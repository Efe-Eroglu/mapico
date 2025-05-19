from sqlalchemy.orm import Session
from app.models.game import Game
from app.schemas.game import GameCreate, GameRead
from app.core.encryption import encryption_service
from fastapi import HTTPException, status
from app.services.auth import get_current_user  # Kimlik doğrulama fonksiyonunu import ettik
from fastapi import Depends

def create_game(db: Session, game_in: GameCreate, current_user = Depends(get_current_user)) -> GameRead:
    # Oyun verilerini şifreliyoruz
    game_in.title = encryption_service.encrypt(game_in.title)
    if game_in.description:
        game_in.description = encryption_service.encrypt(game_in.description)

    # Yeni game oluşturuluyor
    db_game = Game(
        name=game_in.name,
        title=game_in.title,
        description=game_in.description
    )

    db.add(db_game)
    db.commit()
    db.refresh(db_game)

    # Şifreli verileri deşifre ederek döndürüyoruz
    return GameRead(
        id=db_game.id,
        name=db_game.name,
        title=encryption_service.decrypt(db_game.title),
        description=encryption_service.decrypt(db_game.description) if db_game.description else None,
        created_at=db_game.created_at
    )

def delete_game(db: Session, game_id: int, current_user = Depends(get_current_user)):
    db_game = db.query(Game).filter(Game.id == game_id).first()
    if not db_game:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Game not found")
    
    db.delete(db_game)
    db.commit()



def get_game_by_id(db: Session, game_id: int) -> GameRead:
    db_game = db.query(Game).filter(Game.id == game_id).first()
    if not db_game:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Game not found"
        )

    return GameRead(
        id=db_game.id,
        name=db_game.name,
        title=encryption_service.decrypt(db_game.title),
        description=encryption_service.decrypt(db_game.description) if db_game.description else None,
        created_at=db_game.created_at
    )
    
    
def get_all_games(db: Session) -> list[GameRead]:
    db_games = db.query(Game).all()
    if not db_games:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No games found"
        )

    result = []
    for db_game in db_games:
        try:
            decrypted_title = encryption_service.decrypt(db_game.title)
        except Exception:
            decrypted_title = db_game.title

        try:
            decrypted_description = encryption_service.decrypt(db_game.description) if db_game.description else None
        except Exception:
            decrypted_description = db_game.description

        result.append(GameRead(
            id=db_game.id,
            name=db_game.name,
            title=decrypted_title,
            description=decrypted_description,
            created_at=db_game.created_at
        ))

    return result

    
