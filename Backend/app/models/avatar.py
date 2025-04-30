from sqlalchemy import Column, Integer, String
from app.db.base import Base

class Avatar(Base):
    __tablename__ = "avatars"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
        comment="Birincil anahtar"
    )
    category = Column(
        String(50),
        nullable=False,
        comment="Örn. 'hair', 'eyes', 'clothes', 'accessory'"
    )
    name = Column(
        String(100),
        nullable=False,
        comment="Parça adı, örn. 'short_hair', 'blue_eyes'"
    )
    image_url = Column(
        String(255),
        nullable=False,
        comment="S3 veya CDN üzerindeki görselin URL’si"
    )
