from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.user_badge import UserBadgeCreate, UserBadgeRead
from app.services.user_badge import create_user_badge, get_user_badges, create_user_badge, get_user_badges_by_user_id
from app.db.session import get_db
from typing import List
from app.services.auth import get_current_user 

router = APIRouter(prefix="/api/v1/user_badges", tags=["UserBadges"])


      
# Kullanıcının rozetlerini ve kullanıcı bilgilerini getiren endpoint
@router.get(
    "/{user_id}",
    status_code=status.HTTP_200_OK,
    summary="Get all badges of a user with user details",
    description="Belirli bir kullanıcının sahip olduğu tüm rozetler ve kullanıcı bilgilerini getirir"
)
def get_user_badges(
    user_id: int,
    db: Session = Depends(get_db)
):
    try:
        user_badges_info = get_user_badges_by_user_id(db, user_id)
        return user_badges_info
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )

@router.post(
    "",
    response_model=UserBadgeRead,
    status_code=status.HTTP_201_CREATED,
    summary="Assign a badge to a user",
    description="Bir kullanıcıya rozet atar"
)
def assign_badge_to_user(
    badge_in: UserBadgeCreate,  # Badge bilgileri
    current_user=Depends(get_current_user),  # Kullanıcıyı almak için
    db: Session = Depends(get_db)
):
    try:
        user_badge = create_user_badge(db, current_user.id, badge_in)  # create_user_badge fonksiyonuna user_id'yi ileteceğiz
        return user_badge
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )
        
  