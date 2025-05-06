# app/routers/auth.py

from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserRead, UserUpdate
from app.schemas.token import Token
from app.services.auth import (
    create_user,
    authenticate_user,
    create_access_token,
    get_current_user,
    oauth2_scheme,
    blacklisted_tokens,
)
from app.db.session import get_db
from app.core.security import get_password_hash

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

@router.post(
    "/login",
    response_model=Token
)
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    """
    OAuth2 Password flow ile login:
    - form_data.username as email
    - form_data.password as plain password
    - authenticate_user ile doğrula
    - create_access_token ile JWT üret
    """
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = create_access_token(data={"sub": user.email})
    return {"access_token": token, "token_type": "bearer"}


@router.get(
    "/me",
    response_model=UserRead,
    status_code=200,
    summary="Get current user",
    description="Return the currently authenticated user based on Bearer token"
)
def read_users_me(
    current_user: UserRead = Depends(get_current_user)
):
    return current_user


@router.put(
    "/me",
    response_model=UserRead,
    summary="Update current user",
    description="Update full_name, date_of_birth or password for the authenticated user"
)
def update_me(
    user_in: UserUpdate,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if user_in.full_name is not None:
        current_user.full_name = user_in.full_name
    if user_in.date_of_birth is not None:
        current_user.date_of_birth = user_in.date_of_birth
    if user_in.password is not None:
        current_user.hashed_password = get_password_hash(user_in.password)

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return current_user


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Log out",
    description="Invalidate the current access token"
)
def logout(
    # 1) token geçerli mi diye kontrol et
    current_user = Depends(get_current_user),
    # 2) ham token’ı al
    token: str = Depends(oauth2_scheme),
):
    """
    Mevcut Bearer token’ı blacklist’e ekle.
    Sonrasında aynı token ile yapılan istekler 401 dönecek.
    """
    blacklisted_tokens.add(token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
