from sqlalchemy import Column, Integer, String, JSON
from app.db.base import Base

class Badge(Base):
    __tablename__ = "badges"

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
        comment="Rozet adı, örn. 'Explorer', 'Math Whiz'"
    )
    icon_url = Column(
        String(255),
        nullable=True,
        comment="Rozetin simge görsel URL’si"
    )
    criteria = Column(
        JSON,
        nullable=True,
        comment="Rozet kazanma kriterlerinin JSON formatındaki tanımı"
    )
