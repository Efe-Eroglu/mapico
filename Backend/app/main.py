# main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.core.config import settings
from app.db.session import SessionLocal, engine
from app.db.base import Base

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Mapico Backend",
    version="0.1.0",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs"
)

def get_db():
    """
    Her request için yeni bir DB oturumu (Session) açar, iş bitince kapatır.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/api/v1/health")
def health_check(db: Session = Depends(get_db)):
    try:
        # text() ile sarıyoruz
        db.execute(text("SELECT 1"))
    except Exception as e:
        print("DB bağlantı hatası:", e)
        raise HTTPException(503, "Database connection error")
    return {"status": "ok"}


