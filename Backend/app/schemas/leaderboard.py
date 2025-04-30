from pydantic import BaseModel, Field
from datetime import datetime

class LeaderboardBase(BaseModel):
    game_id: int = Field(..., description="Game ID")
    user_id: int = Field(..., description="User ID")
    best_score: int = Field(..., ge=0, description="En yüksek puan")

class LeaderboardCreate(LeaderboardBase):
    pass

class LeaderboardRead(LeaderboardBase):
    id: int = Field(..., description="Leaderboards tablosundaki ID")
    updated_at: datetime = Field(..., description="Güncellenme zamanı")

    class Config:
        orm_mode = True

class LeaderboardUpdate(BaseModel):
    best_score: int = Field(..., ge=0)
