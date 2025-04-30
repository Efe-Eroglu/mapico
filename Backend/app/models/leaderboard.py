# app/models/leaderboard.py

from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class Leaderboard(Base):
    __tablename__ = "leaderboards"

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
    best_score = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Oyun için en yüksek puan"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
        comment="En son güncellenme zamanı"
    )

    # İlişkiler
    game = relationship("Game", back_populates="leaderboards")
    user = relationship("User", back_populates="leaderboards")
