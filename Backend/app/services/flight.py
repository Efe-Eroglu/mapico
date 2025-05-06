from typing import List
from sqlalchemy.orm import Session
from app.models.flight import Flight
from app.schemas.flight import FlightRead
from app.core.encryption import encryption_service  # Şifreleme işlemi için ekledik
from app.schemas.flight import FlightCreate 

def get_all_flights(db: Session) -> List[FlightRead]:
    # Veritabanındaki tüm uçuş rotalarını alıyoruz
    flights = db.query(Flight).all()

    # Şifreli alanları deşifre ediyoruz (title ve description)
    for flight in flights:
        try:
            flight.title = encryption_service.decrypt(flight.title)
        except Exception:
            pass  # Eğer şifrelenmemişse bir şey yapmamıza gerek yok

        if flight.description:
            try:
                flight.description = encryption_service.decrypt(flight.description)
            except Exception:
                pass  # Eğer şifrelenmemişse bir şey yapmamıza gerek yok

    return flights



def create_flight(db: Session, flight_in: FlightCreate) -> FlightRead:
    # Uçuş başlığı ve açıklamasını şifrele
    flight_in.encrypt()

    # Yeni uçuş rotası oluştur
    db_flight = Flight(
        title=flight_in.title,
        description=flight_in.description
    )

    db.add(db_flight)
    db.commit()
    db.refresh(db_flight)

    # Yanıt olarak FlightRead şemasına uygun veriyi döndür
    return FlightRead(
        id=db_flight.id,
        title=db_flight.title,
        description=db_flight.description
    )