# app/db/session.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

# 1. Engine: veritabanına gerçek bağlantıyı sağlar
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,      # bağlantı koparsa yeniden oluşturmayı dener
    future=True              # SQLAlchemy 2.0 tarzı kullanıma izin verir
)

# 2. Oturum Fabrikası: her istek/işlem için Session nesnesi üretir
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    future=True
)
