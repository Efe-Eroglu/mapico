from sqlalchemy.orm import Session
from app.models.leaderboard import Leaderboard
from app.schemas.leaderboard import LeaderboardCreate, LeaderboardRead
from fastapi import HTTPException, status
from sqlalchemy import func 

def get_leaderboard_by_game_id(db: Session, game_id: int) -> list[LeaderboardRead]:
    # game_id'ye göre leaderboard verilerini çekiyoruz
    db_leaderboard = db.query(Leaderboard).filter(Leaderboard.game_id == game_id).order_by(Leaderboard.best_score.desc()).all()

    if not db_leaderboard:
        # Eğer liderlik tablosu verisi yoksa, belirgin bir hata mesajı veriyoruz
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Leaderboard bulunamadı, game_id={game_id} için veri bulunmuyor."
        )

    return [
        LeaderboardRead(
            id=lb.id,
            game_id=lb.game_id,
            user_id=lb.user_id,
            best_score=lb.best_score,
            updated_at=lb.updated_at
        ) for lb in db_leaderboard
    ]
    
    
