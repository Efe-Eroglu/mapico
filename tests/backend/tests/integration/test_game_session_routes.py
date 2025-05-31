from fastapi import status
from fastapi.testclient import TestClient
from datetime import datetime
from app.models.game_session import GameSession

def test_create_game_session_route(client: TestClient, auth_headers, test_game_id, test_user_id, test_db):
    """
    Oyun oturumu oluşturma endpoint'ini test eder
    """
    game_session_data = {
        "game_id": test_game_id,
        "user_id": test_user_id,
        "score": 100,
        "success": True,
        "started_at": datetime.now().isoformat()
    }
    
    response = client.post("/api/v1/game_sessions", json=game_session_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["game_id"] == game_session_data["game_id"]
    assert data["user_id"] == game_session_data["user_id"]
    assert data["score"] == game_session_data["score"]
    assert data["success"] == game_session_data["success"]
    assert "id" in data
    assert "started_at" in data

def test_create_game_session_unauthorized(client: TestClient, test_game_id, test_user_id):
    """
    Kimlik doğrulama olmadan oyun oturumu oluşturmayı dener
    """
    game_session_data = {
        "game_id": test_game_id,
        "user_id": test_user_id,
        "score": 50,
        "success": False,
        "started_at": datetime.now().isoformat()
    }
    
    response = client.post("/api/v1/game_sessions", json=game_session_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_get_all_game_sessions_route(client: TestClient, auth_headers, test_game_id, test_user_id, test_db):
    """
    Tüm oyun oturumlarını getirme endpoint'ini test eder
    """
    # Veritabanına doğrudan oyun oturumları ekleyelim
    session1 = GameSession(
        game_id=test_game_id,
        user_id=test_user_id,
        score=200,
        success=True,
        started_at=datetime.now()
    )
    
    session2 = GameSession(
        game_id=test_game_id,
        user_id=test_user_id,
        score=300,
        success=True,
        started_at=datetime.now()
    )
    
    test_db.add(session1)
    test_db.add(session2)
    test_db.commit()
    
    # Tüm oyun oturumlarını getir
    response = client.get("/api/v1/game_sessions")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 2

def test_get_user_game_sessions_route(client: TestClient, auth_headers, test_game_id, test_user_id, test_db):
    """
    Kullanıcının oyun oturumlarını getirme endpoint'ini test eder
    """
    # Veritabanına doğrudan bir oyun oturumu ekleyelim
    session = GameSession(
        game_id=test_game_id,
        user_id=test_user_id,
        score=150,
        success=True,
        started_at=datetime.now()
    )
    
    test_db.add(session)
    test_db.commit()
    
    # Kullanıcının oyun oturumlarını getir
    response = client.get(f"/api/v1/game_sessions/user/{test_user_id}")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    
    # Oluşturduğumuz oturum kullanıcının oturumları arasında olmalı
    user_sessions = [s for s in data if s["user_id"] == test_user_id]
    assert len(user_sessions) >= 1

def test_get_game_sessions_by_game_route(client: TestClient, auth_headers, test_game_id, test_user_id, test_db):
    """
    Oyuna göre oturumları getirme endpoint'ini test eder
    """
    # Veritabanına doğrudan bir oyun oturumu ekleyelim
    session = GameSession(
        game_id=test_game_id,
        user_id=test_user_id,
        score=250,
        success=True,
        started_at=datetime.now()
    )
    
    test_db.add(session)
    test_db.commit()
    
    # Oyuna göre oturumları getir
    response = client.get(f"/api/v1/game_sessions/game/{test_game_id}")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    
    # Oluşturduğumuz oturum oyunun oturumları arasında olmalı
    game_sessions = [s for s in data if s["game_id"] == test_game_id]
    assert len(game_sessions) >= 1

def test_get_filtered_game_sessions_route(client: TestClient, auth_headers, test_game_id, test_user_id, test_db):
    """
    Oyun ID'sine göre filtrelenmiş oturumları getirme endpoint'ini test eder
    """
    # Veritabanına doğrudan bir oyun oturumu ekleyelim
    session = GameSession(
        game_id=test_game_id,
        user_id=test_user_id,
        score=300,
        success=True,
        started_at=datetime.now()
    )
    
    test_db.add(session)
    test_db.commit()
    
    # Filtrelenmiş oturumları getir
    response = client.get(f"/api/v1/game_sessions/filter?game_id={test_game_id}")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    
    # Tüm oturumlar belirtilen oyuna ait olmalı
    for s in data:
        assert s["game_id"] == test_game_id 