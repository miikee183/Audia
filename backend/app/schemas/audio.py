from pydantic import BaseModel
from typing import Optional


class AudioResponse(BaseModel):
    id: str
    id_perfil_dueno: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None
    audio_url: str
    duracion: float
    num_likes: int = 0
    num_comentarios: int = 0
    foto_fondo: Optional[str] = None
    is_liked: bool = False

    class Config:
        from_attributes = True


class AudioListResponse(BaseModel):
    audios: list[AudioResponse]


class ComentarioCreate(BaseModel):
    texto: str


class ComentarioResponse(BaseModel):
    id: str
    id_perfil_dueno_comentario: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None
    texto: str
    num_likes: int = 0
    is_liked: bool = False

    class Config:
        from_attributes = True
