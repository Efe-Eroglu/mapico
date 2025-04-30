from pydantic import BaseModel, Field
from datetime import datetime

class UserBadgeBase(BaseModel):
    badge_id: int = Field(..., description="Rozet ID")

class UserBadgeCreate(UserBadgeBase):
    """
    Oluşturma şeması; user_id route’dan alınır.
    awarded_at otomatik atanır.
    """
    pass

class UserBadgeRead(UserBadgeBase):
    id: int = Field(..., description="Kayıt ID")
    user_id: int = Field(..., description="Kullanıcı ID")
    awarded_at: datetime = Field(..., description="Veriliş zamanı")

    class Config:
        orm_mode = True

class UserBadgeUpdate(BaseModel):
    """
    Kullanıcı rozet güncelleme şeması.
    """
    badge_id: int = Field(..., description="Yeni rozet ID’si")
