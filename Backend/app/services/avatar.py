from typing import List
from sqlalchemy.orm import Session
from app.models.avatar import Avatar
from app.schemas.avatar import AvatarCreate

def get_all_avatars(db: Session) -> List[Avatar]:
    return db.query(Avatar).order_by(Avatar.id).all()

def create_avatar(db: Session, avatar_in: AvatarCreate) -> Avatar:
    db_avatar = Avatar(
        name=avatar_in.name,
        image_url=str(avatar_in.image_url),
        description=avatar_in.description
    )
    db.add(db_avatar)
    db.commit()
    db.refresh(db_avatar)
    return db_avatar