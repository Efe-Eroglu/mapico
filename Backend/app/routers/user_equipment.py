# Backend/app/routers/user_equipment.py
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import Any
from typing import List 
from app.schemas.user_equipment import UserEquipmentCreate, UserEquipmentRead, UserEquipmentWithDetail
from app.services.user_equipment import create_user_equipment, delete_user_equipment, get_user_equipments
from app.db.session import get_db
from app.services.auth import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/api/v1/users/me/equipment",
    tags=["UserEquipment"],
)

@router.post(
    "",
    response_model=UserEquipmentRead,
    status_code=status.HTTP_201_CREATED,
    summary="Mevcut kullanıcıya yeni ekipman ekle",
    description="Body: { equipment_id: int } — user_id token’dan alınır, selected_at otomatik atanır."
)
def add_user_equipment(
    ue_in: UserEquipmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    try:
        return create_user_equipment(db, current_user.id, ue_in)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.delete(
    "/{user_equipment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Kullanıcı ekipmanını kaldır",
    description="Path param: user_equipment_id — yalnızca kendi kayıtlarınıza müdahale edebilirsiniz."
)
def remove_user_equipment(
    user_equipment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        delete_user_equipment(db, current_user.id, user_equipment_id)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
        
@router.get(
    "",
    response_model=List[UserEquipmentWithDetail],
    status_code=status.HTTP_200_OK,
    summary="Mevcut kullanıcının ekipman detaylarını listele",
    description="Kullanıcının seçtiği ekipmanların tüm detaylarını döner."
)
def list_user_equipments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_user_equipments(db, current_user.id)