from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class PassportStamp(Base):
    __tablename__ = "passport_stamps"

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
    stop_id = Column(
        Integer,
        ForeignKey("flight_stops.id", ondelete="CASCADE"),
        nullable=False,
        comment="flight_stops tablosundaki id"
    )
    stamped_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Damganın eklendiği zaman"
    )

    # İlişkiler
    user = relationship("User", back_populates="passport_stamps")
    stop = relationship("FlightStop", back_populates="passport_stamps")
