from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class UserEquipment(Base):
    __tablename__ = "user_equipment"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="users tablosundaki id"
    )
    equipment_id = Column(
        Integer,
        ForeignKey("equipment.id", ondelete="CASCADE"),
        nullable=False,
        comment="equipment tablosundaki id"
    )
    selected_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Ekipmanın seçildiği zaman"
    )

    # İlişki tanımları (opsiyonel):
    user = relationship("User", back_populates="equipment")
    equipment = relationship("Equipment")
