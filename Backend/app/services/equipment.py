from typing import List
from sqlalchemy.orm import Session

from app.models.equipment import Equipment
from app.schemas.equipment import EquipmentCreate
from app.core.encryption import encryption_service

def get_all_equipment(db: Session) -> List[Equipment]:
    items = db.query(Equipment).order_by(Equipment.id).all()
    for it in items:
        it.name = encryption_service.decrypt(it.name)
        if it.description:
            it.description = encryption_service.decrypt(it.description)
    return items

def create_equipment(db: Session, eq_in: EquipmentCreate) -> Equipment:
    """
    Yeni ekipman oluştururken:
    - name ve description alanlarını şifreler
    - icon_url düz bırakılır
    - veritabanına ekleyip commit eder
    - geri dönerken orijinal (plaintext) değerleri atar
    """
    # 1) Şifreleme
    enc_name = encryption_service.encrypt(eq_in.name)
    enc_desc = (
        encryption_service.encrypt(eq_in.description)
        if eq_in.description is not None else None
    )

    # 2) ORM nesnesi
    db_eq = Equipment(
        name=enc_name,
        description=enc_desc,
        icon_url=str(eq_in.icon_url)
    )
    db.add(db_eq)
    db.commit()
    db.refresh(db_eq)

    # 3) Response için decrypt edilmiş halleri ayarla
    db_eq.name = eq_in.name
    db_eq.description = eq_in.description
    return db_eq
