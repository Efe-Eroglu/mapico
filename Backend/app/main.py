# app/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.core.config import settings
from app.db.session import engine, get_db
from app.db.base import Base

from app.models.user import User
from app.models.avatar import Avatar
from app.models.user_avatar import UserAvatar
from app.models.equipment import Equipment
from app.models.user_equipment import UserEquipment
from app.models.flight import Flight
from app.models.flight_stop import FlightStop
from app.models.task import Task
from app.models.user_task import UserTask
from app.models.asset import Asset
from app.models.passport_stamp import PassportStamp
from app.models.badge import Badge
from app.models.user_badge import UserBadge
from app.models.reminder import Reminder
from app.models.parent_setting import ParentSetting
from app.models.diary_entry import DiaryEntry
from app.models.game import Game
from app.models.game_session import GameSession
from app.models.leaderboard import Leaderboard
from app.models.session_badge import SessionBadge

from app.routers.auth import router as auth_router
from app.routers.encryption import router as encryption_router
from app.routers.avatar import router as avatar_router
from app.routers.equipment import router as equipment_router 
from app.routers.user_avatar import router as user_avatar_router    
from app.routers.user_equipment import router as user_equipment_router
from app.routers.flight import router as flight_router
from app.routers.flight_stop import router as flight_stop_router
from app.routers.game import router as game_router
from app.routers.game_session import router as game_session_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Mapico Backend",
    version="0.1.0",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs"
)

# All Routers
app.include_router(auth_router)
app.include_router(encryption_router)
app.include_router(avatar_router)
app.include_router(equipment_router)
app.include_router(user_avatar_router)
app.include_router(user_equipment_router)
app.include_router(flight_router)
app.include_router(flight_stop_router)
app.include_router(game_router)
app.include_router(game_session_router)


@app.get("/api/v1/health", tags=["Health"])
def health_check(db: Session = Depends(get_db)):
    """
    Hem API’nin, hem de PostgreSQL bağlantısının
    SELECT 1 sorgusuyla çalıştığını doğrular.
    """
    try:
        db.execute(text("SELECT 1"))
    except Exception as e:
        print("DB bağlantı hatası:", e)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection error"
        )
    return {"status": "ok"}
