import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas.avatar import AvatarCreate, AvatarUpdate
from app.services.avatar import create_avatar, get_avatar_by_id, delete_avatar, get_all_avatars
from app.models.user import User
from app.models.avatar import Avatar
from datetime import date

def test_create_avatar(test_db: Session, test_user: User):
    """
    Avatar oluşturma işlevini test eder
    """
    avatar_data = AvatarCreate(
        name="test_avatar",
        image_url="http://example.com/avatar.png",
        description="Test avatar description"
    )
    
    avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Avatar doğru şekilde oluşturuldu mu?
    assert avatar.name == avatar_data.name
    assert avatar.image_url == str(avatar_data.image_url)
    assert avatar.description == avatar_data.description
    assert avatar.creator_id == test_user.id
    
    # Veritabanından çekip kontrol edelim
    db_avatar = get_avatar_by_id(test_db, avatar.id)
    assert db_avatar is not None
    assert db_avatar.name == avatar_data.name
    assert db_avatar.image_url == str(avatar_data.image_url)
    assert db_avatar.description == avatar_data.description

def test_get_avatar_by_id(test_db: Session, test_user: User):
    """
    ID ile avatar getirme işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="get_avatar_test",
        image_url="http://example.com/get_avatar.png",
        description="Test avatar retrieval"
    )
    
    created_avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # ID ile avatarı getir
    avatar = get_avatar_by_id(test_db, created_avatar.id)
    
    # Doğru avatar getirildi mi?
    assert avatar.id == created_avatar.id
    assert avatar.name == avatar_data.name
    assert avatar.image_url == str(avatar_data.image_url)
    assert avatar.description == avatar_data.description

def test_get_avatar_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile avatar getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_avatar_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail.lower()

def test_delete_avatar(test_db: Session, test_user: User):
    """
    Avatar silme işlevini test eder
    """
    # Önce bir avatar oluştur
    avatar_data = AvatarCreate(
        name="delete_avatar_test",
        image_url="http://example.com/delete_avatar.png",
        description="Test avatar deletion"
    )
    
    created_avatar = create_avatar(test_db, avatar_data, test_user.id)
    
    # Avatarı sil
    delete_avatar(test_db, created_avatar.id, test_user)
    
    # Avatar silindi mi kontrol et
    with pytest.raises(HTTPException) as excinfo:
        get_avatar_by_id(test_db, created_avatar.id)
    
    assert excinfo.value.status_code == 404

def test_get_all_avatars(test_db: Session, test_user: User):
    """
    Tüm avatarları getirme işlevini test eder
    """
    # Önce avatarları temizle
    test_db.query(Avatar).delete()
    test_db.commit()
    
    # Birkaç avatar oluştur
    avatar_data1 = AvatarCreate(
        name="avatar1",
        image_url="http://example.com/avatar1.png",
        description="First test avatar"
    )
    
    avatar_data2 = AvatarCreate(
        name="avatar2",
        image_url="http://example.com/avatar2.png",
        description="Second test avatar"
    )
    
    create_avatar(test_db, avatar_data1, test_user.id)
    create_avatar(test_db, avatar_data2, test_user.id)
    
    # Tüm avatarları getir
    avatars = get_all_avatars(test_db)
    
    # En az iki avatar olmalı
    assert len(avatars) >= 2
    
    # Oluşturduğumuz avatarlar listede olmalı (name alanına göre kontrol et)
    assert any(a.name == "avatar1" for a in avatars)
    assert any(a.name == "avatar2" for a in avatars) 