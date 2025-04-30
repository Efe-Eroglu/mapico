# app/models/equipment.py

from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.db.base import Base

class Equipment(Base):
    __tablename__ = "equipment"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    name = Column(
        String(100),
        nullable=False,
        unique=True,
        comment="Ekipman adı, örn. 'dürbün', 'pusula'"
    )
    description = Column(
        String(255),
        nullable=True,
        comment="Ekipmanın kısa açıklaması"
    )
    icon_url = Column(
        String(255),
        nullable=True,
        comment="S3/CDN üzerindeki simge görselinin URL’si"
    )

    # Kullanıcının seçtiği ekipman kayıtları
    user_equipment = relationship(
        "UserEquipment",
        back_populates="equipment",
        cascade="all, delete-orphan"
    )
