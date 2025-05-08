# app/routers/badge.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.badge import BadgeCreate, BadgeRead, BadgeUpdate
from typing import List
from app.services.badge import create_badge, get_all_badges, update_badge, delete_badge
from app.db.session import get_db

router = APIRouter(prefix="/api/v1/badges", tags=["Badges"])

@router.post(
    "",
    response_model=BadgeRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new badge",
    description="Yeni bir rozet ekler"
)
def add_badge(
    badge_in: BadgeCreate,
    db: Session = Depends(get_db)
):
    try:
        badge = create_badge(db, badge_in)
        return badge
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )

@router.get(
    "",
    response_model=List[BadgeRead],
    status_code=status.HTTP_200_OK,
    summary="Get all badges",
    description="Tüm rozetleri getirir"
)
def get_badges(
    db: Session = Depends(get_db)
):
    try:
        badges = get_all_badges(db)
        return badges
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )


@router.put(
    "/{badge_id}",
    response_model=BadgeRead,
    status_code=status.HTTP_200_OK,
    summary="Update a badge",
    description="Bir rozetin bilgilerini günceller"
)
def update_badge_endpoint(
    badge_id: int,
    badge_in: BadgeUpdate,
    db: Session = Depends(get_db)
):
    try:
        return update_badge(db, badge_id, badge_in)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )


@router.delete(
    "/{badge_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a badge",
    description="Bir rozet siler"
)
def delete_badge_endpoint(
    badge_id: int,
    db: Session = Depends(get_db)
):
    try:
        delete_badge(db, badge_id)
        return {"detail": "Badge deleted successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Bir hata oluştu: {str(e)}"
        )
