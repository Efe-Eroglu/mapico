from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.schemas.user import UserCreate, UserRead
from app.services.user import create_user
from app.db.session import get_db

router = APIRouter(prefix="/api/v1/auth", tags=["Auth"])

@router.post(
    "/register",
    response_model=UserRead,
    status_code=status.HTTP_201_CREATED
)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    """
    Yeni kullanıcı kaydı:
    - UserCreate şemasına göre body doğrulaması
    - create_user servisini çağırır
    - Hataları yakalayıp 400 döner
    """
    try:
        user = create_user(db, user_in)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    return user
