# app/services/auth.py

from datetime import datetime, timedelta
from typing import Optional

from jose import jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.schemas.user import UserCreate
from app.core.security import get_password_hash, verify_password
from app.core.config import settings

# Parola işlemleri için Passlib context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
