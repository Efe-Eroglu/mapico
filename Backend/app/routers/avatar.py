from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.schemas.avatar import AvatarRead, AvatarCreate
from app.services.avatar import get_all_avatars, create_avatar
from app.db.session import get_db
from app.services.auth import get_current_user

router = APIRouter(
    prefix="/api/v1/avatars",
    tags=["Avatars"]
)

@router.get(
    "/",
    response_model=List[AvatarRead],
    status_code=status.HTTP_200_OK,
    summary="List all avatars",
    description="Return all available avatar options"
)
def list_avatars(
    db: Session = Depends(get_db),
    _: object = Depends(get_current_user) 
):
    return get_all_avatars(db)


@router.post(
    "/",
    response_model=AvatarRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create new avatar"
)
def add_avatar(
    avatar_in: AvatarCreate,
    db: Session = Depends(get_db),
    _: object = Depends(get_current_user)
):
    try:
        return create_avatar(db, avatar_in)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )