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


def _get_user_info(db: Session, user_id: str) -> tuple[str, str | None]:
    cuenta = db.query(Cuenta).filter(Cuenta.id == user_id).first()
    if cuenta and cuenta.perfil:
        return cuenta.perfil.nombre_usuario, cuenta.perfil.foto_perfil
    return "Usuario", None


def _audio_to_response(audio: Audio, current_user_id: str, db: Session) -> AudioResponse:
    username, foto = _get_user_info(db, audio.id_cuenta_dueno)
    is_liked = current_user_id in (audio.lista_likes_cuentas or [])
    return AudioResponse(
        id=audio.id,
        id_cuenta_dueno=audio.id_cuenta_dueno,
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
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")

    suffix = os.path.splitext(file.filename or "audio.mp3")[1] or ".mp3"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix, dir="temp") as tmp:
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

    audio = Audio(
        id_cuenta_dueno=account_id,
        audio_url=audio_url,
        duracion=duracion,
        foto_fondo=foto_fondo,
    )
    db.add(audio)
    db.commit()
    db.refresh(audio)

    return _audio_to_response(audio, account_id, db)


@router.get("/", response_model=AudioListResponse)
def list_audios(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audios = db.query(Audio).order_by(Audio.id.desc()).all()

    return AudioListResponse(
        audios=[_audio_to_response(a, account_id, db) for a in audios]
    )


@router.get("/mis-audios", response_model=AudioListResponse)
def mis_audios(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audios = db.query(Audio).filter(Audio.id_cuenta_dueno == account_id).order_by(Audio.id.desc()).all()
    return AudioListResponse(
        audios=[_audio_to_response(a, account_id, db) for a in audios]
    )


@router.post("/{audio_id}/like")
def toggle_like(
    audio_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    if not audio.lista_likes_cuentas:
        audio.lista_likes_cuentas = []

    if account_id in audio.lista_likes_cuentas:
        audio.lista_likes_cuentas.remove(account_id)
        audio.num_likes = max(0, audio.num_likes - 1)
        db.commit()
        return {"liked": False, "num_likes": audio.num_likes}
    else:
        audio.lista_likes_cuentas.append(account_id)
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
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    if not request.texto.strip():
        raise HTTPException(status_code=400, detail="El comentario no puede estar vacío")

    comentario = Comentario(
        id_dueno_comentario=account_id,
        id_audio=audio_id,
        texto=request.texto.strip(),
    )
    db.add(comentario)
    audio.num_comentarios += 1
    db.commit()
    db.refresh(comentario)

    username, foto = _get_user_info(db, account_id)
    return ComentarioResponse(
        id=comentario.id,
        id_dueno_comentario=account_id,
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
        username, foto = _get_user_info(db, c.id_dueno_comentario)
        is_liked = account_id in (c.lista_likes_cuentas or [])
        result.append(ComentarioResponse(
            id=c.id,
            id_dueno_comentario=c.id_dueno_comentario,
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
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    comentario = db.query(Comentario).filter(
        Comentario.id == comentario_id, Comentario.id_audio == audio_id
    ).first()
    if not comentario:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")

    if not comentario.lista_likes_cuentas:
        comentario.lista_likes_cuentas = []

    if account_id in comentario.lista_likes_cuentas:
        comentario.lista_likes_cuentas.remove(account_id)
        comentario.num_likes = max(0, comentario.num_likes - 1)
        db.commit()
        return {"liked": False, "num_likes": comentario.num_likes}
    else:
        comentario.lista_likes_cuentas.append(account_id)
        comentario.num_likes += 1
        db.commit()
        return {"liked": True, "num_likes": comentario.num_likes}
