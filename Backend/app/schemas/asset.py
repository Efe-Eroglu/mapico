from pydantic import BaseModel, Field, HttpUrl
from typing import Optional

class AssetBase(BaseModel):
    stop_id: int = Field(..., description="flight_stops tablosundaki ID")
    type: str = Field(..., max_length=50, description="Varlık tipi")
    url: HttpUrl = Field(..., description="Varlığın URL’si")

class AssetCreate(AssetBase):
    """
    Yeni varlık ekleme şeması.
    """
    pass

class AssetRead(AssetBase):
    id: int = Field(..., description="Varlık ID")

    class Config:
        orm_mode = True

class AssetUpdate(BaseModel):
    """
    Var olan varlığı güncelleme şeması.
    """
    type: Optional[str] = Field(None, max_length=50)
    url: Optional[HttpUrl] = None
