# app/routers/user_avatar.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.schemas.user_avatar import UserAvatarAssign, UserAvatarRead
from app.services.user_avatar import assign_avatar
from app.db.session import get_db
from app.services.auth import get_current_user

router = APIRouter(prefix="/api/v1/users/me", tags=["UserAvatar"])

@router.post(
    "/avatar",
    response_model=UserAvatarRead,
    status_code=status.HTTP_200_OK,
    summary="Assign or update current user's avatar"
)
def set_my_avatar(
    body: UserAvatarAssign,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        ua = assign_avatar(db, current_user.id, body.avatar_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    return ua
