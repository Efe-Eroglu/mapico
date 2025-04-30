from pydantic import BaseModel, EmailStr, Field
from datetime import date
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr = Field(..., description="Kullanıcının e-posta adresi")
    full_name: Optional[str] = Field(None, max_length=255, description="Tam adı")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Parola")

class UserRead(UserBase):
    id: int
    is_active: bool
    is_superuser: bool
    date_of_birth: Optional[date]
    age: Optional[int] = Field(None, description="Hesaplanan yaş")

    class Config:
        orm_mode = True

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    password: Optional[str] = Field(None, min_length=8)
