from pydantic import BaseModel
from datetime import datetime


class GoogleAuthRequest(BaseModel):
    id_token: str


class AccountInfo(BaseModel):
    id: str
    correoGoogle: str | None = None
    correoAudia: str | None = None
    telefono: str | None = None
    personalizado: bool

    class Config:
        from_attributes = True


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    account: AccountInfo
