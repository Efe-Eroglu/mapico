from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base import Base

class Asset(Base):
    __tablename__ = "assets"

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
        comment="Varlık tipi, örn. '3d_model', 'audio', 'image'"
    )
    url = Column(
        String(255),
        nullable=False,
        comment="Varlığın S3/CDN üzerindeki erişim URL’si"
    )

    # İlişki tanımı (opsiyonel)
    stop = relationship("FlightStop", back_populates="assets")
