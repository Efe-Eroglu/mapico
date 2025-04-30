from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class Reminder(Base):
    __tablename__ = "reminders"

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
    type = Column(
        String(50),
        nullable=False,
        comment="Hatırlatıcı türü, örn. 'rest_eyes', 'posture_check'"
    )
    schedule_cron = Column(
        String(100),
        nullable=False,
        comment="Cron ifadesi veya benzeri zamanlama tanımı"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Kaydın oluşturulma zamanı"
    )

    # İlişki
    user = relationship("User", back_populates="reminders")
