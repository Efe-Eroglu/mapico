from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base import Base

class FlightStop(Base):
    __tablename__ = "flight_stops"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    flight_id = Column(
        Integer,
        ForeignKey("flights.id", ondelete="CASCADE"),
        nullable=False,
        comment="flights tablosundaki ID"
    )
    name = Column(
        String(100),
        nullable=False,
        comment="Durak adı, örn. ülke/şehir"
    )
    order = Column(
        Integer,
        nullable=False,
        comment="Rotadaki sıralama"
    )
    reward_badge = Column(
        Integer,
        nullable=True,
        comment="Ödül rozet ID (badges tablosuna referans)"
    )

    # Flight ↔ FlightStop
    flight = relationship(
        "Flight",
        back_populates="stops"
    )

    # ◀︎ Task ↔ FlightStop
    tasks = relationship(
        "Task",
        back_populates="stop",
        cascade="all, delete-orphan"
    )
