from pydantic import BaseModel, Field
from typing import Any

class ParentSettingBase(BaseModel):
    child_id: int = Field(..., description="Çocuk kullanıcı ID")
    settings_json: Any = Field(
        ..., description="Ebeveyn kontrol ayarlarının JSON verisi"
    )

class ParentSettingCreate(ParentSettingBase):
    """
    Oluşturma şeması; parent_id route’dan alınır.
    """
    pass

class ParentSettingRead(ParentSettingBase):
    id: int = Field(..., description="Kayıt ID")
    parent_id: int = Field(..., description="Ebeveyn kullanıcı ID")

    class Config:
        orm_mode = True

class ParentSettingUpdate(BaseModel):
    """
    Ayarları güncellemek için kullanılacak şema.
    """
    settings_json: Any = Field(..., description="Güncel JSON verisi")
