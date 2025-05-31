from fastapi import status
from fastapi.testclient import TestClient
from app.core.encryption import encryption_service

def test_create_game_route(client: TestClient, auth_headers):
    """
    Oyun oluşturma endpoint'ini test eder
    """
    game_data = {
        "name": "test_route_game",
        "title": "Test Route Game",
        "description": "Test game creation via API"
    }
    
    response = client.post("/api/v1/games", json=game_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["name"] == game_data["name"]
    # Şifrelenmiş alanları sadece var olup olmadığını kontrol edelim
    assert "title" in data
    assert "description" in data
    assert "id" in data
    assert "created_at" in data

def test_create_game_unauthorized(client: TestClient):
    """
    Kimlik doğrulama olmadan oyun oluşturmayı dener
    """
    game_data = {
        "name": "unauthorized_game",
        "title": "Unauthorized Game",
        "description": "Should not be created"
    }
    
    response = client.post("/api/v1/games", json=game_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_get_game_by_id_route(client: TestClient, auth_headers):
    """
    ID ile oyun getirme endpoint'ini test eder
    """
    # Önce bir oyun oluştur
    game_data = {
        "name": "get_route_game",
        "title": "Get Route Game",
        "description": "Test getting game by ID via API"
    }
    
    create_response = client.post("/api/v1/games", json=game_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    game_id = create_response.json()["id"]
    
    # ID ile oyunu getir
    get_response = client.get(f"/api/v1/games/{game_id}")
    
    assert get_response.status_code == status.HTTP_200_OK
    data = get_response.json()
    assert data["id"] == game_id
    assert data["name"] == game_data["name"]
    # Şifrelenmiş alanları sadece var olup olmadığını kontrol edelim
    assert "title" in data
    assert "description" in data

def test_get_nonexistent_game(client: TestClient):
    """
    Var olmayan bir ID ile oyun getirmeyi dener
    """
    response = client.get("/api/v1/games/9999")  # Var olmayan ID
    
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "detail" in response.json()

def test_get_all_games_route(client: TestClient, auth_headers):
    """
    Tüm oyunları getirme endpoint'ini test eder
    """
    # Önce birkaç oyun oluştur
    game_data1 = {
        "name": "all_games_test1",
        "title": "All Games Test 1",
        "description": "Test game 1 for get all endpoint"
    }
    
    game_data2 = {
        "name": "all_games_test2",
        "title": "All Games Test 2",
        "description": "Test game 2 for get all endpoint"
    }
    
    client.post("/api/v1/games", json=game_data1, headers=auth_headers)
    client.post("/api/v1/games", json=game_data2, headers=auth_headers)
    
    # Tüm oyunları getir
    response = client.get("/api/v1/games")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    
    # Oluşturduğumuz oyunlar listede olmalı
    game_names = [game["name"] for game in data]
    assert "all_games_test1" in game_names
    assert "all_games_test2" in game_names

def test_delete_game_route(client: TestClient, auth_headers):
    """
    Oyun silme endpoint'ini test eder
    """
    # Önce bir oyun oluştur
    game_data = {
        "name": "delete_route_game",
        "title": "Delete Route Game",
        "description": "Test game deletion via API"
    }
    
    create_response = client.post("/api/v1/games", json=game_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    game_id = create_response.json()["id"]
    
    # Oyunu sil
    delete_response = client.delete(f"/api/v1/games/{game_id}", headers=auth_headers)
    assert delete_response.status_code == status.HTTP_204_NO_CONTENT
    
    # Oyunun silindiğini doğrula
    get_response = client.get(f"/api/v1/games/{game_id}")
    assert get_response.status_code == status.HTTP_404_NOT_FOUND

def test_delete_game_unauthorized(client: TestClient, auth_headers):
    """
    Kimlik doğrulama olmadan oyun silmeyi dener
    """
    # Önce bir oyun oluştur
    game_data = {
        "name": "unauth_delete_game",
        "title": "Unauthorized Delete Game",
        "description": "Test unauthorized game deletion"
    }
    
    create_response = client.post("/api/v1/games", json=game_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    game_id = create_response.json()["id"]
    
    # Kimlik doğrulama olmadan silmeyi dene
    delete_response = client.delete(f"/api/v1/games/{game_id}")
    assert delete_response.status_code == status.HTTP_401_UNAUTHORIZED 