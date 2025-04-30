from pydantic import BaseModel, Field
from typing import Any, Optional

class TaskBase(BaseModel):
    stop_id: int = Field(..., description="flight_stops tablosundaki ID")
    type: str = Field(..., max_length=50, description="Görev tipi")
    payload: Optional[Any] = Field(None, description="Görev verisi (JSON)")
    points: int = Field(..., ge=0, description="Görevden kazanılacak puan")

class TaskCreate(TaskBase):
    """
    Yeni görev oluşturmak için kullanılacak şema.
    """
    pass

class TaskRead(TaskBase):
    id: int = Field(..., description="Görev ID")

    class Config:
        orm_mode = True

class TaskUpdate(BaseModel):
    """
    Var olan görevi güncellemek için kullanılacak şema.
    """
    type: Optional[str] = Field(None, max_length=50)
    payload: Optional[Any] = None
    points: Optional[int] = Field(None, ge=0)
    
