# app/models/parent_setting.py

from sqlalchemy import Column, Integer, ForeignKey, JSON, UniqueConstraint
from sqlalchemy.orm import relationship
from app.db.base import Base

class ParentSetting(Base):
    __tablename__ = "parent_settings"
    __table_args__ = (
        UniqueConstraint("parent_id", "child_id", name="uq_parent_child"),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    parent_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Ebeveyn kullanıcı ID"
    )
    child_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="Çocuk kullanıcı ID"
    )
    settings_json = Column(
        JSON,
        nullable=False,
        comment="Ebeveyn kontrol ayarlarının JSON verisi"
    )

    # İlişkiler
    parent = relationship(
        "User",
        back_populates="parent_settings",
        foreign_keys=[parent_id]
    )
    child = relationship(
        "User",
        back_populates="children_settings",
        foreign_keys=[child_id]
    )
