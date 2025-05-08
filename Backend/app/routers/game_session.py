# app/routers/game_session.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.schemas.game_session import GameSessionRead, GameSessionCreate
from app.services.game_session import get_all_game_sessions, get_game_sessions_by_user_id, get_game_sessions_by_game_id, get_game_sessions_by_user_and_game_id, create_game_session, get_game_sessions_by_filtered_game_id
from app.db.session import get_db

router = APIRouter(prefix="/api/v1/game_sessions", tags=["GameSessions"])



# game_id'ye göre oyun oturumlarını filtreleyerek getirme
@router.get(
    "/filter",
    response_model=List[GameSessionRead],
    status_code=status.HTTP_200_OK,
    summary="Get game sessions filtered by game_id",
    description="Belirli bir game_id'ye sahip oyun oturumlarını getirir"
)
def get_filtered_game_sessions(
    game_id: int,  # game_id burada query parametresi olarak alınır
    db: Session = Depends(get_db)
):
    try:
        game_sessions = get_game_sessions_by_filtered_game_id(db, game_id)
        return game_sessions  # Boş liste dönebilir
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )

# Tüm oyun oturumlarını getirme
@router.get(
    "",
    response_model=List[GameSessionRead],
    status_code=status.HTTP_200_OK,
    summary="Get all game sessions",
    description="Tüm oyun oturumlarını getirir"
)
def get_all_game_sessions_endpoint(
    db: Session = Depends(get_db)
):
    try:
        game_sessions = get_all_game_sessions(db)
        return game_sessions
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )


# Kullanıcıya ait oyun oturumlarını getirme
@router.get(
    "/{user_id}",
    response_model=List[GameSessionRead],
    status_code=status.HTTP_200_OK,
    summary="Get game sessions of a specific user",
    description="Belirli bir kullanıcının oyun oturumlarını getirir"
)
def get_user_game_sessions(
    user_id: int,
    db: Session = Depends(get_db)
):
    try:
        game_sessions = get_game_sessions_by_user_id(db, user_id)
        return game_sessions  # Boş liste dönebilir
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )
        
        
@router.get(
    "/{game_id}",
    response_model=List[GameSessionRead],
    status_code=status.HTTP_200_OK,
    summary="Get game sessions for a specific game",
    description="Belirli bir oyun için tüm oyun oturumlarını getirir"
)
def get_game_sessions_by_game(
    game_id: int,
    db: Session = Depends(get_db)
):
    try:
        game_sessions = get_game_sessions_by_game_id(db, game_id)
        return game_sessions  
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )


@router.get(
    "/{user_id}/{game_id}",
    response_model=List[GameSessionRead],
    status_code=status.HTTP_200_OK,
    summary="Get game sessions for a specific user and game",
    description="Belirli bir kullanıcı ve oyun için oyun oturumlarını getirir"
)
def get_user_game_sessions_by_game(
    user_id: int,
    game_id: int,
    db: Session = Depends(get_db)
):
    try:
        game_sessions = get_game_sessions_by_user_and_game_id(db, user_id, game_id)
        return game_sessions  # Boş liste dönebilir
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )

# Kişiye oyun verisi ekleme
@router.post(
    "",
    response_model=GameSessionRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new game session",
    description="Bir kullanıcıya oyun oturumu verisi ekler"
)
def create_game_session_endpoint(
    game_session_in: GameSessionCreate,
    db: Session = Depends(get_db)
):
    try:
        game_session = create_game_session(db, game_session_in)
        return game_session
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )


