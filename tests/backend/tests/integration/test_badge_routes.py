from fastapi import status
from fastapi.testclient import TestClient

def test_create_badge_route(client: TestClient, auth_headers):
    """
    Rozet oluşturma endpoint'ini test eder
    """
    badge_data = {
        "name": "test_route_badge",
        "icon_url": "http://example.com/route_badge.png",
        "description": "Test badge creation via API",
        "criteria": "Earn 100 points"
    }
    
    response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["name"] == badge_data["name"]
    assert data["icon_url"] == badge_data["icon_url"]
    assert data["description"] == badge_data["description"]
    assert "id" in data

def test_create_badge_unauthorized(client: TestClient):
    """
    Kimlik doğrulama olmadan rozet oluşturmayı dener
    """
    badge_data = {
        "name": "unauthorized_badge",
        "icon_url": "http://example.com/unauthorized_badge.png",
        "description": "Should not be created",
        "criteria": "Should not be created"
    }
    
    response = client.post("/api/v1/badges", json=badge_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_get_all_badges_route(client: TestClient, auth_headers):
    """
    Tüm rozetleri getirme endpoint'ini test eder
    """
    # Önce birkaç rozet oluştur
    badge_data1 = {
        "name": "all_badges_test1",
        "icon_url": "http://example.com/all_badges1.png",
        "description": "Test badge 1 for get all endpoint",
        "criteria": "Earn 50 points"
    }
    
    badge_data2 = {
        "name": "all_badges_test2",
        "icon_url": "http://example.com/all_badges2.png",
        "description": "Test badge 2 for get all endpoint",
        "criteria": "Complete 5 tasks"
    }
    
    client.post("/api/v1/badges", json=badge_data1, headers=auth_headers)
    client.post("/api/v1/badges", json=badge_data2, headers=auth_headers)
    
    # Tüm rozetleri getir
    response = client.get("/api/v1/badges")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    
    # Oluşturduğumuz rozetler listede olmalı
    badge_names = [badge["name"] for badge in data]
    assert "all_badges_test1" in badge_names
    assert "all_badges_test2" in badge_names

def test_update_badge_route(client: TestClient, auth_headers):
    """
    Rozet güncelleme endpoint'ini test eder
    """
    # Önce bir rozet oluştur
    badge_data = {
        "name": "update_route_badge",
        "icon_url": "http://example.com/update_route_badge.png",
        "description": "Test badge update via API",
        "criteria": "Original criteria"
    }
    
    create_response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    badge_id = create_response.json()["id"]
    
    # Rozeti güncelle
    update_data = {
        "description": "Updated description",
        "criteria": "Updated criteria"
    }
    
    update_response = client.put(f"/api/v1/badges/{badge_id}", json=update_data, headers=auth_headers)
    assert update_response.status_code == status.HTTP_200_OK
    
    updated_badge = update_response.json()
    assert updated_badge["id"] == badge_id
    assert updated_badge["name"] == badge_data["name"]  # Değişmemeli
    assert updated_badge["description"] == update_data["description"]  # Güncellenmeli
    assert updated_badge["criteria"] == update_data["criteria"]  # Güncellenmeli

def test_delete_badge_route(client: TestClient, auth_headers):
    """
    Rozet silme endpoint'ini test eder
    """
    # Önce bir rozet oluştur
    badge_data = {
        "name": "delete_route_badge",
        "icon_url": "http://example.com/delete_route_badge.png",
        "description": "Test badge deletion via API",
        "criteria": "Test criteria"
    }
    
    create_response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    badge_id = create_response.json()["id"]
    
    # Rozeti sil
    delete_response = client.delete(f"/api/v1/badges/{badge_id}", headers=auth_headers)
    assert delete_response.status_code == status.HTTP_204_NO_CONTENT
    
    # Rozet silindi mi kontrol et
    get_response = client.get("/api/v1/badges")
    badge_ids = [badge["id"] for badge in get_response.json()]
    assert badge_id not in badge_ids

def test_delete_badge_unauthorized(client: TestClient, auth_headers):
    """
    Kimlik doğrulama olmadan rozet silmeyi dener
    """
    # Önce bir rozet oluştur
    badge_data = {
        "name": "unauth_delete_badge",
        "icon_url": "http://example.com/unauth_delete_badge.png",
        "description": "Test unauthorized badge deletion",
        "criteria": "Test criteria"
    }
    
    create_response = client.post("/api/v1/badges", json=badge_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    badge_id = create_response.json()["id"]
    
    # Kimlik doğrulama olmadan silmeyi dene
    delete_response = client.delete(f"/api/v1/badges/{badge_id}")
    assert delete_response.status_code == status.HTTP_401_UNAUTHORIZED 