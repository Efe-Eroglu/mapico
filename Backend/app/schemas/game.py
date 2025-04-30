from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List

class GameBase(BaseModel):
    name: str = Field(..., max_length=100, description="Oyunun kısa adı")
    title: str = Field(..., max_length=200, description="Oyun başlığı")
    description: Optional[str] = Field(None, description="Oyun açıklaması")

class GameCreate(GameBase):
    """Yeni oyun tanımı için şema"""
    pass

class GameRead(GameBase):
    id: int = Field(..., description="Oyun ID")
    created_at: datetime = Field(..., description="Oluşturulma zamanı")
    # isterseniz session özetleri ekleyebilirsiniz:
    # sessions: List["GameSessionRead"]

    class Config:
        orm_mode = True

class GameUpdate(BaseModel):
    title: Optional[str] = Field(None, max_length=200)
    description: Optional[str] = None
