import os
import tempfile
import cloudinary
import cloudinary.uploader
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.models.personalizacion import Perfil
from app.models.audio import Audio, Comentario
from app.schemas.audio import AudioResponse, AudioListResponse, ComentarioResponse, ComentarioCreate
from app.services.auth_service import get_current_account
from mutagen.mp3 import MP3
from mutagen.wave import WAVE

router = APIRouter(prefix="/audio", tags=["audio"])

cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
)


def _get_duration(file_path: str) -> float:
    try:
        audio = MP3(file_path)
        return audio.info.length
    except Exception:
        try:
            audio = WAVE(file_path)
            return audio.info.length
        except Exception:
            return 0.0


def _get_user_info_from_perfil(db: Session, perfil_id: str) -> tuple[str, str | None]:
    perfil = db.query(Perfil).filter(Perfil.id == perfil_id).first()
    if perfil:
        return perfil.nombre_usuario, perfil.foto_perfil
    return "Usuario", None


def _get_perfil_id(db: Session, account_id: str) -> str:
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")
    return cuenta.perfil.id


def _audio_to_response(audio: Audio, current_perfil_id: str, db: Session) -> AudioResponse:
    username, foto = _get_user_info_from_perfil(db, audio.id_perfil_dueno)
    is_liked = current_perfil_id in (audio.lista_likes_perfiles or [])
    return AudioResponse(
        id=audio.id,
        id_perfil_dueno=audio.id_perfil_dueno,
        nombre_usuario=username,
        foto_perfil=foto,
        audio_url=audio.audio_url,
        duracion=audio.duracion,
        num_likes=audio.num_likes,
        num_comentarios=audio.num_comentarios,
        foto_fondo=audio.foto_fondo,
        is_liked=is_liked,
    )


