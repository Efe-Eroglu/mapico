# app/schemas/equipment.py

from pydantic import BaseModel, Field, HttpUrl
from typing import Optional

class EquipmentBase(BaseModel):
    name: str = Field(
        ..., 
        max_length=100, 
        description="Ekipman adı, örn. 'dürbün', 'pusula'"
    )
    description: Optional[str] = Field(
        None, 
        max_length=255,
        description="Ekipmanın kısa açıklaması"
    )
    icon_url: Optional[HttpUrl] = Field(
        None, 
        description="S3/CDN üzerindeki simge görselinin URL’si"
    )

class EquipmentCreate(EquipmentBase):
    """
    Yeni ekipman eklemek için kullanılacak şema.
    Tüm alanlar EquipmentBase’den geliyor.
    """
    pass

class EquipmentRead(EquipmentBase):
    """
    DB’den döneceğiniz yanıtın şeması.
    `orm_mode = True` ile SQLAlchemy modelini direkt kabul eder.
    """
    id: int = Field(..., description="Ekipmanın benzersiz kimliği")

    class Config:
        orm_mode = True

class EquipmentUpdate(BaseModel):
    """
    Ekipman güncelleme (PATCH/PUT) için opsiyonel tüm alanlar.
    """
    name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Ekipman adı"
    )
    description: Optional[str] = Field(
        None, 
        max_length=255,
        description="Ekipmanın kısa açıklaması"
    )
    icon_url: Optional[HttpUrl] = Field(
        None, 
        description="Simge görsel URL"
    )
