from pydantic import BaseModel, Field
from datetime import datetime

class UserEquipmentBase(BaseModel):
    equipment_id: int = Field(..., description="Seçilen ekipman ID’si")

class UserEquipmentCreate(UserEquipmentBase):
    """
    Oluşturma şeması; user_id route’dan alınır.
    selected_at otomatik atanır.
    """
    pass

class UserEquipmentRead(UserEquipmentBase):
    id: int = Field(..., description="Kayıdın benzersiz ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    selected_at: datetime = Field(..., description="Seçim zamanı")

    class Config:
        orm_mode = True

class UserEquipmentUpdate(BaseModel):
    """
    Güncelleme şeması; genelde equipment_id değişikliği için kullanılır.
    """
    equipment_id: int = Field(..., description="Yeni ekipman ID’si")
