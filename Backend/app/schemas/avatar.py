from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, List

class AvatarCreate(BaseModel):
    name: str = Field(..., max_length=100, description="Avatar adı")
    image_url: HttpUrl = Field(..., description="Avatar görsel URL’si")
    description: Optional[str] = Field(None, description="Avatar açıklaması")

class AvatarRead(BaseModel):
    id: int = Field(..., description="Avatar parçasının benzersiz kimliği")
    name: str
    image_url: HttpUrl
    description: Optional[str]

    class Config:
        orm_mode = True

class AvatarUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="Avatar adı")
    image_url: Optional[HttpUrl] = Field(None, description="Avatar görsel URL’si")
    description: Optional[str] = Field(None, description="Avatar açıklaması")
