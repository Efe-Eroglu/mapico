# app/models/session_badge.py

from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class SessionBadge(Base):
    __tablename__ = "session_badges"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    session_id = Column(
        Integer,
        ForeignKey("game_sessions.id", ondelete="CASCADE"),
        nullable=False,
        comment="game_sessions tablosundaki id"
    )
    badge_id = Column(
        Integer,
        ForeignKey("badges.id", ondelete="CASCADE"),
        nullable=False,
        comment="badges tablosundaki id"
    )
    awarded_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Rozetin bu oturumda kazanıldığı zaman"
    )

    # İlişkiler
    session = relationship("GameSession", back_populates="session_badges")
    badge = relationship("Badge")
