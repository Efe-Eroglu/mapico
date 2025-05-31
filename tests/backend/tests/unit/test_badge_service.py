import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas.badge import BadgeCreate, BadgeUpdate
from app.services.badge import (
    create_badge, 
    get_badge_by_id, 
    update_badge,
    delete_badge,
    assign_badge_to_user,
    get_user_badges
)
from app.models.user import User
from app.models.badge import Badge
from app.models.user_badge import UserBadge

def test_create_badge(test_db: Session, test_user: User):
    """
    Rozet oluşturma işlevini test eder
    """
    badge_data = BadgeCreate(
        name="test_badge",
        icon_url="http://example.com/badge.png",
        description="Test badge description",
        criteria="Test criteria for earning this badge"
    )
    
    badge = create_badge(test_db, badge_data, test_user)
    
    # Rozet doğru şekilde oluşturuldu mu?
    assert badge.name == badge_data.name
    assert badge.icon_url == str(badge_data.icon_url) if badge_data.icon_url else None
    assert badge.description == badge_data.description
    assert badge.criteria == badge_data.criteria
    assert badge.creator_id == test_user.id
    
    # Veritabanından çekip kontrol edelim
    db_badge = get_badge_by_id(test_db, badge.id)
    assert db_badge is not None
    assert db_badge.name == badge_data.name
    assert db_badge.icon_url == str(badge_data.icon_url) if badge_data.icon_url else None
    assert db_badge.description == badge_data.description

def test_get_badge_by_id(test_db: Session, test_user: User):
    """
    ID ile rozet getirme işlevini test eder
    """
    # Önce bir rozet oluştur
    badge_data = BadgeCreate(
        name="get_badge_test",
        icon_url="http://example.com/get_badge.png",
        description="Test badge retrieval",
        criteria="Test criteria for this badge"
    )
    
    created_badge = create_badge(test_db, badge_data, test_user)
    
    # ID ile rozeti getir
    badge = get_badge_by_id(test_db, created_badge.id)
    
    # Doğru rozet getirildi mi?
    assert badge.id == created_badge.id
    assert badge.name == badge_data.name
    assert badge.icon_url == str(badge_data.icon_url) if badge_data.icon_url else None
    assert badge.description == badge_data.description
    assert badge.criteria == badge_data.criteria

def test_get_badge_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile rozet getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_badge_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail.lower()

def test_update_badge(test_db: Session, test_user: User):
    """
    Rozet güncelleme işlevini test eder
    """
    # Önce bir rozet oluştur
    badge_data = BadgeCreate(
        name="update_badge_test",
        icon_url="http://example.com/update_badge.png",
        description="Original description",
        criteria="Original criteria"
    )
    
    created_badge = create_badge(test_db, badge_data, test_user)
    
    # Rozeti güncelle
    update_data = BadgeUpdate(
        description="Updated description",
        criteria="Updated criteria"
    )
    
    updated_badge = update_badge(test_db, created_badge.id, update_data, test_user)
    
    # Rozet doğru şekilde güncellendi mi?
    assert updated_badge.name == badge_data.name  # Değişmemeli
    assert updated_badge.icon_url == str(badge_data.icon_url) if badge_data.icon_url else None  # Değişmemeli
    assert updated_badge.description == update_data.description  # Güncellenmiş olmalı
    assert updated_badge.criteria == update_data.criteria  # Güncellenmiş olmalı
    
    # Veritabanından çekip kontrol edelim
    db_badge = get_badge_by_id(test_db, created_badge.id)
    assert db_badge.description == update_data.description
    assert db_badge.criteria == update_data.criteria

def test_delete_badge(test_db: Session, test_user: User):
    """
    Rozet silme işlevini test eder
    """
    # Önce bir rozet oluştur
    badge_data = BadgeCreate(
        name="delete_badge_test",
        icon_url="http://example.com/delete_badge.png",
        description="Test badge deletion",
        criteria="Test criteria for delete badge"
    )
    
    created_badge = create_badge(test_db, badge_data, test_user)
    badge_id = created_badge.id
    
    # Rozeti sil
    delete_badge(test_db, badge_id, test_user)
    
    # Rozet silindi mi kontrol et
    with pytest.raises(HTTPException) as excinfo:
        get_badge_by_id(test_db, badge_id)
    
    assert excinfo.value.status_code == 404

def test_assign_badge_to_user(test_db: Session, test_user: User):
    """
    Kullanıcıya rozet atama işlevini test eder
    """
    # Önce bir rozet oluştur
    badge_data = BadgeCreate(
        name="assign_badge_test",
        icon_url="http://example.com/assign_badge.png",
        description="Test badge assignment",
        criteria="Test criteria for assign badge"
    )
    
    badge = create_badge(test_db, badge_data, test_user)
    
    # Rozeti kullanıcıya ata
    user_badge = assign_badge_to_user(test_db, badge.id, test_user.id)
    
    # Rozet doğru şekilde atandı mı?
    assert user_badge.user_id == test_user.id
    assert user_badge.badge_id == badge.id
    
    # Kullanıcının rozetlerini getirip kontrol edelim
    user_badges = get_user_badges(test_db, test_user.id)
    assert any(ub.badge_id == badge.id for ub in user_badges)

def test_get_user_badges(test_db: Session, test_user: User):
    """
    Kullanıcının rozetlerini getirme işlevini test eder
    """
    # Önce kullanıcının rozetlerini temizle
    test_db.query(UserBadge).filter(UserBadge.user_id == test_user.id).delete()
    test_db.commit()
    
    # İki farklı rozet oluştur
    badge_data1 = BadgeCreate(
        name="user_badge1",
        icon_url="http://example.com/user_badge1.png",
        description="First test user badge",
        criteria="First test criteria"
    )
    
    badge_data2 = BadgeCreate(
        name="user_badge2",
        icon_url="http://example.com/user_badge2.png",
        description="Second test user badge",
        criteria="Second test criteria"
    )
    
    badge1 = create_badge(test_db, badge_data1, test_user)
    badge2 = create_badge(test_db, badge_data2, test_user)
    
    # Rozetleri kullanıcıya ata
    assign_badge_to_user(test_db, badge1.id, test_user.id)
    assign_badge_to_user(test_db, badge2.id, test_user.id)
    
    # Kullanıcının rozetlerini getir
    user_badges = get_user_badges(test_db, test_user.id)
    
    # Kullanıcının en az iki rozeti olmalı
    assert len(user_badges) >= 2
    
    # Oluşturduğumuz rozetler listede olmalı
    badge_ids = [ub.badge_id for ub in user_badges]
    assert badge1.id in badge_ids
    assert badge2.id in badge_ids 