@router.post("/upload", response_model=AudioResponse)
async def upload_audio(
    file: UploadFile = File(...),
    duracion: float = Form(...),
    foto_fondo: str | None = Form(None),
    fondo_file: UploadFile | None = File(None),
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)

    suffix = os.path.splitext(file.filename or "audio.mp3")[1] or ".mp3"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
        actual_duration = _get_duration(tmp_path)
        if actual_duration > 0:
            duracion = actual_duration

        result = cloudinary.uploader.upload(
            tmp_path,
            resource_type="video",
            folder="audia_audio",
            use_filename=True,
            unique_filename=True,
        )
        audio_url = result["secure_url"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error subiendo a Cloudinary: {str(e)}")
    finally:
        os.unlink(tmp_path)

    # Si se subió una imagen de fondo, súbela a Cloudinary
    fondo_final = foto_fondo
    if fondo_file:
        suffix_img = os.path.splitext(fondo_file.filename or "fondo.jpg")[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix_img) as tmp_img:
            content_img = await fondo_file.read()
            tmp_img.write(content_img)
            tmp_img_path = tmp_img.name
        try:
            result_img = cloudinary.uploader.upload(
                tmp_img_path,
                resource_type="image",
                folder="audia_fondos",
                use_filename=True,
                unique_filename=True,
            )
            fondo_final = result_img["secure_url"]
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error subiendo imagen de fondo: {str(e)}")
        finally:
            os.unlink(tmp_img_path)

    audio = Audio(
        id_perfil_dueno=perfil_id,
        audio_url=audio_url,
        duracion=duracion,
        foto_fondo=fondo_final,
    )
    db.add(audio)
    db.commit()
    db.refresh(audio)

    return _audio_to_response(audio, perfil_id, db)


def _can_view_audio(perfil_id: str, owner_id: str, db: Session) -> bool:
    """Check if perfil_id can view audios from owner_id."""
    owner = db.query(Perfil).filter(Perfil.id == owner_id).first()
    if not owner:
        return False

    # Check if owner blocked the current user
    if perfil_id in (owner.lista_bloqueados or []):
        return False

    # Check if current user blocked the owner
    current = db.query(Perfil).filter(Perfil.id == perfil_id).first()
    if current and owner_id in (current.lista_bloqueados or []):
        return False

    # If owner has private account, only show to mutual followers (amigos)
    if owner.cuenta_privada:
        if perfil_id == owner_id:
            return True
        seguidores_owner = set(owner.lista_seguidores or [])
        siguiendo_owner = set(owner.lista_siguiendo or [])
        if perfil_id in seguidores_owner and perfil_id in siguiendo_owner:
            return True
        return False

    return True


@router.get("/", response_model=AudioListResponse)
def list_audios(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audios = db.query(Audio).order_by(Audio.id.desc()).all()

    filtered = [a for a in audios if _can_view_audio(perfil_id, a.id_perfil_dueno, db)]

    return AudioListResponse(
        audios=[_audio_to_response(a, perfil_id, db) for a in filtered]
    )


@router.get("/mis-audios", response_model=AudioListResponse)
def mis_audios(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audios = db.query(Audio).filter(Audio.id_perfil_dueno == perfil_id).order_by(Audio.id.desc()).all()
    return AudioListResponse(
        audios=[_audio_to_response(a, perfil_id, db) for a in audios]
    )


@router.post("/{audio_id}/like")
def toggle_like(
    audio_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    likes = list(audio.lista_likes_perfiles or [])

    if perfil_id in likes:
        likes.remove(perfil_id)
        audio.lista_likes_perfiles = likes
        audio.num_likes = max(0, audio.num_likes - 1)
        db.commit()
        return {"liked": False, "num_likes": audio.num_likes}
    else:
        likes.append(perfil_id)
        audio.lista_likes_perfiles = likes
        audio.num_likes += 1
        db.commit()
        return {"liked": True, "num_likes": audio.num_likes}


@router.post("/{audio_id}/comentario", response_model=ComentarioResponse)
def add_comentario(
    audio_id: str,
    request: ComentarioCreate,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    if not request.texto.strip():
        raise HTTPException(status_code=400, detail="El comentario no puede estar vacío")

    comentario = Comentario(
        id_perfil_dueno_comentario=perfil_id,
        id_audio=audio_id,
        texto=request.texto.strip(),
    )
    db.add(comentario)
    audio.num_comentarios += 1
    db.commit()
    db.refresh(comentario)

    username, foto = _get_user_info_from_perfil(db, perfil_id)
    return ComentarioResponse(
        id=comentario.id,
        id_perfil_dueno_comentario=perfil_id,
        nombre_usuario=username,
        foto_perfil=foto,
        texto=comentario.texto,
        num_likes=comentario.num_likes,
        is_liked=False,
    )


@router.get("/{audio_id}/comentarios")
def list_comentarios(
    audio_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    comentarios = (
        db.query(Comentario)
        .filter(Comentario.id_audio == audio_id)
        .order_by(Comentario.id.desc())
        .all()
    )
    result = []
    for c in comentarios:
        username, foto = _get_user_info_from_perfil(db, c.id_perfil_dueno_comentario)
        is_liked = perfil_id in (c.lista_likes_perfiles or [])
        result.append(ComentarioResponse(
            id=c.id,
            id_perfil_dueno_comentario=c.id_perfil_dueno_comentario,
            nombre_usuario=username,
            foto_perfil=foto,
            texto=c.texto,
            num_likes=c.num_likes,
            is_liked=is_liked,
        ))
    return result


@router.post("/{audio_id}/comentario/{comentario_id}/like")
def toggle_comentario_like(
    audio_id: str,
    comentario_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    perfil_id = _get_perfil_id(db, account_id)
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    comentario = db.query(Comentario).filter(
        Comentario.id == comentario_id, Comentario.id_audio == audio_id
    ).first()
    if not comentario:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")

    likes = list(comentario.lista_likes_perfiles or [])

    if perfil_id in likes:
        likes.remove(perfil_id)
        comentario.lista_likes_perfiles = likes
        comentario.num_likes = max(0, comentario.num_likes - 1)
        db.commit()
        return {"liked": False, "num_likes": comentario.num_likes}
    else:
        likes.append(perfil_id)
        comentario.lista_likes_perfiles = likes
        comentario.num_likes += 1
        db.commit()
        return {"liked": True, "num_likes": comentario.num_likes}
