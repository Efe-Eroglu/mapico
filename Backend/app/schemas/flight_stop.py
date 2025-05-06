from pydantic import BaseModel, Field
from typing import Optional

class FlightStopBase(BaseModel):
    flight_id: int = Field(..., description="Linked flight ID")
    name: str = Field(..., max_length=100, description="Durak adı")
    order: int = Field(..., ge=1, description="Sıralama numarası")
    reward_badge: Optional[int] = Field(
        None, description="Ödül rozet ID (opsiyonel)"
    )
    description: Optional[str] = Field(
        None, description="Durak açıklaması (opsiyonel)"
    )  # description alanı ekledik

class FlightStopCreate(FlightStopBase):
    """
    Yeni durak eklemek için istek gövdesi.
    """
    pass

class FlightStopRead(FlightStopBase):
    id: int = Field(..., description="Durak ID")

    class Config:
        orm_mode = True

class FlightStopUpdate(BaseModel):
    """
    PUT/PATCH için kısmi güncelleme modeli.
    """
    name: Optional[str] = Field(None, max_length=100)
    order: Optional[int] = Field(None, ge=1)
    reward_badge: Optional[int] = None
    description: Optional[str] = None  # description ekledik
