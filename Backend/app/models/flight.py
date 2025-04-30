from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship
from app.db.base import Base

class Flight(Base):
    __tablename__ = "flights"

    id = Column(Integer, primary_key=True, index=True, comment="PK")
    title = Column(String(100), nullable=False, unique=True, comment="Rota adı")
    description = Column(Text, nullable=True, comment="Rota açıklaması")

    # Flight ↔ FlightStop
    stops = relationship("FlightStop", back_populates="flight", cascade="all, delete-orphan")
