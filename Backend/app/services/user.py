from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.schemas.user import UserCreate
from app.core.security import get_password_hash

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
