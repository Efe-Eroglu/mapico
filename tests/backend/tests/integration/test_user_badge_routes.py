from fastapi import status
from fastapi.testclient import TestClient

def test_assign_badge_to_user_route(client: TestClient, auth_headers, test_user_id):
    """
    Kullanıcıya rozet atama endpoint'ini test eder
    """
    # Önce bir rozet oluştur
    badge_data = {
        "name": "test_user_badge_route",
        "icon_url": "http://example.com/user_badge_route.png",
        "description": "Test user badge assignment via API",
        "criteria": "Earn 100 points"
    }
    
    badge_response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    assert badge_response.status_code == status.HTTP_201_CREATED
    badge_id = badge_response.json()["id"]
    
    # Kullanıcıya rozet ata
    user_badge_data = {
        "badge_id": badge_id
    }
    
    response = client.post("/api/v1/user_badges", json=user_badge_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["badge_id"] == badge_id
    assert data["user_id"] == test_user_id
    assert "id" in data

def test_assign_badge_to_user_unauthorized(client: TestClient):
    """
    Kimlik doğrulama olmadan kullanıcıya rozet atamayı dener
    """
    user_badge_data = {
        "badge_id": 1  # Herhangi bir rozet ID'si
    }
    
    response = client.post("/api/v1/user_badges", json=user_badge_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_get_user_badges_route(client: TestClient, auth_headers, test_user_id):
    """
    Kullanıcının rozetlerini getirme endpoint'ini test eder
    """
    # Önce bir rozet oluştur ve kullanıcıya ata
    badge_data = {
        "name": "get_user_badges_test",
        "icon_url": "http://example.com/get_user_badges.png",
        "description": "Test getting user badges via API",
        "criteria": "Complete 10 tasks"
    }
    
    badge_response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    assert badge_response.status_code == status.HTTP_201_CREATED
    badge_id = badge_response.json()["id"]
    
    # Kullanıcıya rozet ata
    user_badge_data = {
        "badge_id": badge_id
    }
    
    client.post("/api/v1/user_badges", json=user_badge_data, headers=auth_headers)
    
    # Kullanıcının rozetlerini getir
    response = client.get(f"/api/v1/user_badges/{test_user_id}")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    
    # En az bir rozet olmalı
    assert len(data) >= 1
    
    # Atadığımız rozet kullanıcının rozetleri arasında olmalı
    badge_ids = [user_badge["badge_id"] for user_badge in data]
    assert badge_id in badge_ids

def test_get_nonexistent_user_badges(client: TestClient):
    """
    Var olmayan bir kullanıcının rozetlerini getirmeyi dener
    """
    response = client.get("/api/v1/user_badges/9999")  # Var olmayan kullanıcı ID'si
    
    # Kullanıcı olmadığında boş liste döndürebilir veya hata döndürebilir
    if response.status_code == status.HTTP_200_OK:
        assert response.json() == []
    else:
        assert response.status_code == status.HTTP_404_NOT_FOUND 