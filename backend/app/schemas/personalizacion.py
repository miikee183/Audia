from pydantic import BaseModel
from typing import Optional
from datetime import date


class PerfilRequest(BaseModel):
    cuenta_id: str
    fecha_nacimiento: date
    sexo: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None
    biografia: Optional[str] = None
    idioma: str
