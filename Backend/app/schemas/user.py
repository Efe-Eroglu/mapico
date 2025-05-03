# app/schemas/user.py

from pydantic import BaseModel, EmailStr, Field
from datetime import date
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr = Field(..., description="Kullanıcının e-posta adresi")
    full_name: Optional[str] = Field(
        None,
        max_length=255,
        description="Tam adı"
    )

class UserCreate(UserBase):
    date_of_birth: date = Field(..., description="Doğum tarihi (YYYY-AA-GG)")
    password: str = Field(
        ...,
        min_length=8,
        description="Parola"
    )

class UserRead(UserBase):
    id: int
    date_of_birth: Optional[date]
    age: Optional[int] = Field(None, description="Hesaplanan yaş")
    is_active: bool
    is_superuser: bool

    model_config = {
        "from_attributes": True  # Pydantic V2 için ORM objelerini okumaya izin verir
    }

class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(None, max_length=255, description="Güncel tam adı")
    date_of_birth: Optional[date] = Field(None, description="Güncel doğum tarihi (YYYY-AA-GG)")
    password: Optional[str] = Field(None, min_length=8, description="Yeni parola")
