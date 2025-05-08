from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.game import GameCreate, GameRead
from app.services.game import create_game, delete_game, get_game_by_id, get_all_games
from app.db.session import get_db
from app.services.auth import get_current_user
from typing import List

router = APIRouter(prefix="/api/v1/games", tags=["Games"])

# Oyun ekleme
@router.post(
    "",
    response_model=GameRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new game",
    description="Yeni bir oyun ekler"
)
def create_new_game(
    game_in: GameCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        game = create_game(db, game_in, current_user)
        return game
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )

# Oyun silme
@router.delete(
    "/{game_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a game",
    description="Bir oyunu siler"
)
def delete_game_endpoint(
    game_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user) 
):
    try:
        delete_game(db, game_id, current_user)
        return {"detail": "Game deleted successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Bir hata oluştu: {str(e)}"
        )


# Oyun bilgilerini getirme
@router.get(
    "/{game_id}",
    response_model=GameRead,
    status_code=status.HTTP_200_OK,
    summary="Get game details",
    description="Bir oyunun detaylarını getirir"
)
def get_game(
    game_id: int,
    db: Session = Depends(get_db)
):
    try:
        game = get_game_by_id(db, game_id)
        return game
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Bir hata oluştu: {str(e)}"
        )
        
        
# Tüm oyunları getirme
@router.get(
    "",
    response_model=List[GameRead],
    status_code=status.HTTP_200_OK,
    summary="Get all games",
    description="Tüm oyunları getirir"
)
def get_all_games_endpoint(
    db: Session = Depends(get_db)
):
    try:
        games = get_all_games(db)
        return games
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )