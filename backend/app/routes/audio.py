import os
import uuid
import tempfile
import cloudinary
import cloudinary.uploader
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.models.personalizacion import Personalizacion
from app.models.audio import Audio, AudioLike, AudioComment, AudioListen
from app.schemas.audio import AudioResponse, AudioListResponse, AudioCommentResponse, AudioCommentCreate, AudioProgressRequest
from app.services.auth_service import get_current_account
from mutagen.mp3 import MP3
from mutagen.wave import WAVE
from datetime import datetime

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
    pers = db.query(Personalizacion).filter(Personalizacion.cuenta_id == user_id).first()
    if pers:
        return pers.nombre_usuario, pers.foto_perfil
    return "Usuario", None


def _audio_to_response(audio: Audio, current_user_id: str, db: Session) -> AudioResponse:
    username, foto = _get_user_info(db, audio.user_id)
    like_count = db.query(func.count(AudioLike.id)).filter(AudioLike.audio_id == audio.id).scalar() or 0
    comment_count = db.query(func.count(AudioComment.id)).filter(AudioComment.audio_id == audio.id).scalar() or 0
    is_liked = db.query(AudioLike).filter(
        AudioLike.user_id == current_user_id, AudioLike.audio_id == audio.id
    ).first() is not None
    listen = db.query(AudioListen).filter(
        AudioListen.user_id == current_user_id, AudioListen.audio_id == audio.id
    ).first()
    listen_progress = listen.progress_seconds if listen else 0.0
    is_completed = listen.completed if listen else False
    return AudioResponse(
        id=audio.id,
        user_id=audio.user_id,
        nombre_usuario=username,
        foto_perfil=foto,
        cloudinary_url=audio.cloudinary_url,
        duration=audio.duration,
        like_count=like_count,
        comment_count=comment_count,
        is_liked=is_liked,
        listen_progress=listen_progress,
        is_completed=is_completed,
        created_at=audio.created_at,
    )


@router.post("/upload", response_model=AudioResponse)
async def upload_audio(
    file: UploadFile = File(...),
    duration: float = Form(...),
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
            duration = actual_duration

        result = cloudinary.uploader.upload(
            tmp_path,
            resource_type="video",
            folder="audia_audio",
            use_filename=True,
            unique_filename=True,
        )
        cloudinary_url = result["secure_url"]
        public_id = result["public_id"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error subiendo a Cloudinary: {str(e)}")
    finally:
        os.unlink(tmp_path)

    audio = Audio(
        user_id=account_id,
        cloudinary_url=cloudinary_url,
        cloudinary_public_id=public_id,
        duration=duration,
    )
    db.add(audio)
    db.commit()
    db.refresh(audio)

    return _audio_to_response(audio, account_id, db)


@router.get("/", response_model=AudioListResponse)
def list_audios(
    source: str = Query("para_ti", pattern="^(para_ti|contactos|siguiendo)$"),
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    query = (
        db.query(Audio)
        .options(joinedload(Audio.user))
        .order_by(Audio.created_at.desc())
    )

    if source == "contactos":
        query = query.filter(Audio.user_id == account_id)
    elif source == "siguiendo":
        query = query.filter(Audio.user_id == account_id)
    audios = query.all()

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

    existing = db.query(AudioLike).filter(
        AudioLike.user_id == account_id, AudioLike.audio_id == audio_id
    ).first()

    if existing:
        db.delete(existing)
        db.commit()
        return {"liked": False, "like_count": db.query(func.count(AudioLike.id)).filter(AudioLike.audio_id == audio_id).scalar()}
    else:
        like = AudioLike(user_id=account_id, audio_id=audio_id)
        db.add(like)
        db.commit()
        return {"liked": True, "like_count": db.query(func.count(AudioLike.id)).filter(AudioLike.audio_id == audio_id).scalar()}


@router.post("/{audio_id}/comment", response_model=AudioCommentResponse)
def add_comment(
    audio_id: str,
    request: AudioCommentCreate,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    if not request.text.strip():
        raise HTTPException(status_code=400, detail="El comentario no puede estar vacío")

    comment = AudioComment(user_id=account_id, audio_id=audio_id, text=request.text.strip())
    db.add(comment)
    db.commit()
    db.refresh(comment)

    username, foto = _get_user_info(db, account_id)
    return AudioCommentResponse(
        id=comment.id,
        user_id=account_id,
        nombre_usuario=username,
        foto_perfil=foto,
        text=comment.text,
        like_count=0,
        is_liked=False,
        created_at=comment.created_at,
    )


@router.get("/{audio_id}/comments")
def list_comments(
    audio_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    comments = (
        db.query(AudioComment)
        .filter(AudioComment.audio_id == audio_id)
        .order_by(AudioComment.created_at.desc())
        .all()
    )
    result = []
    for c in comments:
        username, foto = _get_user_info(db, c.user_id)
        result.append(AudioCommentResponse(
            id=c.id,
            user_id=c.user_id,
            nombre_usuario=username,
            foto_perfil=foto,
            text=c.text,
            like_count=0,
            is_liked=False,
            created_at=c.created_at,
        ))
    return result


@router.post("/{audio_id}/progress")
def update_progress(
    audio_id: str,
    request: AudioProgressRequest,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    audio = db.query(Audio).filter(Audio.id == audio_id).first()
    if not audio:
        raise HTTPException(status_code=404, detail="Audio no encontrado")

    listen = db.query(AudioListen).filter(
        AudioListen.user_id == account_id, AudioListen.audio_id == audio_id
    ).first()

    if listen:
        listen.progress_seconds = request.progress_seconds
        listen.completed = request.completed
        listen.updated_at = datetime.now()
    else:
        listen = AudioListen(
            user_id=account_id,
            audio_id=audio_id,
            progress_seconds=request.progress_seconds,
            completed=request.completed,
        )
        db.add(listen)

    db.commit()
    return {"message": "Progreso actualizado"}
