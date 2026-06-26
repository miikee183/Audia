import os
from datetime import datetime, timedelta, timezone
from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests
from jose import jwt
from jose.exceptions import JWTError
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.models.usuario import Usuario

GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "")
JWT_SECRET = os.environ.get("JWT_SECRET", "audia-super-secret-key-change-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_HOURS = 72


def verify_google_token(token: str) -> dict:
    try:
        info = google_id_token.verify_oauth2_token(
            token, google_requests.Request(), GOOGLE_CLIENT_ID
        )
        if info.get("iss") not in ["accounts.google.com", "https://accounts.google.com"]:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid issuer")
        return info
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


def create_access_token(user_id: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": user_id,
        "iat": now,
        "exp": now + timedelta(hours=JWT_EXPIRY_HOURS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def authenticate_google(token: str, db: Session) -> dict:
    info = verify_google_token(token)
    email = info.get("email")
    if not email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email not provided by Google")

    user = db.query(Usuario).filter(Usuario.correo == email).first()

    if not user:
        user = Usuario(
            correo=email,
            usuario=info.get("name"),
            telefono="",
            auth_provider="google",
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    access_token = create_access_token(user.id)
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user,
    }
