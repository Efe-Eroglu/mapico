# app/models/task.py

from sqlalchemy import Column, Integer, ForeignKey, String, JSON
from sqlalchemy.orm import relationship
from app.db.base import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    stop_id = Column(
        Integer,
        ForeignKey("flight_stops.id", ondelete="CASCADE"),
        nullable=False,
        comment="flight_stops tablosundaki id"
    )
    type = Column(
        String(50),
        nullable=False,
        comment="Görev tipi, örn. 'match', 'detect'"
    )
    payload = Column(
        JSON,
        nullable=True,
        comment="Göreve özel JSON verisi"
    )
    points = Column(
        Integer,
        nullable=False,
        default=0,
        comment="Tamamlandığında kazanılacak puan"
    )

    # FlightStop ↔ Task
    stop = relationship("FlightStop", back_populates="tasks")

    # ◀︎ Burayı ekleyin: Task ↔ UserTask (çift yönlü)
    user_tasks = relationship(
        "UserTask",
        back_populates="task",
        cascade="all, delete-orphan"
    )
