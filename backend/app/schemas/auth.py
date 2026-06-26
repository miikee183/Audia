from pydantic import BaseModel
from datetime import datetime


class GoogleAuthRequest(BaseModel):
    id_token: str


class AccountInfo(BaseModel):
    id: str
    telefono: str | None = None
    correoGoogle: str | None = None
    correoAudia: str | None = None
    personalizado: bool

    class Config:
        from_attributes = True


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    account: AccountInfo


class SignUpRequest(BaseModel):
    email: str
    password: str


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
