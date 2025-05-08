# app/services/badge.py
from sqlalchemy.orm import Session
from app.models.badge import Badge
from app.schemas.badge import BadgeCreate, BadgeRead, BadgeUpdate
from fastapi import HTTPException, status

def create_badge(db: Session, badge_in: BadgeCreate) -> BadgeRead:
    # icon_url'yu String'e dönüştürüyoruz
    icon_url = str(badge_in.icon_url) if badge_in.icon_url else None

    # Yeni Badge oluşturuyoruz
    db_badge = Badge(
        name=badge_in.name,
        icon_url=icon_url,
        criteria=badge_in.criteria
    )

    db.add(db_badge)
    db.commit()
    db.refresh(db_badge)

    return BadgeRead(
        id=db_badge.id,
        name=db_badge.name,
        icon_url=db_badge.icon_url,
        criteria=db_badge.criteria,
        updated_at=db_badge.updated_at
    )


def get_all_badges(db: Session) -> list[BadgeRead]:
    db_badges = db.query(Badge).all()

    return [
        BadgeRead(
            id=db_badge.id,
            name=db_badge.name,
            icon_url=db_badge.icon_url,
            criteria=db_badge.criteria
        ) for db_badge in db_badges
    ]
    
def update_badge(db: Session, badge_id: int, badge_in: BadgeUpdate) -> BadgeRead:
    db_badge = db.query(Badge).filter(Badge.id == badge_id).first()

    if not db_badge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Badge not found"
        )

    if badge_in.name:
        db_badge.name = badge_in.name
    if badge_in.icon_url:
        db_badge.icon_url = badge_in.icon_url
    if badge_in.criteria is not None:
        db_badge.criteria = badge_in.criteria

    db.commit()
    db.refresh(db_badge)

    return BadgeRead(
        id=db_badge.id,
        name=db_badge.name,
        icon_url=db_badge.icon_url,
        criteria=db_badge.criteria
    )
    
def delete_badge(db: Session, badge_id: int):
    db_badge = db.query(Badge).filter(Badge.id == badge_id).first()

    if not db_badge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Badge not found"
        )

    db.delete(db_badge)
    db.commit()
    
