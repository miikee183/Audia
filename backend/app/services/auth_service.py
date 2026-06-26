import os
from dotenv import load_dotenv

load_dotenv()
from datetime import datetime, timedelta, timezone
from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests
from jose import jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, Header, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.cuenta import Cuenta

GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "")
JWT_SECRET = os.environ.get("JWT_SECRET", "audia-super-secret-key-change-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_HOURS = 72

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_current_account(
    authorization: str = Header(...),
    db: Session = Depends(get_db),
) -> str:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header")
    token = authorization[7:]
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        account_id = payload.get("sub")
        if not account_id:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        return account_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


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



