# app/schemas/avatar.py

from pydantic import BaseModel, Field, HttpUrl
from typing import Optional

class AvatarBase(BaseModel):
    category: str = Field(
        ..., 
        max_length=50, 
        description="Kategori, örn. 'hair', 'eyes', 'clothes', 'accessory'"
    )
    name: str = Field(
        ..., 
        max_length=100, 
        description="Parça adı, örn. 'short_hair', 'blue_eyes'"
    )
    image_url: HttpUrl = Field(
        ..., 
        description="Avatar parçasının S3/CDN üzerindeki görsel URL’si"
    )

class AvatarCreate(AvatarBase):
    """
    Yeni avatar parçası eklemek için kullanılacak şema.
    Tüm alanlar AvatarBase’den geliyor.
    """
    pass

class AvatarRead(AvatarBase):
    """
    DB’den döneceğiniz yanıtın şeması.
    `orm_mode = True` ile SQLAlchemy modelini direkt kabul eder.
    """
    id: int = Field(..., description="Avatar parçasının benzersiz kimliği")

    class Config:
        orm_mode = True

class AvatarUpdate(BaseModel):
    """
    Avatar parçası güncelleme (PATCH/PUT) için opsiyonel tüm alanlar.
    """
    category: Optional[str] = Field(
        None, 
        max_length=50, 
        description="Kategori"
    )
    name: Optional[str] = Field(
        None, 
        max_length=100, 
        description="Parça adı"
    )
    image_url: Optional[HttpUrl] = Field(
        None, 
        description="Görsel URL"
    )
