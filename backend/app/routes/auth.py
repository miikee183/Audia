from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.schemas.auth import (
    GoogleAuthRequest, AuthResponse, AccountInfo, SignUpRequest,
    LoginRequest, PhoneAuthRequest, LinkGoogleRequest, LinkEmailRequest,
    SendCodeRequest, SendCodeResponse, VerifyCodeRequest,
)
from app.services.auth_service import hash_password, verify_password, create_access_token, verify_google_token, get_current_account
from app.services.sms_service import send_sms, generate_code, is_configured
from app.models.codigo_verificacion import CodigoVerificacion
from datetime import datetime, timedelta, timezone

router = APIRouter(prefix="/auth", tags=["auth"])


def _cuenta_to_response(cuenta: Cuenta) -> AuthResponse:
    access_token = create_access_token(cuenta.id)
    account_data = {
        "id": cuenta.id,
        "telefono": cuenta.telefono,
        "correoGoogle": cuenta.correoGoogle,
        "correoAudia": cuenta.correoAudia,
        "tiene_perfil": cuenta.perfil is not None,
    }
    if cuenta.perfil:
        account_data["nombre_usuario"] = cuenta.perfil.nombre_usuario
        account_data["biografia"] = cuenta.perfil.biografia
        account_data["foto_perfil"] = cuenta.perfil.foto_perfil
        account_data["num_seguidores"] = cuenta.perfil.num_seguidores
        account_data["num_siguiendo"] = cuenta.perfil.num_siguiendo
        account_data["likes_totales"] = cuenta.perfil.likes_totales
    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        account=AccountInfo(**account_data),
    )


@router.post("/send-code", response_model=SendCodeResponse)
def send_code(request: SendCodeRequest, db: Session = Depends(get_db)):
    telefono = request.telefono.strip()
    if not telefono:
        raise HTTPException(status_code=400, detail="Teléfono requerido")

    codigo = generate_code()
    expires_at = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(minutes=5)

    codigo_v = CodigoVerificacion(
        telefono=telefono,
        codigo=codigo,
        expires_at=expires_at,
    )
    db.add(codigo_v)
    db.commit()

    send_sms(telefono, codigo)

    return SendCodeResponse(
        message="Código enviado",
        dev_codigo=codigo if not is_configured() else None,
    )


@router.post("/verify-code", response_model=AuthResponse)
def verify_code(request: VerifyCodeRequest, db: Session = Depends(get_db)):
    telefono = request.telefono.strip()
    codigo = request.codigo.strip()

    codigo_v = (
        db.query(CodigoVerificacion)
        .filter(
            CodigoVerificacion.telefono == telefono,
            CodigoVerificacion.codigo == codigo,
            CodigoVerificacion.usado == False,
            CodigoVerificacion.expires_at > datetime.now(timezone.utc).replace(tzinfo=None),
        )
        .order_by(CodigoVerificacion.created_at.desc())
        .first()
    )

    if not codigo_v:
        raise HTTPException(status_code=400, detail="Código inválido o expirado")

    codigo_v.usado = True
    db.flush()

    cuenta = db.query(Cuenta).filter(Cuenta.telefono == telefono).first()
    if not cuenta:
        cuenta = Cuenta(telefono=telefono)
        db.add(cuenta)

    db.commit()
    db.refresh(cuenta)

    return _cuenta_to_response(cuenta)


@router.post("/phone", response_model=AuthResponse)
def phone_auth(request: PhoneAuthRequest, db: Session = Depends(get_db)):
    telefono = request.telefono.strip()
    cuenta = db.query(Cuenta).filter(Cuenta.telefono == telefono).first()
    if not cuenta:
        cuenta = Cuenta(telefono=telefono)
        db.add(cuenta)
        db.commit()
        db.refresh(cuenta)
    return _cuenta_to_response(cuenta)


@router.post("/google", response_model=AuthResponse)
def google_auth(request: GoogleAuthRequest, db: Session = Depends(get_db)):
    info = verify_google_token(request.id_token)
    email = info.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email not provided by Google")

    existente = (
        db.query(Cuenta)
        .filter((Cuenta.correoGoogle == email) | (Cuenta.correoAudia == email))
        .first()
    )
    if existente:
        if existente.correoGoogle == email:
            return _cuenta_to_response(existente)
        raise HTTPException(status_code=400, detail="El correo ya está registrado con otra cuenta")

    if request.telefono:
        cuenta = db.query(Cuenta).filter(Cuenta.telefono == request.telefono).first()
        if cuenta:
            cuenta.correoGoogle = email
            db.commit()
            db.refresh(cuenta)
            return _cuenta_to_response(cuenta)

    cuenta = Cuenta(correoGoogle=email)
    db.add(cuenta)
    db.commit()
    db.refresh(cuenta)

    return _cuenta_to_response(cuenta)


@router.post("/signup", response_model=AuthResponse)
def signup(request: SignUpRequest, db: Session = Depends(get_db)):
    existing = (
        db.query(Cuenta)
        .filter((Cuenta.correoAudia == request.email) | (Cuenta.correoGoogle == request.email))
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    if request.telefono:
        cuenta = db.query(Cuenta).filter(Cuenta.telefono == request.telefono).first()
        if cuenta:
            cuenta.correoAudia = request.email
            cuenta.contrasenaAudia = hash_password(request.password)
            db.commit()
            db.refresh(cuenta)
            return _cuenta_to_response(cuenta)

    cuenta = Cuenta(
        correoAudia=request.email,
        contrasenaAudia=hash_password(request.password),
    )
    db.add(cuenta)
    db.commit()
    db.refresh(cuenta)

    return _cuenta_to_response(cuenta)


@router.post("/login", response_model=AuthResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    cuenta = db.query(Cuenta).filter(Cuenta.correoAudia == request.email).first()
    if not cuenta or not cuenta.contrasenaAudia:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    if not verify_password(request.password, cuenta.contrasenaAudia):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    return _cuenta_to_response(cuenta)


@router.post("/link-google", response_model=AuthResponse)
def link_google(
    request: LinkGoogleRequest,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    info = verify_google_token(request.id_token)
    email = info.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email not provided by Google")

    taken = (
        db.query(Cuenta)
        .filter((Cuenta.correoGoogle == email) | (Cuenta.correoAudia == email))
        .first()
    )
    if taken:
        raise HTTPException(status_code=400, detail="Ese correo ya está vinculado a otra cuenta")

    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")

    cuenta.correoGoogle = email
    db.commit()
    db.refresh(cuenta)
    return _cuenta_to_response(cuenta)


@router.post("/link-email", response_model=AuthResponse)
def link_email(
    request: LinkEmailRequest,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    taken = (
        db.query(Cuenta)
        .filter((Cuenta.correoAudia == request.email) | (Cuenta.correoGoogle == request.email))
        .first()
    )
    if taken:
        raise HTTPException(status_code=400, detail="Ese correo ya está registrado")

    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")

    cuenta.correoAudia = request.email
    cuenta.contrasenaAudia = hash_password(request.password)
    db.commit()
    db.refresh(cuenta)
    return _cuenta_to_response(cuenta)


@router.get("/me", response_model=AuthResponse)
def get_current_user(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")
    return _cuenta_to_response(cuenta)
