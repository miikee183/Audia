from pydantic import BaseModel
from typing import Optional

class PersonalizacionRequest(BaseModel):
    cuenta_id: str
    ano_nacimiento: int
    sexo: str
    nombre_usuario: str
    gustos: Optional[str] = None
    foto_perfil: Optional[str] = None
    idioma: str
