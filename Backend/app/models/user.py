from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, Date, func
)
from sqlalchemy.orm import relationship
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, comment="PK")
    email = Column(String(255), unique=True, nullable=False, index=True, comment="E-posta")
    full_name = Column(String(255), nullable=True, comment="Ad Soyad")
    date_of_birth = Column(Date, nullable=True, comment="Doğum tarihi")
    hashed_password = Column(String(255), nullable=False, comment="Hash’lenmiş şifre")
    is_active = Column(Boolean, default=True, nullable=False, comment="Aktif mi?")
    is_superuser = Column(Boolean, default=False, nullable=False, comment="Admin mi?")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, comment="Oluşturma")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(),
                        onupdate=func.now(), nullable=False, comment="Güncelleme")

    # Avatar ↔ UserAvatar
    avatars = relationship("UserAvatar", back_populates="user", cascade="all, delete-orphan")
    # Equipment ↔ UserEquipment
    equipment = relationship("UserEquipment", back_populates="user", cascade="all, delete-orphan")
    # Task ↔ UserTask
    tasks = relationship("UserTask", back_populates="user", cascade="all, delete-orphan")
    # PassportStamp ↔ FlightStop
    passport_stamps = relationship("PassportStamp", back_populates="user", cascade="all, delete-orphan")
    # Badge ↔ UserBadge
    badges = relationship("UserBadge", back_populates="user", cascade="all, delete-orphan")
    # Reminder ↔ User
    reminders = relationship("Reminder", back_populates="user", cascade="all, delete-orphan")
    # ParentSetting (ebeveyn—çocuk)
    parent_settings = relationship(
        "ParentSetting",
        back_populates="parent",
        cascade="all, delete-orphan",
        foreign_keys="[ParentSetting.parent_id]"
    )
    children_settings = relationship(
        "ParentSetting",
        back_populates="child",
        cascade="all, delete-orphan",
        foreign_keys="[ParentSetting.child_id]"
    )
    # DiaryEntry ↔ User
    diary_entries = relationship("DiaryEntry", back_populates="user", cascade="all, delete-orphan")
    # GameSession ↔ User
    game_sessions = relationship("GameSession", back_populates="user", cascade="all, delete-orphan")
    # Leaderboard ↔ User
    leaderboards = relationship("Leaderboard", back_populates="user", cascade="all, delete-orphan")
    # SessionBadge ↔ GameSession
    session_badges = relationship("SessionBadge", back_populates="badge", cascade="all, delete-orphan")
