# app/models/game.py

from sqlalchemy import Column, Integer, String, Text, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class Game(Base):
    __tablename__ = "games"

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
        comment="Oyunun kısa adı, örn. 'math_race'"
    )
    title = Column(
        String(200),
        nullable=False,
        comment="Kullanıcıya gösterilecek oyun başlığı"
    )
    description = Column(
        Text,
        nullable=True,
        comment="Oyunun açıklaması"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Kaydın oluşturulma zamanı"
    )

    # İlişkiler
    sessions = relationship(
        "GameSession",
        back_populates="game",
        cascade="all, delete-orphan"
    )
    leaderboards = relationship(
        "Leaderboard",
        back_populates="game",
        cascade="all, delete-orphan"
    )
