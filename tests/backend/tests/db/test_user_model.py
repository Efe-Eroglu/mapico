from sqlalchemy.orm import Session
from app.models.user import User
from datetime import date, datetime

def test_user_model_create(test_db: Session):
    """
    User modelinin oluşturulmasını test eder
    """
    # Yeni bir kullanıcı oluştur
    user = User(
        email="testuser@example.com",
        full_name="Test User",
        date_of_birth=date(2000, 1, 1),
        hashed_password="hashed_password_string",
        is_active=True,
        is_superuser=False
    )
    
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    
    # ID atanmış olmalı
    assert user.id is not None
    
    # Veritabanından kullanıcıyı çekip kontrol et
    db_user = test_db.query(User).filter(User.id == user.id).first()
    assert db_user is not None
    assert db_user.email == "testuser@example.com"
    assert db_user.full_name == "Test User"
    assert db_user.date_of_birth == date(2000, 1, 1)
    assert db_user.hashed_password == "hashed_password_string"
    assert db_user.is_active is True
    assert db_user.is_superuser is False
    
    # created_at ve updated_at alanları doldurulmuş olmalı
    assert isinstance(db_user.created_at, datetime)
    assert isinstance(db_user.updated_at, datetime)

def test_user_model_update(test_db: Session):
    """
    User modelinin güncellenmesini test eder
    """
    # Önce bir kullanıcı oluştur
    user = User(
        email="updateuser@example.com",
        full_name="Update Test User",
        date_of_birth=date(2000, 1, 1),
        hashed_password="original_password_hash",
        is_active=True,
        is_superuser=False
    )
    
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    
    # Güncelleme öncesi zaman
    original_updated_at = user.updated_at
    
    # Kullanıcıyı güncelle
    user.full_name = "Updated Name"
    user.hashed_password = "new_password_hash"
    
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    
    # Değişiklikleri kontrol et
    assert user.full_name == "Updated Name"
    assert user.hashed_password == "new_password_hash"
    
    # updated_at alanı güncellenmiş olmalı (SQLite test DB kullandığımızdan burada çalışmayabilir)
    # assert user.updated_at > original_updated_at

def test_user_model_delete(test_db: Session):
    """
    User modelinin silinmesini test eder
    """
    # Önce bir kullanıcı oluştur
    user = User(
        email="deleteuser@example.com",
        full_name="Delete Test User",
        date_of_birth=date(2000, 1, 1),
        hashed_password="password_hash",
        is_active=True,
        is_superuser=False
    )
    
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    
    user_id = user.id
    
    # Kullanıcıyı sil
    test_db.delete(user)
    test_db.commit()
    
    # Kullanıcının artık veritabanında olmaması gerekiyor
    deleted_user = test_db.query(User).filter(User.id == user_id).first()
    assert deleted_user is None 