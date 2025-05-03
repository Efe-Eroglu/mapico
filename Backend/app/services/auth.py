# app/services/auth.py

from datetime import datetime, timedelta
from typing import Optional
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.models.user import User
from app.schemas.user import UserCreate
from app.core.security import get_password_hash, verify_password
from app.core.config import settings
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from app.db.session import get_db


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def create_user(db: Session, user_in: UserCreate) -> User:
    """
    Yeni bir kullanıcı kaydı oluşturur.
    - Email zaten varsa ValueError fırlatır.
    - Şifreyi hash’ler.
    - Commit edip taze kaydı döner.
    """
    # 1) Email kontrolü
    existing = db.query(User).filter(User.email == user_in.email).first()
    if existing:
        raise ValueError("Bu email zaten kayıtlı")

    # 2) Hash’lenmiş şifre
    hashed_pwd = get_password_hash(user_in.password)

    # 3) User nesnesi oluştur ve DB’ye ekle
    db_user = User(
        email=user_in.email,
        full_name=user_in.full_name,
        date_of_birth=user_in.date_of_birth,
        hashed_password=hashed_pwd
    )
    db.add(db_user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise ValueError("Kayıt sırasında bir hata oluştu")
    db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
    """
    Email + şifreyi kontrol eder. Başarılıysa User objesini,
    başarısızsa None döner.
    """
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user

def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    JWT oluşturur. data içine en az {"sub": user.email} koymalısınız.
    expire süresi settings.ACCESS_TOKEN_EXPIRE_MINUTES’ten alınır.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )
    return encoded_jwt


def get_current_user(
    token: str = Depends(oauth2_scheme),  
    db: Session = Depends(get_db),
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user