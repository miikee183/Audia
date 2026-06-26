from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.schemas.auth import GoogleAuthRequest, AuthResponse, AccountInfo, SignUpRequest, LoginRequest, MessageResponse
from app.services.auth_service import authenticate_google, hash_password, verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/google", response_model=AuthResponse)
def google_auth(request: GoogleAuthRequest, db: Session = Depends(get_db)):
    result = authenticate_google(request.id_token, db)
    return AuthResponse(
        access_token=result["access_token"],
        token_type=result["token_type"],
        account=AccountInfo.model_validate(result["account"]),
    )


@router.post("/signup", response_model=MessageResponse)
def signup(request: SignUpRequest, db: Session = Depends(get_db)):
    existing = db.query(Cuenta).filter(Cuenta.correoAudia == request.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    cuenta = Cuenta(
        correoAudia=request.email,
        contrasenaAudia=hash_password(request.password),
        personalizado=False,
    )
    db.add(cuenta)
    db.commit()
    db.refresh(cuenta)

    return MessageResponse(message="Cuenta creada con éxito", id=cuenta.id)


@router.post("/login", response_model=AuthResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    cuenta = db.query(Cuenta).filter(Cuenta.correoAudia == request.email).first()
    if not cuenta or not cuenta.contrasenaAudia:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    if not verify_password(request.password, cuenta.contrasenaAudia):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    access_token = create_access_token(cuenta.id)
    return AuthResponse(
        access_token=access_token,
        token_type="bearer",
        account=AccountInfo.model_validate(cuenta),
    )
