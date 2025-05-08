from sqlalchemy.orm import Session
from app.models.user_badge import UserBadge
from app.models.badge import Badge
from app.schemas.user_badge import UserBadgeCreate, UserBadgeRead
from fastapi import HTTPException, status
from app.core.encryption import encryption_service
from app.models.user import User

def create_user_badge(
    db: Session, user_id: int, badge_in: UserBadgeCreate
) -> UserBadgeRead:
    # Yeni bir user_badge oluşturuyoruz
    db_user_badge = UserBadge(
        user_id=user_id,  # User id'yi route'dan alıyoruz
        badge_id=badge_in.badge_id
    )

    db.add(db_user_badge)
    db.commit()
    db.refresh(db_user_badge)

    # Kullanıcı rozetini UserBadgeRead formatında döndürüyoruz
    return UserBadgeRead(
        id=db_user_badge.id,
        user_id=db_user_badge.user_id,
        badge_id=db_user_badge.badge_id,
        awarded_at=db_user_badge.awarded_at
    )
    
    
def get_user_badges(db: Session, user_id: int) -> list[UserBadgeRead]:
    # Kullanıcıya ait rozetleri getiriyoruz
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == user_id).all()

    if not user_badges:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No badges found for this user"
        )

    return [
        UserBadgeRead(
            id=user_badge.id,
            user_id=user_badge.user_id,
            badge_id=user_badge.badge_id,
            awarded_at=user_badge.awarded_at
        ) for user_badge in user_badges
    ]

def get_user_badges_by_user_id(db: Session, user_id: int):
    # Kullanıcıyı getiriyoruz
    user = db.query(User).filter(User.id == user_id).first()

    # Eğer kullanıcı bulunmazsa hata fırlatıyoruz
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Kullanıcıya ait rozetleri alıyoruz
    db_user_badges = db.query(UserBadge).filter(UserBadge.user_id == user_id).all()
    
    if not db_user_badges:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User has no badges"
        )

    # Kullanıcı bilgilerini ve rozetleri döndürüyoruz
    return {
        "user_info": {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "date_of_birth": user.date_of_birth,
            "is_active": user.is_active,
            "created_at": user.created_at,
            "updated_at": user.updated_at
        },
        "badges": [
            UserBadgeRead(
                id=user_badge.id,
                user_id=user_badge.user_id,
                badge_id=user_badge.badge_id,
                awarded_at=user_badge.awarded_at
            ) for user_badge in db_user_badges
        ]
    }