from fastapi import status
from fastapi.testclient import TestClient

def test_create_avatar_route(client: TestClient, auth_headers):
    """
    Avatar oluşturma endpoint'ini test eder
    """
    avatar_data = {
        "name": "test_route_avatar",
        "image_url": "http://example.com/route_avatar.png",
        "description": "Test avatar creation via API"
    }
    
    response = client.post("/api/v1/avatars", json=avatar_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["name"] == avatar_data["name"]  # İsim şifrelenmeden dönülür
    assert data["image_url"] == avatar_data["image_url"]
    assert data["description"] == avatar_data["description"]  # Açıklama şifrelenmeden dönülür
    assert "id" in data
    assert "created_at" in data

def test_create_avatar_unauthorized(client: TestClient):
    """
    Kimlik doğrulama olmadan avatar oluşturmayı dener
    """
    avatar_data = {
        "name": "unauthorized_avatar",
        "image_url": "http://example.com/unauthorized_avatar.png",
        "description": "Should not be created"
    }
    
    response = client.post("/api/v1/avatars", json=avatar_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_get_avatar_by_id_route(client: TestClient, auth_headers):
    """
    ID ile avatar getirme endpoint'ini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = {
        "name": "get_route_avatar",
        "image_url": "http://example.com/get_route_avatar.png",
        "description": "Test getting avatar by ID via API"
    }
    
    create_response = client.post("/api/v1/avatars", json=avatar_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    avatar_id = create_response.json()["id"]
    
    # ID ile avatarı getir
    get_response = client.get(f"/api/v1/avatars/{avatar_id}")
    
    assert get_response.status_code == status.HTTP_200_OK
    data = get_response.json()
    assert data["id"] == avatar_id
    assert "name" in data
    assert "image_url" in data
    assert "description" in data

def test_get_nonexistent_avatar(client: TestClient):
    """
    Var olmayan bir ID ile avatar getirmeyi dener
    """
    response = client.get("/api/v1/avatars/9999")  # Var olmayan ID
    
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "detail" in response.json()

def test_get_all_avatars_route(client: TestClient, auth_headers):
    """
    Tüm avatarları getirme endpoint'ini test eder
    """
    # Önce birkaç avatar oluştur
    avatar_data1 = {
        "name": "all_avatars_test1",
        "image_url": "http://example.com/all_avatars1.png",
        "description": "Test avatar 1 for get all endpoint"
    }
    
    avatar_data2 = {
        "name": "all_avatars_test2",
        "image_url": "http://example.com/all_avatars2.png",
        "description": "Test avatar 2 for get all endpoint"
    }
    
    client.post("/api/v1/avatars", json=avatar_data1, headers=auth_headers)
    client.post("/api/v1/avatars", json=avatar_data2, headers=auth_headers)
    
    # Tüm avatarları getir
    response = client.get("/api/v1/avatars")
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    
    # Oluşturduğumuz avatarlar listede olmalı (doğrudan değerler yerine varlığını kontrol et)
    assert len(data) >= 2

def test_delete_avatar_route(client: TestClient, auth_headers):
    """
    Avatar silme endpoint'ini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = {
        "name": "delete_route_avatar",
        "image_url": "http://example.com/delete_route_avatar.png",
        "description": "Test avatar deletion via API"
    }
    
    create_response = client.post("/api/v1/avatars", json=avatar_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    avatar_id = create_response.json()["id"]
    
    # Avatarı sil
    delete_response = client.delete(f"/api/v1/avatars/{avatar_id}", headers=auth_headers)
    assert delete_response.status_code == status.HTTP_204_NO_CONTENT
    
    # Avatarın silindiğini doğrula
    get_response = client.get(f"/api/v1/avatars/{avatar_id}")
    assert get_response.status_code == status.HTTP_404_NOT_FOUND

def test_delete_avatar_unauthorized(client: TestClient, auth_headers):
    """
    Kimlik doğrulama olmadan avatar silmeyi dener
    """
    # Önce bir avatar oluştur
    avatar_data = {
        "name": "unauth_delete_avatar",
        "image_url": "http://example.com/unauth_delete_avatar.png",
        "description": "Test unauthorized avatar deletion"
    }
    
    create_response = client.post("/api/v1/avatars", json=avatar_data, headers=auth_headers)
    assert create_response.status_code == status.HTTP_201_CREATED
    avatar_id = create_response.json()["id"]
    
    # Kimlik doğrulama olmadan silmeyi dene
    delete_response = client.delete(f"/api/v1/avatars/{avatar_id}")
    assert delete_response.status_code == status.HTTP_401_UNAUTHORIZED 