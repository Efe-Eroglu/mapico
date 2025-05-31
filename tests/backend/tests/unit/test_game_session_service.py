import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.schemas.game_session import GameSessionCreate
from app.services.game_session import (
    create_game_session, 
    get_game_session_by_id,
    get_user_game_sessions,
    end_game_session
)
from app.models.user import User
from app.models.game import Game
from app.models.game_session import GameSession
from app.schemas.game import GameCreate
from app.services.game import create_game

def test_create_game_session(test_db: Session, test_user: User):
    """
    Oyun oturumu oluşturma işlevini test eder
    """
    # Önce bir oyun oluştur
    game_data = GameCreate(
        name="test_game_session",
        title="Test Game Session",
        description="Test game session creation"
    )
    game = create_game(test_db, game_data, test_user)
    
    # Oyun oturumu oluştur
    game_session_data = GameSessionCreate(
        user_id=test_user.id,
        game_id=game.id,
        started_at=datetime.now(),
        score=0
    )
    
    game_session = create_game_session(test_db, game_session_data)
    
    # Oyun oturumu doğru şekilde oluşturuldu mu?
    assert game_session.user_id == game_session_data.user_id
    assert game_session.game_id == game_session_data.game_id
    assert game_session.started_at is not None
    assert game_session.ended_at is None  # Henüz bitmemiş olmalı
    assert game_session.score == 0
    
    # Veritabanından çekip kontrol edelim
    db_game_session = get_game_session_by_id(test_db, game_session.id)
    assert db_game_session is not None
    assert db_game_session.user_id == game_session_data.user_id
    assert db_game_session.game_id == game_session_data.game_id

def test_get_game_session_by_id(test_db: Session, test_user: User):
    """
    ID ile oyun oturumu getirme işlevini test eder
    """
    # Önce bir oyun oluştur
    game_data = GameCreate(
        name="get_game_session_test",
        title="Get Game Session Test",
        description="Test game session retrieval"
    )
    game = create_game(test_db, game_data, test_user)
    
    # Oyun oturumu oluştur
    game_session_data = GameSessionCreate(
        user_id=test_user.id,
        game_id=game.id,
        started_at=datetime.now(),
        score=100
    )
    
    created_game_session = create_game_session(test_db, game_session_data)
    
    # ID ile oyun oturumunu getir
    game_session = get_game_session_by_id(test_db, created_game_session.id)
    
    # Doğru oyun oturumu getirildi mi?
    assert game_session.id == created_game_session.id
    assert game_session.user_id == game_session_data.user_id
    assert game_session.game_id == game_session_data.game_id
    assert game_session.score == game_session_data.score

def test_get_game_session_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile oyun oturumu getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_game_session_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail.lower()

def test_end_game_session(test_db: Session, test_user: User):
    """
    Oyun oturumunu sonlandırma işlevini test eder
    """
    # Önce bir oyun oluştur
    game_data = GameCreate(
        name="end_game_session_test",
        title="End Game Session Test",
        description="Test game session ending"
    )
    game = create_game(test_db, game_data, test_user)
    
    # Oyun oturumu oluştur
    game_session_data = GameSessionCreate(
        user_id=test_user.id,
        game_id=game.id,
        started_at=datetime.now() - timedelta(minutes=30),  # 30 dakika önce başlamış
        score=0
    )
    
    created_game_session = create_game_session(test_db, game_session_data)
    
    # Oyun oturumunu sonlandır
    final_score = 500
    ended_game_session = end_game_session(test_db, created_game_session.id, final_score)
    
    # Oyun oturumu doğru şekilde sonlandırıldı mı?
    assert ended_game_session.ended_at is not None
    assert ended_game_session.score == final_score
    
    # Veritabanından çekip kontrol edelim
    db_game_session = get_game_session_by_id(test_db, created_game_session.id)
    assert db_game_session.ended_at is not None
    assert db_game_session.score == final_score

def test_get_user_game_sessions(test_db: Session, test_user: User):
    """
    Kullanıcının oyun oturumlarını getirme işlevini test eder
    """
    # Önce kullanıcının oyun oturumlarını temizle
    test_db.query(GameSession).filter(GameSession.user_id == test_user.id).delete()
    test_db.commit()
    
    # Bir oyun oluştur
    game_data = GameCreate(
        name="user_game_sessions_test",
        title="User Game Sessions Test",
        description="Test user game sessions retrieval"
    )
    game = create_game(test_db, game_data, test_user)
    
    # İki farklı oyun oturumu oluştur
    game_session_data1 = GameSessionCreate(
        user_id=test_user.id,
        game_id=game.id,
        started_at=datetime.now() - timedelta(days=1),
        score=200
    )
    
    game_session_data2 = GameSessionCreate(
        user_id=test_user.id,
        game_id=game.id,
        started_at=datetime.now() - timedelta(hours=2),
        score=300
    )
    
    session1 = create_game_session(test_db, game_session_data1)
    session2 = create_game_session(test_db, game_session_data2)
    
    # İlk oturumu sonlandır
    end_game_session(test_db, session1.id, 200)
    
    # Kullanıcının oyun oturumlarını getir
    user_game_sessions = get_user_game_sessions(test_db, test_user.id)
    
    # Kullanıcının en az iki oyun oturumu olmalı
    assert len(user_game_sessions) >= 2
    
    # Oluşturduğumuz oturumlar listede olmalı
    session_ids = [gs.id for gs in user_game_sessions]
    assert session1.id in session_ids
    assert session2.id in session_ids
    
    # Aktif ve tamamlanmış oturumlar ayrı olarak test edilebilir
    active_sessions = [gs for gs in user_game_sessions if gs.ended_at is None]
    completed_sessions = [gs for gs in user_game_sessions if gs.ended_at is not None]
    
    assert len(active_sessions) >= 1
    assert len(completed_sessions) >= 1 