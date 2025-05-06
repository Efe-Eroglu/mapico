from typing import List
from sqlalchemy.orm import Session

from app.models.avatar import Avatar
from app.schemas.avatar import AvatarCreate
from app.core.encryption import encryption_service

def get_all_avatars(db: Session) -> List[Avatar]:
    avatars = db.query(Avatar).order_by(Avatar.id).all()
    for a in avatars:
        a.name = encryption_service.decrypt(a.name)
        if a.description is not None:
            a.description = encryption_service.decrypt(a.description)
    return avatars

def create_avatar(db: Session, avatar_in: AvatarCreate) -> Avatar:
    encrypted_name = encryption_service.encrypt(avatar_in.name)
    encrypted_desc = (
        encryption_service.encrypt(avatar_in.description)
        if avatar_in.description is not None else None
    )

    db_avatar = Avatar(
        name=encrypted_name,
        image_url=str(avatar_in.image_url),
        description=encrypted_desc
    )
    db.add(db_avatar)
    db.commit()
    db.refresh(db_avatar)

    # Dönerken de decrypt edelim
    db_avatar.name = avatar_in.name
    db_avatar.description = avatar_in.description
    return db_avatar


