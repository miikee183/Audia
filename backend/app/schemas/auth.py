from pydantic import BaseModel


class GoogleAuthRequest(BaseModel):
    id_token: str
    telefono: str | None = None


class AccountInfo(BaseModel):
    id: str
    telefono: str | None = None
    correoGoogle: str | None = None
    correoAudia: str | None = None
    tiene_perfil: bool = False
    id_perfil: str | None = None
    nombre_usuario: str | None = None
    biografia: str | None = None
    foto_perfil: str | None = None
    num_seguidores: int = 0
    num_siguiendo: int = 0
    likes_totales: int = 0

    class Config:
        from_attributes = True


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    account: AccountInfo


class SignUpRequest(BaseModel):
    email: str
    password: str
    telefono: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str


class PhoneAuthRequest(BaseModel):
    telefono: str


class LinkGoogleRequest(BaseModel):
    id_token: str


class LinkEmailRequest(BaseModel):
    email: str
    password: str


class SendCodeRequest(BaseModel):
    telefono: str


class SendCodeResponse(BaseModel):
    message: str
    dev_codigo: str | None = None


class VerifyCodeRequest(BaseModel):
    telefono: str
    codigo: str


class MessageResponse(BaseModel):
    message: str
    id: str
