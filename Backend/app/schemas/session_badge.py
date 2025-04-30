from pydantic import BaseModel, Field
from datetime import datetime

class SessionBadgeBase(BaseModel):
    session_id: int = Field(..., description="GameSession ID")
    badge_id: int = Field(..., description="Badge ID")

class SessionBadgeCreate(SessionBadgeBase):
    pass

class SessionBadgeRead(SessionBadgeBase):
    id: int = Field(..., description="SessionBadge ID")
    awarded_at: datetime = Field(..., description="Veriliş zamanı")

    class Config:
        orm_mode = True
