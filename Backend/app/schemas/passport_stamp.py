from pydantic import BaseModel, Field
from datetime import datetime

class PassportStampBase(BaseModel):
    stop_id: int = Field(..., description="flight_stops tablosundaki ID")

class PassportStampCreate(PassportStampBase):
    """
    Yeni damga eklemek için kullanılacak şema.
    user_id route’dan alınır.
    """
    pass

class PassportStampRead(PassportStampBase):
    id: int = Field(..., description="Damga kaydının ID’si")
    user_id: int = Field(..., description="Kullanıcı ID")
    stamped_at: datetime = Field(..., description="Damgalanma zamanı")

    class Config:
        orm_mode = True
