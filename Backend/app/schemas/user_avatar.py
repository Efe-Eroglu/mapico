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

class UserAvatarUpdate(BaseModel):
    avatar_id: Optional[int] = Field(None, description="Yeni avatar parçası ID")


class UserAvatarAssign(BaseModel):
    avatar_id: int = Field(..., description="Atanacak avatar'ın ID'si")

class UserAvatarRead(BaseModel):
    id: int
    user_id: int
    avatar_id: int
    selected_at: datetime

    class Config:
        orm_mode = True