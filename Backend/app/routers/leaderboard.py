from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.schemas.leaderboard import LeaderboardCreate, LeaderboardRead
from app.services.leaderboard import get_leaderboard_by_game_id
from app.db.session import get_db

router = APIRouter(prefix="/api/v1/leaderboards", tags=["Leaderboards"])

# Oyun ID'sine göre leaderboard'ı getir
@router.get(
    "/{game_id}",
    response_model=List[LeaderboardRead],
    status_code=status.HTTP_200_OK,
    summary="Get leaderboard for a specific game",
    description="Belirli bir oyun için tüm liderlik tablosunu getirir"
)
def get_leaderboard_by_game(
    game_id: int,
    db: Session = Depends(get_db)
):
    try:
        leaderboard = get_leaderboard_by_game_id(db, game_id)
        return leaderboard
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )

