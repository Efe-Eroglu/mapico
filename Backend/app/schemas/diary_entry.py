from pydantic import BaseModel, Field
from datetime import datetime

class DiaryEntryBase(BaseModel):
    title: str = Field(..., max_length=200, description="Günlük başlığı")
    content: str = Field(..., description="Günlük içeriği")

class DiaryEntryCreate(DiaryEntryBase):
    """
    Yeni günlük girişi oluşturmak için kullanılan şema.
    user_id route’dan alınır; created_at otomatik atanır.
    """
    pass

class DiaryEntryRead(DiaryEntryBase):
    id: int = Field(..., description="Günlük kaydının ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    created_at: datetime = Field(..., description="Oluşturulma zamanı")

    class Config:
        orm_mode = True

class DiaryEntryUpdate(BaseModel):
    """
    Var olan günlük kaydını güncellemek için şema.
    """
    title: str = Field(..., max_length=200, description="Günlük başlığı")
    content: str = Field(..., description="Günlük içeriği")
