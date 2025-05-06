# app/services/user_avatar.py

from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime

from app.models.user_avatar import UserAvatar

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
