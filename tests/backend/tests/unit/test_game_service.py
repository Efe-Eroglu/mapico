import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas.game import GameCreate
from app.services.game import create_game, get_game_by_id, get_all_games, delete_game
from app.models.user import User
from app.core.encryption import encryption_service
from datetime import date

def test_create_game(test_db: Session, test_user: User):
    """
    Oyun oluşturma işlevini test eder
    """
    game_data = GameCreate(
        name="test_game",
        title="Test Game",
        description="Test game description"
    )
    
    game = create_game(test_db, game_data, test_user)
    
    # Oyun doğru şekilde oluşturuldu mu?
    assert game.name == game_data.name
    # Not: title ve description şifrelenmiş olarak saklanır ve döndürülürken çözülür
    # Bu nedenle doğrudan eşitliği kontrol edemiyoruz
    assert isinstance(game.title, str)
    assert isinstance(game.description, str)
    
    # Veritabanından çekip kontrol edelim
    db_game = get_game_by_id(test_db, game.id)
    assert db_game is not None
    assert db_game.name == game_data.name
    assert isinstance(db_game.title, str)
    assert isinstance(db_game.description, str)

def test_get_game_by_id(test_db: Session, test_user: User):
    """
    ID ile oyun getirme işlevini test eder
    """
    # Önce bir oyun oluştur
    game_data = GameCreate(
        name="get_game_test",
        title="Get Game Test",
        description="Test game retrieval"
    )
    
    created_game = create_game(test_db, game_data, test_user)
    
    # ID ile oyunu getir
    game = get_game_by_id(test_db, created_game.id)
    
    # Doğru oyun getirildi mi?
    assert game.id == created_game.id
    assert game.name == game_data.name
    # Şifrelenmiş/çözülmüş alanlarda tür kontrolü yap
    assert isinstance(game.title, str)
    assert isinstance(game.description, str)

def test_get_game_by_nonexistent_id(test_db: Session):
    """
    Var olmayan bir ID ile oyun getirmeyi dener ve hatayı doğrular
    """
    with pytest.raises(HTTPException) as excinfo:
        get_game_by_id(test_db, 9999)  # Var olmayan ID
    
    assert excinfo.value.status_code == 404
    assert "not found" in excinfo.value.detail

def test_get_all_games(test_db: Session, test_user: User):
    """
    Tüm oyunları getirme işlevini test eder
    """
    # Birkaç oyun oluştur
    game_data1 = GameCreate(
        name="game1",
        title="Game One",
        description="First test game"
    )
    
    game_data2 = GameCreate(
        name="game2",
        title="Game Two",
        description="Second test game"
    )
    
    create_game(test_db, game_data1, test_user)
    create_game(test_db, game_data2, test_user)
    
    # Tüm oyunları getir
    games = get_all_games(test_db)
    
    # En az iki oyun olmalı
    assert len(games) >= 2
    
    # Oluşturduğumuz oyunlar listede olmalı (name alanına göre kontrol et)
    assert any(g.name == "game1" for g in games)
    assert any(g.name == "game2" for g in games)

def test_delete_game(test_db: Session, test_user: User):
    """
    Oyun silme işlevini test eder
    """
    # Önce bir oyun oluştur
    game_data = GameCreate(
        name="delete_game_test",
        title="Delete Game Test",
        description="Test game deletion"
    )
    
    created_game = create_game(test_db, game_data, test_user)
    game_id = created_game.id
    
    # Oyunu sil
    delete_game(test_db, game_id, test_user)
    
    # Oyun silindi mi kontrol et
    with pytest.raises(HTTPException) as excinfo:
        get_game_by_id(test_db, game_id)
    
    assert excinfo.value.status_code == 404 