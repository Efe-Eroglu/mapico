import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session
from datetime import date

from app.schemas.user_avatar import UserAvatarCreate, UserAvatarUpdate
from app.services.user_avatar import (
    create_user_avatar, 
    get_user_avatar_by_id, 
    get_user_avatars_by_user_id,
    update_user_avatar,
    delete_user_avatar
)
from app.models.user import User
from app.models.avatar import Avatar
from app.models.user_avatar import UserAvatar
from app.schemas.avatar import AvatarCreate
from app.services.avatar import create_avatar
from app.services.user import create_user
from app.core.security import get_password_hash
from app.schemas.user import UserCreate

def test_create_user_avatar(test_db: Session, test_user: User):
    """
    Kullanıcı avatar oluşturma işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="test_user_avatar",
        image_url="http://example.com/avatar.png",
        description="Test avatar description"
    )
    avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Kullanıcı avatar oluştur
    user_avatar_data = UserAvatarCreate(
        user_id=test_user.id,
        avatar_id=avatar.id,
        is_active=True
    )
    
    user_avatar = create_user_avatar(test_db, user_avatar_data)
    
    # Kullanıcı avatar doğru şekilde oluşturuldu mu?
    assert user_avatar.user_id == user_avatar_data.user_id
    assert user_avatar.avatar_id == user_avatar_data.avatar_id
    assert user_avatar.is_active == user_avatar_data.is_active
    
    # Veritabanından çekip kontrol edelim
    db_user_avatar = get_user_avatar_by_id(test_db, user_avatar.id)
    assert db_user_avatar is not None
    assert db_user_avatar.user_id == user_avatar_data.user_id
    assert db_user_avatar.avatar_id == user_avatar_data.avatar_id

def test_get_user_avatar_by_id(test_db: Session, test_user: User):
    """
    ID ile kullanıcı avatar getirme işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="get_user_avatar_test",
        image_url="http://example.com/get_avatar.png",
        description="Test user avatar retrieval"
    )
    avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Kullanıcı avatar oluştur
    user_avatar_data = UserAvatarCreate(
        user_id=test_user.id,
        avatar_id=avatar.id,
        is_active=True
    )
    
    created_user_avatar = create_user_avatar(test_db, user_avatar_data)
    
    # ID ile kullanıcı avatarı getir
    user_avatar = get_user_avatar_by_id(test_db, created_user_avatar.id)
    
    # Doğru kullanıcı avatar getirildi mi?
    assert user_avatar.id == created_user_avatar.id
    assert user_avatar.user_id == user_avatar_data.user_id
    assert user_avatar.avatar_id == user_avatar_data.avatar_id
    assert user_avatar.is_active == user_avatar_data.is_active

def test_get_user_avatar_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile kullanıcı avatar getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_user_avatar_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail.lower()

def test_get_user_avatars_by_user_id(test_db: Session, test_user: User):
    """
    Kullanıcı ID'sine göre kullanıcı avatarlarını getirme işlevini test eder
    """
    # Yeni bir test kullanıcısı oluştur
    test_user2 = create_user(
        test_db,
        UserCreate(
            email="test2@example.com",
            password="password123",
            full_name="Test User 2",
            date_of_birth=date(2000, 1, 1)
        )
    )
    
    # Önce kullanıcı avatarlarını temizle
    test_db.query(UserAvatar).filter(UserAvatar.user_id == test_user.id).delete()
    test_db.query(UserAvatar).filter(UserAvatar.user_id == test_user2.id).delete()
    test_db.commit()
    
    # İki farklı avatar oluştur
    avatar_data1 = AvatarCreate(
        name="user_avatar1",
        image_url="http://example.com/avatar1.png",
        description="First test user avatar"
    )
    
    avatar_data2 = AvatarCreate(
        name="user_avatar2",
        image_url="http://example.com/avatar2.png",
        description="Second test user avatar"
    )
    
    avatar1 = create_avatar(test_db, avatar_data1, test_user.id)
    avatar2 = create_avatar(test_db, avatar_data2, test_user.id)
    
    # İki farklı kullanıcı için avatar oluştur
    user_avatar_data1 = UserAvatarCreate(
        user_id=test_user.id,
        avatar_id=avatar1.id,
        is_active=True
    )
    
    user_avatar_data2 = UserAvatarCreate(
        user_id=test_user2.id,
        avatar_id=avatar2.id,
        is_active=False
    )
    
    create_user_avatar(test_db, user_avatar_data1)
    create_user_avatar(test_db, user_avatar_data2)
    
    # Birinci kullanıcının avatarlarını getir
    user_avatars = get_user_avatars_by_user_id(test_db, test_user.id)
    
    # Kullanıcının bir avatarı olmalı
    assert len(user_avatars) == 1
    
    # Oluşturduğumuz avatar listede olmalı
    avatar_ids = [ua.avatar_id for ua in user_avatars]
    assert avatar1.id in avatar_ids
    assert avatar2.id not in avatar_ids  # Bu başka kullanıcıya ait olmalı

def test_update_user_avatar(test_db: Session, test_user: User):
    """
    Kullanıcı avatar güncelleme işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="update_user_avatar_test",
        image_url="http://example.com/update_avatar.png",
        description="Test user avatar update"
    )
    avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Kullanıcı avatar oluştur
    user_avatar_data = UserAvatarCreate(
        user_id=test_user.id,
        avatar_id=avatar.id,
        is_active=False
    )
    
    created_user_avatar = create_user_avatar(test_db, user_avatar_data)
    
    # Kullanıcı avatarı güncelle
    update_data = UserAvatarUpdate(is_active=True)
    updated_user_avatar = update_user_avatar(test_db, created_user_avatar.id, update_data)
    
    # Güncelleme başarılı mı?
    assert updated_user_avatar.is_active == True
    
    # Veritabanından çekip kontrol edelim
    db_user_avatar = get_user_avatar_by_id(test_db, created_user_avatar.id)
    assert db_user_avatar.is_active == True

def test_delete_user_avatar(test_db: Session, test_user: User):
    """
    Kullanıcı avatar silme işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="delete_user_avatar_test",
        image_url="http://example.com/delete_avatar.png",
        description="Test user avatar deletion"
    )
    avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Kullanıcı avatar oluştur
    user_avatar_data = UserAvatarCreate(
        user_id=test_user.id,
        avatar_id=avatar.id,
        is_active=True
    )
    
    created_user_avatar = create_user_avatar(test_db, user_avatar_data)
    user_avatar_id = created_user_avatar.id
    
    # Kullanıcı avatarı sil
    delete_user_avatar(test_db, user_avatar_id)
    
    # Silme başarılı mı?
    with pytest.raises(HTTPException) as excinfo:
        get_user_avatar_by_id(test_db, user_avatar_id)
    
    assert excinfo.value.status_code == 404 