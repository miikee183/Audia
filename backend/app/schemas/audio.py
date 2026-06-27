from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class AudioResponse(BaseModel):
    id: str
    user_id: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None
    cloudinary_url: str
    duration: float
    like_count: int = 0
    comment_count: int = 0
    is_liked: bool = False
    listen_progress: float = 0.0
    is_completed: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


class AudioListResponse(BaseModel):
    audios: list[AudioResponse]


class AudioCommentCreate(BaseModel):
    text: str


class AudioCommentResponse(BaseModel):
    id: str
    user_id: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None
    text: str
    like_count: int = 0
    is_liked: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


class AudioProgressRequest(BaseModel):
    progress_seconds: float
    completed: bool = False
