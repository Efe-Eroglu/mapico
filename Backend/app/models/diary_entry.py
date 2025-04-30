from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class DiaryEntry(Base):
    __tablename__ = "diary_entries"

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
    title = Column(
        String(200),
        nullable=False,
        comment="Günlük başlığı"
    )
    content = Column(
        Text,
        nullable=False,
        comment="Günlük içeriği"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Oluşturulma zamanı"
    )

    # İlişki
    user = relationship("User", back_populates="diary_entries")
