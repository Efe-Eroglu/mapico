# app/models/game_session.py

from sqlalchemy import Column, Integer, ForeignKey, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class GameSession(Base):
    __tablename__ = "game_sessions"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    game_id = Column(
        Integer,
        ForeignKey("games.id", ondelete="CASCADE"),
        nullable=False,
        comment="games tablosundaki id"
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="users tablosundaki id"
    )
    score = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Bu oturumda kazanılan puan"
    )
    success = Column(
        Boolean,
        nullable=False,
        default=False,
        comment="Oturumun başarılı (tamamlandı) olup olmadığı"
    )
    started_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Oturum başlama zamanı"
    )
    ended_at = Column(
        DateTime(timezone=True),
        nullable=True,
        comment="Oturum bitiş zamanı"
    )

    # İlişkiler
    game = relationship("Game", back_populates="sessions")
    user = relationship("User", back_populates="game_sessions")
    session_badges = relationship(
        "SessionBadge",
        back_populates="session",
        cascade="all, delete-orphan"
    )
