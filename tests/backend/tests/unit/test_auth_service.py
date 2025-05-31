import pytest
from datetime import date
from sqlalchemy.orm import Session

from app.schemas.user import UserCreate
from app.services.auth import (
    create_user, 
    authenticate_user, 
    create_access_token, 
    get_password_hash, 
    verify_password
)

def test_password_hash_and_verify():
    """
    Şifre hashleme ve doğrulama işlevlerini test eder
    """
    password = "test_password"
    hashed = get_password_hash(password)
    
    # Hash farklı olmalı
    assert hashed != password
    
    # Doğrulama başarılı olmalı
    assert verify_password(password, hashed) == True
    
    # Yanlış şifre doğrulanmamalı
    assert verify_password("wrong_password", hashed) == False

def test_create_user(test_db: Session):
    """
    Kullanıcı oluşturma işlevini test eder
    """
    user_data = UserCreate(
        email="testcreate@example.com",
        password="Test1234!",
        full_name="Test Create User",
        date_of_birth=date(2000, 1, 1)
    )
    
    user = create_user(test_db, user_data)
    
    # Kullanıcı doğru şekilde oluşturuldu mu?
    assert user.email == user_data.email
    assert user.full_name == user_data.full_name
    assert user.date_of_birth == user_data.date_of_birth
    # Şifre hashlenmiş olmalı
    assert user.hashed_password != user_data.password
    
    # Veritabanından tekrar çekip kontrol edelim
    db_user = test_db.query(user.__class__).filter_by(id=user.id).first()
    assert db_user is not None
    assert db_user.email == user_data.email

def test_create_duplicate_user_raises_error(test_db: Session):
    """
    Aynı e-posta ile ikinci bir kullanıcı oluşturmanın hata vermesini test eder
    """
    user_data = UserCreate(
        email="testduplicate@example.com",
        password="Test1234!",
        full_name="Test Duplicate User",
        date_of_birth=date(2000, 1, 1)
    )
    
    # İlk kullanıcıyı oluştur
    create_user(test_db, user_data)
    
    # Aynı e-posta ile ikinci bir kullanıcı oluşturmak hata vermeli
    with pytest.raises(ValueError):
        create_user(test_db, user_data)

def test_authenticate_user(test_db: Session):
    """
    Kullanıcı kimlik doğrulama işlevini test eder
    """
    user_data = UserCreate(
        email="testauth@example.com",
        password="Test1234!",
        full_name="Test Auth User",
        date_of_birth=date(2000, 1, 1)
    )
    
    # Kullanıcı oluştur
    create_user(test_db, user_data)
    
    # Doğru kimlik bilgileriyle doğrulama
    authenticated_user = authenticate_user(test_db, user_data.email, user_data.password)
    assert authenticated_user is not None
    assert authenticated_user.email == user_data.email
    
    # Yanlış şifreyle doğrulama
    wrong_auth_user = authenticate_user(test_db, user_data.email, "wrong_password")
    assert wrong_auth_user is None
    
    # Var olmayan kullanıcıyla doğrulama
    nonexistent_user = authenticate_user(test_db, "nonexistent@example.com", user_data.password)
    assert nonexistent_user is None

def test_create_access_token():
    """
    JWT oluşturma işlevini test eder
    """
    data = {"sub": "test@example.com"}
    token = create_access_token(data)
    
    # Token bir string olmalı
    assert isinstance(token, str)
    # Token boş olmamalı
    assert token
    # JWT formatını kontrol etmek için noktaları sayalım (header.payload.signature)
    assert token.count('.') == 2 