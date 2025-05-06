from pydantic import BaseModel, Field, HttpUrl
from typing import Optional
from app.core.encryption import encryption_service

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

    # Şifreleme işlemi sadece gerekli olduğunda yapılacak
    def encrypt(self):
        self.title = encryption_service.encrypt(self.title)
        if self.description:
            self.description = encryption_service.encrypt(self.description)

class FlightCreate(FlightBase):
    """
    Yeni rota eklemek için kullanılan şema.
    Bu şemada şifreleme işlemi yapılır.
    """
    pass

class FlightRead(FlightBase):
    id: int = Field(..., description="Rota ID")
    title: str = Field(..., max_length=255, description="Rota başlığı")

    class Config:
        orm_mode = True  # SQLAlchemy modeline dönüşüm için orm_mode kullanılır

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

    # Şifreleme işlemi yapılır
    def encrypt(self):
        if self.title:
            self.title = encryption_service.encrypt(self.title)
        if self.description:
            self.description = encryption_service.encrypt(self.description)
