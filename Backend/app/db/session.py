# app/db/session.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# 1) Engine: veritabanına gerçek bağlantıyı sağlar
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    future=True
)

# 2) Oturum Fabrikası: her istek/işlem için Session nesnesi üretir
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    future=True
)

# 3) get_db dependency’si: her request için Session açıp kapatan jeneratör
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
