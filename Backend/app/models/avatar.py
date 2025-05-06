from sqlalchemy import Column, Integer, String, Text
from app.db.base import Base

class Avatar(Base):
    __tablename__ = "avatars"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    name = Column(
        String(100),
        nullable=False,
        comment="Avatar adı, örn. 'short_hair', 'blue_eyes'"
    )
    image_url = Column(
        String(255),
        nullable=False,
        comment="S3 veya CDN üzerindeki görselin URL’si"
    )
    description = Column(
        Text,
        nullable=True,
        comment="Avatar açıklaması"
    )
