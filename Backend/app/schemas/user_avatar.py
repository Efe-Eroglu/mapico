from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class UserAvatarBase(BaseModel):
    avatar_id: Optional[int] = Field(
        None,
        description="Seçilen avatar parçası ID’si"
    )

class UserAvatarCreate(UserAvatarBase):
    """
    Avatar seçimi oluşturma; user_id’yi route’dan alacağız.
    selected_at otomatik set edilir.
    """
    pass

class UserAvatarRead(UserAvatarBase):
    id: int = Field(..., description="Pivot tablonun ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    selected_at: datetime = Field(..., description="Seçim zamanı")

    class Config:
        orm_mode = True

class UserAvatarUpdate(BaseModel):
    avatar_id: Optional[int] = Field(None, description="Yeni avatar parçası ID")
