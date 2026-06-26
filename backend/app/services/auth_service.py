import os
from dotenv import load_dotenv

load_dotenv()
from datetime import datetime, timedelta, timezone
from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests
from jose import jwt
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.models.cuenta import Cuenta

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


def create_access_token(account_id: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": account_id,
        "iat": now,
        "exp": now + timedelta(hours=JWT_EXPIRY_HOURS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def authenticate_google(token: str, db: Session) -> dict:
    info = verify_google_token(token)
    email = info.get("email")
    if not email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email not provided by Google")

    cuenta = db.query(Cuenta).filter(Cuenta.correoGoogle == email).first()

    if not cuenta:
        cuenta = Cuenta(
            correoGoogle=email,
            personalizado=False,
        )
        db.add(cuenta)
        db.commit()
        db.refresh(cuenta)

    access_token = create_access_token(cuenta.id)
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "account": cuenta,
    }
