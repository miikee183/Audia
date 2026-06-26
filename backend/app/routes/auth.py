from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.schemas.auth import GoogleAuthRequest, AuthResponse, UserInfo
from app.services.auth_service import authenticate_google

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/google", response_model=AuthResponse)
def google_auth(request: GoogleAuthRequest, db: Session = Depends(get_db)):
    result = authenticate_google(request.id_token, db)
    return AuthResponse(
        access_token=result["access_token"],
        token_type=result["token_type"],
        user=UserInfo.model_validate(result["user"]),
    )
