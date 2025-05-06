# app/routers/equipment.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.schemas.equipment import EquipmentRead, EquipmentCreate
from app.services.equipment import get_all_equipment, create_equipment
from app.db.session import get_db
from app.services.auth import get_current_user

router = APIRouter(
    prefix="/api/v1/equipment",
    tags=["Equipment"]
)

@router.get(
    "/",
    response_model=List[EquipmentRead],
    status_code=status.HTTP_200_OK,
    summary="List all equipment",
    description="Return all available equipment options (name, icon_url, description)"
)
def list_equipment(
    db: Session = Depends(get_db),
    _: object = Depends(get_current_user)
):
    return get_all_equipment(db)


@router.post(
    "/",
    response_model=EquipmentRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create new equipment",
    description="Add a new equipment option (with encrypted storage)"
)
def add_equipment(
    eq_in: EquipmentCreate,
    db: Session = Depends(get_db),
    _: object = Depends(get_current_user)
):
    try:
        return create_equipment(db, eq_in)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
