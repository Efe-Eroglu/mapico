from pydantic import BaseModel, Field
from typing import Optional

class FlightBase(BaseModel):
    title: str = Field(
        ..., 
        max_length=100, 
        description="Rota başlığı"
    )
    description: Optional[str] = Field(
        None, 
        description="Rotanın kısa açıklaması"
    )

class FlightCreate(FlightBase):
    """
    Yeni rota eklemek için kullanılan şema.
    """
    pass

class FlightRead(FlightBase):
    id: int = Field(..., description="Rota ID")

    class Config:
        orm_mode = True

class FlightUpdate(BaseModel):
    title: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Rota başlığı"
    )
    description: Optional[str] = Field(
        None, 
        description="Rotanın açıklaması"
    )
