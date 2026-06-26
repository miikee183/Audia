from pydantic import BaseModel
from datetime import datetime


class GoogleAuthRequest(BaseModel):
    id_token: str


class UserInfo(BaseModel):
    id: str
    correo: str
    usuario: str | None
    auth_provider: str
    personalizado: bool

    class Config:
        from_attributes = True


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserInfo
