from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class GameSessionBase(BaseModel):
    game_id: int = Field(..., description="Game ID")
    user_id: int = Field(..., description="User ID")
    score: int = Field(..., ge=0, description="Bu oturumdaki puan")
    success: bool = Field(..., description="Oturumun başarı durumu")
    started_at: Optional[datetime]
    ended_at: Optional[datetime]

class GameSessionCreate(GameSessionBase):
    pass

class GameSessionRead(GameSessionBase):
    id: int = Field(..., description="Oturum ID")
    user_name: str 

    class Config:
        orm_mode = True

class GameSessionUpdate(BaseModel):
    score: Optional[int] = Field(None, ge=0)
    success: Optional[bool]
    ended_at: Optional[datetime]
