from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class UserBadge(Base):
    __tablename__ = "user_badges"

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
        comment="Rozetin kullanıcıya verildiği zaman"
    )

    # İlişkiler
    user = relationship("User", back_populates="badges")
    badge = relationship("Badge", back_populates="users")
