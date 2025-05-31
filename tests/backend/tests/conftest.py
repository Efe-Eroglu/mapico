import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import os
from datetime import datetime, date
from unittest.mock import patch, MagicMock
import sys
from pathlib import Path

# Ana dizini sys.path'e ekle (uygulama modüllerini import edebilmek için)
sys.path.insert(0, str(Path(__file__).parent.parent))

# Mock config'i import et
from tests.config_mock import settings

# app'i import etmeden önce config modülünü mock'la
sys.modules['app.core.config'] = MagicMock()
sys.modules['app.core.config'].settings = settings

# Şimdi app'i ve diğer modülleri import et
from app.db.base import Base
from app.db.session import get_db
from app.main import app
from app.schemas.user import UserCreate
from app.services.auth import create_user
from app.schemas.game import GameCreate
from app.services.game import create_game
from app.models.game import Game

# Test için SQLite bellek veritabanı
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture(scope="function")
def test_db():
    """
    Her test fonksiyonu için yeni bir SQLite bellek veritabanı oluşturur.
    Test tamamlandığında veritabanını temizler.
    """
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    # Tüm tabloları oluştur
    Base.metadata.create_all(bind=engine)
    
    # Test veritabanı oturumu
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(test_db):
    """
    FastAPI test istemcisi. Veritabanı bağımlılığını override eder.
    """
    def override_get_db():
        try:
            yield test_db
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()

@pytest.fixture(scope="function")
def test_user(test_db):
    """
    Test için kullanıcı oluşturur
    """
    user_data = UserCreate(
        email="test@example.com",
        password="Test1234!",
        full_name="Test User",
        date_of_birth=date(2000, 1, 1)
    )
    return create_user(test_db, user_data)

@pytest.fixture(scope="function")
def test_user_id(test_user):
    """
    Test kullanıcısının ID'sini döndürür
    """
    return test_user.id

@pytest.fixture(scope="function")
def test_game(test_db, test_user):
    """
    Test için oyun oluşturur
    """
    # SQLAlchemy modeli doğrudan oluşturalım
    game = Game(
        name="test_game",
        title="Test Game",
        description="Test game description",
        creator_id=test_user.id,
        is_active=True
    )
    
    test_db.add(game)
    test_db.commit()
    test_db.refresh(game)
    
    return game

@pytest.fixture(scope="function")
def test_game_id(test_game):
    """
    Test oyununun ID'sini döndürür
    """
    return test_game.id

@pytest.fixture(scope="function")
def auth_headers(client, test_user):
    """
    Kimlik doğrulama gerektiren endpoint'ler için token içeren header
    """
    login_data = {
        "username": test_user.email,
        "password": "Test1234!"
    }
    response = client.post("/api/v1/auth/login", data=login_data)
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"} 