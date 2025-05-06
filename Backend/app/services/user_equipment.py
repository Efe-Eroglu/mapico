# Backend/app/services/user_equipment.py
from app.models.user_equipment import UserEquipment
from app.schemas.user_equipment import UserEquipmentCreate
from app.core.encryption import encryption_service
from typing import List
from sqlalchemy.orm import Session, joinedload

def create_user_equipment(
    db: Session,
    user_id: int,
    ue_in: UserEquipmentCreate
) -> UserEquipment:
    encrypted_eq_id = encryption_service.encrypt(str(ue_in.equipment_id))

    new_ue = UserEquipment(
        user_id=user_id,
        equipment_id=ue_in.equipment_id
    )
    db.add(new_ue)
    db.commit()
    db.refresh(new_ue)
    return new_ue


def delete_user_equipment(
    db: Session,
    user_id: int,
    ue_id: int
) -> None:
    """
    - user_id ve user_equipment_id eşleşen kaydı bulur,
    - yoksa Exception fırlatır,
    - varsa siler ve commit eder.
    """
    ue: UserEquipment = (
        db.query(UserEquipment)
          .filter(
              UserEquipment.id == ue_id,
              UserEquipment.user_id == user_id
          )
          .first()
    )
    if not ue:
        raise Exception("Kayıt bulunamadı veya bu kullanıcıya ait değil")
    db.delete(ue)
    db.commit()

    
    
def get_user_equipments(
    db: Session,
    user_id: int
) -> List[UserEquipment]:
    # equipment ilişkisini eager-load edelim
    ues = (
        db.query(UserEquipment)
          .filter(UserEquipment.user_id == user_id)
          .options(joinedload(UserEquipment.equipment))
          .order_by(UserEquipment.selected_at.desc())
          .all()
    )

    # decrypt edilmiş equipment alanları
    for ue in ues:
        eq = ue.equipment
        try:
            eq.name = encryption_service.decrypt(eq.name)
        except Exception:
            pass
        if eq.description is not None:
            try:
                eq.description = encryption_service.decrypt(eq.description)
            except Exception:
                pass

    return ues