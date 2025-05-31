import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
from datetime import date
import uuid

from app.schemas.user import UserCreate, UserUpdate
from app.services.user import (
    get_user_by_id, 
    get_user_by_email, 
    create_user, 
    update_user, 
    delete_user, 
    authenticate_user
)
from app.models.user import User
from app.core.security import get_password_hash

def test_create_user(test_db: Session):
    """
    Kullanıcı oluşturma işlevini test eder
    """
    # Benzersiz bir e-posta adresi oluştur
    unique_id = str(uuid.uuid4())
    email = f"test_create_user_{unique_id}@example.com"
    
    user_data = UserCreate(
        email=email,
        password="password123",
        full_name="Test User",
        date_of_birth=date(2000, 1, 1)
    )
    
    user = create_user(test_db, user_data)
    
    # Kullanıcı doğru şekilde oluşturuldu mu?
    assert user.email == user_data.email
    assert user.full_name == user_data.full_name
    assert user.date_of_birth == user_data.date_of_birth
    
    # Şifre hash'lendi mi?
    assert user.hashed_password != user_data.password
    
    # Kullanıcı aktif mi?
    assert user.is_active == True
    
    # Superuser değil, değil mi?
    assert user.is_superuser == False

def test_create_user_with_existing_email(test_db: Session, test_user: User):
    """
    Var olan bir e-posta ile kullanıcı oluşturmayı dener ve hatayı doğrular
    """
    user_data = UserCreate(
        email=test_user.email,  # Var olan bir e-posta
        password="password123",
        full_name="Another User",
        date_of_birth=date(2000, 1, 1)
    )
    
    with pytest.raises(HTTPException) as excinfo:
        create_user(test_db, user_data)
    
    assert excinfo.value.status_code == 400
    assert "Email already registered" in excinfo.value.detail

def test_get_user_by_id(test_db: Session, test_user: User):
    """
    ID ile kullanıcı getirme işlevini test eder
    """
    user = get_user_by_id(test_db, test_user.id)
    
    # Doğru kullanıcı getirildi mi?
    assert user.id == test_user.id
    assert user.email == test_user.email
    assert user.full_name == test_user.full_name

def test_get_user_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile kullanıcı getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_user_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail.lower()

def test_get_user_by_email(test_db: Session, test_user: User):
    """
    E-posta ile kullanıcı getirme işlevini test eder
    """
    user = get_user_by_email(test_db, test_user.email)
    
    # Doğru kullanıcı getirildi mi?
    assert user is not None
    assert user.id == test_user.id
    assert user.email == test_user.email

def test_get_user_by_nonexistent_email(test_db: Session):
    """
    Var olmayan bir e-posta ile kullanıcı getirmeyi dener
    """
    user = get_user_by_email(test_db, "nonexistent@example.com")
    
    # Kullanıcı bulunamadı mı?
    assert user is None

def test_update_user(test_db: Session, test_user: User):
    """
    Kullanıcı güncelleme işlevini test eder
    """
    # Önce bir kopya oluştur
    original_hashed_password = test_user.hashed_password
    
    update_data = UserUpdate(
        full_name="Updated Test User",
        password="newpassword123"
    )
    
    updated_user = update_user(test_db, test_user.id, update_data)
    
    # Kullanıcı doğru şekilde güncellendi mi?
    assert updated_user.id == test_user.id
    assert updated_user.full_name == update_data.full_name
    
    # Şifre güncellendi mi?
    assert updated_user.hashed_password != original_hashed_password
    
    # E-posta ve diğer alanlar değişmedi mi?
    assert updated_user.email == test_user.email
    assert updated_user.date_of_birth == test_user.date_of_birth

def test_delete_user(test_db: Session):
    """
    Kullanıcı silme işlevini test eder
    """
    # Önce bir kullanıcı oluştur
    unique_id = str(uuid.uuid4())
    user_data = UserCreate(
        email=f"test_delete_user_{unique_id}@example.com",
        password="password123",
        full_name="User To Delete",
        date_of_birth=date(2000, 1, 1)
    )
    
    created_user = create_user(test_db, user_data)
    user_id = created_user.id
    
    # Kullanıcıyı sil
    delete_user(test_db, user_id)
    
    # Kullanıcı silindi mi kontrol et
    with pytest.raises(HTTPException) as excinfo:
        get_user_by_id(test_db, user_id)
    
    assert excinfo.value.status_code == 404

def test_authenticate_user(test_db: Session):
    """
    Kullanıcı kimlik doğrulama işlevini test eder
    """
    # Önce bir kullanıcı oluştur
    unique_id = str(uuid.uuid4())
    email = f"test_auth_user_{unique_id}@example.com"
    password = "password123"
    
    user_data = UserCreate(
        email=email,
        password=password,
        full_name="Auth Test User",
        date_of_birth=date(2000, 1, 1)
    )
    
    create_user(test_db, user_data)
    
    # Doğru kimlik bilgileriyle doğrulama
    authenticated_user = authenticate_user(test_db, email, password)
    assert authenticated_user is not None
    assert authenticated_user.email == email
    
    # Yanlış şifre ile doğrulama
    authenticated_user = authenticate_user(test_db, email, "wrongpassword")
    assert authenticated_user is None
    
    # Yanlış e-posta ile doğrulama
    authenticated_user = authenticate_user(test_db, "wrong@example.com", password)
    assert authenticated_user is None 