# app/services/game_session.py
from sqlalchemy.orm import Session
from app.models.game_session import GameSession
from app.schemas.game_session import GameSessionRead, GameSessionCreate
from app.core.encryption import encryption_service
from fastapi import HTTPException, status
from app.models.user import User

def get_all_game_sessions(db: Session) -> list[GameSessionRead]:
    db_game_sessions = db.query(GameSession).all()
    if not db_game_sessions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No game sessions found"
        )
    return [
        GameSessionRead(
            id=db_game_session.id,
            game_id=db_game_session.game_id,
            user_id=db_game_session.user_id,
            score=db_game_session.score,
            success=db_game_session.success,
            started_at=db_game_session.started_at,
            ended_at=db_game_session.ended_at
        ) for db_game_session in db_game_sessions
    ]


def get_game_sessions_by_user_id(db: Session, user_id: int) -> list[GameSessionRead]:
    db_game_sessions = db.query(GameSession).filter(GameSession.user_id == user_id).all()
    
    # Kullanıcıya ait oyun oturumları bulunmazsa boş liste döndürüyoruz
    if not db_game_sessions:
        return []

    # Şifrelenmiş verileri deşifre edip döndürüyoruz
    return [
        GameSessionRead(
            id=db_game_session.id,
            game_id=db_game_session.game_id,
            user_id=db_game_session.user_id,
            score=db_game_session.score,
            success=db_game_session.success,
            started_at=db_game_session.started_at,
            ended_at=db_game_session.ended_at
        ) for db_game_session in db_game_sessions
    ]
    
    
# app/services/game_session.py

def get_game_sessions_by_game_id(db: Session, game_id: int) -> list[GameSessionRead]:
    # game_id'ye göre oyun oturumlarını sorguluyoruz
    db_game_sessions = db.query(GameSession).filter(GameSession.game_id == game_id).all()
    
    # Oyun oturumları bulunmazsa boş liste döndürüyoruz
    if not db_game_sessions:
        return []

    # Şifrelenmiş verileri deşifre edip döndürüyoruz
    return [
        GameSessionRead(
            id=db_game_session.id,
            game_id=db_game_session.game_id,
            user_id=db_game_session.user_id,
            score=db_game_session.score,
            success=db_game_session.success,
            started_at=db_game_session.started_at,
            ended_at=db_game_session.ended_at
        ) for db_game_session in db_game_sessions
    ]


# app/services/game_session.py
def get_game_sessions_by_user_and_game_id(db: Session, user_id: int, game_id: int) -> list[GameSessionRead]:
    db_game_sessions = db.query(GameSession).filter(
        GameSession.user_id == user_id, 
        GameSession.game_id == game_id
    ).all()
    
    # Oyun oturumları bulunmazsa boş liste döndürüyoruz
    if not db_game_sessions:
        return []

    # Şifrelenmiş verileri deşifre edip döndürüyoruz
    return [
        GameSessionRead(
            id=db_game_session.id,
            game_id=db_game_session.game_id,
            user_id=db_game_session.user_id,
            score=db_game_session.score,
            success=db_game_session.success,
            started_at=db_game_session.started_at,
            ended_at=db_game_session.ended_at
        ) for db_game_session in db_game_sessions
    ]


def create_game_session(
    db: Session, game_session_in: GameSessionCreate
) -> GameSessionRead:
    # Yeni bir oyun oturumu oluşturuyoruz
    db_game_session = GameSession(
        game_id=game_session_in.game_id,
        user_id=game_session_in.user_id,
        score=game_session_in.score,
        success=game_session_in.success,
        started_at=game_session_in.started_at,
        ended_at=game_session_in.ended_at
    )

    db.add(db_game_session)
    db.commit()
    db.refresh(db_game_session)

    # Oyun oturumunu GameSessionRead formatında döndürüyoruz
    return GameSessionRead(
        id=db_game_session.id,
        game_id=db_game_session.game_id,
        user_id=db_game_session.user_id,
        score=db_game_session.score,
        success=db_game_session.success,
        started_at=db_game_session.started_at,
        ended_at=db_game_session.ended_at
    )
    
def get_game_sessions_by_filtered_game_id(db: Session, game_id: int) -> list[GameSessionRead]:
    db_game_sessions = db.query(GameSession).filter(GameSession.game_id == game_id).all()
    
    if not db_game_sessions:
        return []

    return [
        GameSessionRead(
            id=db_game_session.id,
            game_id=db_game_session.game_id,
            user_id=db_game_session.user_id,
            score=db_game_session.score,
            success=db_game_session.success,
            started_at=db_game_session.started_at,
            ended_at=db_game_session.ended_at
        ) for db_game_session in db_game_sessions
    ]
    
def get_game_sessions_sorted_by_score_with_user_names(db: Session, game_id: int) -> list[GameSessionRead]:
    db_game_sessions = db.query(GameSession, User).join(User, User.id == GameSession.user_id).filter(GameSession.game_id == game_id).order_by(GameSession.score.desc()).all()

    if not db_game_sessions:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Leaderboard not found for this game"
        )

    return [
        GameSessionRead(
            id=db_game_session.GameSession.id,
            game_id=db_game_session.GameSession.game_id,
            user_id=db_game_session.GameSession.user_id,
            user_name=db_game_session.User.full_name,
            score=db_game_session.GameSession.score,
            success=db_game_session.GameSession.success,
            started_at=db_game_session.GameSession.started_at,
            ended_at=db_game_session.GameSession.ended_at
        ) for db_game_session in db_game_sessions
    ]