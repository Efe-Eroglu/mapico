from pydantic import BaseModel, Field, HttpUrl
from typing import Any, Optional

class BadgeBase(BaseModel):
    name: str = Field(
        ..., max_length=100,
        description="Rozet adı, örn. 'Explorer'"
    )
    icon_url: Optional[HttpUrl] = Field(
        None,
        description="Rozetin simge görsel URL’si"
    )
    criteria: Optional[Any] = Field(
        None,
        description="Rozet kazanma kriterlerinin JSON tanımı"
    )

class BadgeCreate(BadgeBase):
    """
    Yeni rozet eklemek için kullanılacak şema.
    """
    pass

class BadgeRead(BadgeBase):
    id: int = Field(..., description="Rozet ID")

    class Config:
        orm_mode = True

class BadgeUpdate(BaseModel):
    """
    Var olan rozet bilgisini güncellemek için kullanılacak şema.
    """
    name: Optional[str] = Field(None, max_length=100)
    icon_url: Optional[HttpUrl] = None
    criteria: Optional[Any] = None
