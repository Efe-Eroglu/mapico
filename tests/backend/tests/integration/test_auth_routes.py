from fastapi import status
from fastapi.testclient import TestClient

def test_register_success(client: TestClient):
    """
    Başarılı bir kullanıcı kaydını test eder
    """
    user_data = {
        "email": "newuser@example.com",
        "password": "Test1234!",
        "full_name": "New Test User",
        "date_of_birth": "2000-01-01"
    }
    
    response = client.post("/api/v1/auth/register", json=user_data)
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["full_name"] == user_data["full_name"]
    assert "id" in data
    assert "password" not in data  # Şifre yanıtta olmamalı

def test_register_duplicate_email(client: TestClient, test_user):
    """
    Var olan bir e-posta ile kayıt olmayı dener ve hatayı doğrular
    """
    user_data = {
        "email": test_user.email,  # Zaten kayıtlı olan e-posta
        "password": "AnotherPassword123!",
        "full_name": "Duplicate Email User",
        "date_of_birth": "2000-01-01"
    }
    
    response = client.post("/api/v1/auth/register", json=user_data)
    
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "detail" in response.json()

def test_login_success(client: TestClient, test_user):
    """
    Başarılı bir giriş işlemini test eder
    """
    login_data = {
        "username": test_user.email,
        "password": "Test1234!"
    }
    
    response = client.post("/api/v1/auth/login", data=login_data)
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_wrong_password(client: TestClient, test_user):
    """
    Yanlış şifreyle giriş yapmayı dener ve hatayı doğrular
    """
    login_data = {
        "username": test_user.email,
        "password": "WrongPassword123!"
    }
    
    response = client.post("/api/v1/auth/login", data=login_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
    assert "detail" in response.json()

def test_login_nonexistent_user(client: TestClient):
    """
    Var olmayan bir kullanıcıyla giriş yapmayı dener
    """
    login_data = {
        "username": "nonexistent@example.com",
        "password": "SomePassword123!"
    }
    
    response = client.post("/api/v1/auth/login", data=login_data)
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
    assert "detail" in response.json()

def test_me_endpoint(client: TestClient, auth_headers):
    """
    /me endpoint'ini test eder
    """
    response = client.get("/api/v1/auth/me", headers=auth_headers)
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "id" in data
    assert "email" in data
    assert "full_name" in data

def test_me_unauthorized(client: TestClient):
    """
    Token olmadan /me endpoint'ine erişmeyi dener
    """
    response = client.get("/api/v1/auth/me")
    
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

def test_update_me(client: TestClient, auth_headers):
    """
    Kullanıcı bilgilerini güncellemeyi test eder
    """
    update_data = {
        "full_name": "Updated Test User"
    }
    
    response = client.put("/api/v1/auth/me", json=update_data, headers=auth_headers)
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["full_name"] == update_data["full_name"]

def test_logout(client: TestClient, auth_headers):
    """
    Logout işlemini test eder
    """
    # Önce logout yap
    logout_response = client.post("/api/v1/auth/logout", headers=auth_headers)
    assert logout_response.status_code == status.HTTP_204_NO_CONTENT
    
    # Aynı token ile /me endpoint'ine erişmeyi dene
    me_response = client.get("/api/v1/auth/me", headers=auth_headers)
    assert me_response.status_code == status.HTTP_401_UNAUTHORIZED 