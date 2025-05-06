# app/services/user_avatar.py
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
from app.models.user_avatar import UserAvatar
from app.schemas.user_avatar import UserAvatarRead
from app.schemas.avatar import AvatarRead
from app.core.encryption import encryption_service

def assign_avatar(db: Session, user_id: int, avatar_id: int) -> UserAvatar:
    """
    Eğer user_id ile daha önce bir kayıt yapılmışsa:
      - avatar_id ve selected_at güncellenir.
    Yoksa:
      - yeni bir UserAvatar oluşturulur.
    """
    try:
        ua = db.query(UserAvatar).filter(UserAvatar.user_id == user_id).first()
        if ua:
            ua.avatar_id = avatar_id
            ua.selected_at = datetime.utcnow()
        else:
            ua = UserAvatar(user_id=user_id, avatar_id=avatar_id)
            db.add(ua)
        db.commit()
        db.refresh(ua)
        return ua
    except SQLAlchemyError:
        db.rollback()
        raise ValueError("Avatar ataması başarısız")


  
    
def get_user_avatar_with_details(db: Session, user_id: int) -> UserAvatarRead:
    # Kullanıcının aktif avatarını ve detaylarını alıyoruz
    user_avatar = (
        db.query(UserAvatar)
        .filter(UserAvatar.user_id == user_id)
        .options(joinedload(UserAvatar.avatar))  # Avatar detaylarını da yükle
        .first()  # Kullanıcıya ait bir tane avatar olacak
    )
    
    if not user_avatar:
        return None

    # Avatar detaylarını getirelim
    avatar = user_avatar.avatar

    # Eğer avatar varsa, decrypt işlemi yapılır (eğer şifrelenmişse)
    try:
        avatar.name = encryption_service.decrypt(avatar.name)
    except Exception:
        pass  # Eğer şifrelenmemişse bir şey yapmamıza gerek yok

    if avatar.description is not None:
        try:
            avatar.description = encryption_service.decrypt(avatar.description)
        except Exception:
            pass  # Eğer şifrelenmemişse bir şey yapmamıza gerek yok

    # Avatar modelini Pydantic AvatarRead şemasına dönüştürüyoruz
    avatar_data = AvatarRead(
        id=avatar.id,
        name=avatar.name,
        description=avatar.description,
        image_url=avatar.image_url
    )

    # UserAvatarRead şemasına uygun olarak döndür
    return UserAvatarRead(
        id=user_avatar.id,
        user_id=user_avatar.user_id,
        avatar_id=user_avatar.avatar_id,
        selected_at=user_avatar.selected_at,
        avatar=avatar_data  # Avatar detaylarını da dahil ediyoruz
    )