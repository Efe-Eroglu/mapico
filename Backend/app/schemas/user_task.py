from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class UserTaskBase(BaseModel):
    task_id: int = Field(..., description="Task tablosundaki ID")

class UserTaskCreate(UserTaskBase):
    """
    Oluşturma şeması; user_id route’dan alınır,
    completed_at ve score sonradan güncellenebilir.
    """
    pass

class UserTaskRead(UserTaskBase):
    id: int = Field(..., description="Pivot tablonun ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    completed_at: Optional[datetime] = Field(None, description="Tamamlanma zamanı")
    score: Optional[int] = Field(None, description="Kazanılan puan")

    class Config:
        orm_mode = True

class UserTaskUpdate(BaseModel):
    """
    Görevin tamamlanma zamanı ve/veya skoru güncellemek için.
    """
    completed_at: Optional[datetime] = Field(None, description="Tamamlanma zamanı")
    score: Optional[int] = Field(None, description="Kazanılan puan")
