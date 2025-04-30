from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ReminderBase(BaseModel):
    type: str = Field(
        ..., max_length=50,
        description="Hatırlatıcı türü, örn. 'rest_eyes'"
    )
    schedule_cron: str = Field(
        ..., max_length=100,
        description="Cron ifadesi veya zamanlama tanımı"
    )

class ReminderCreate(ReminderBase):
    """
    Yeni hatırlatıcı oluşturmak için kullanılan şema.
    user_id route’dan alınır; created_at otomatik atanır.
    """
    pass

class ReminderRead(ReminderBase):
    id: int = Field(..., description="Hatırlatıcı kaydının ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    created_at: datetime = Field(..., description="Oluşturulma zamanı")

    class Config:
        orm_mode = True

class ReminderUpdate(BaseModel):
    """
    Mevcut hatırlatıcıyı güncellemek için kullanılacak şema.
    """
    type: Optional[str] = Field(None, max_length=50)
    schedule_cron: Optional[str] = Field(None, max_length=100)
