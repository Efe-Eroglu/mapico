from sqlalchemy.orm import Session
from app.models.flight_stop import FlightStop
from app.schemas.flight_stop import FlightStopCreate, FlightStopRead
from app.core.encryption import encryption_service  # Şifreleme için ekledik
from fastapi import HTTPException
from typing import List

def create_flight_stop(db: Session, flight_stop_in: FlightStopCreate) -> FlightStopRead:
    # Şifreleme işlemi yapıyoruz
    flight_stop_in.name = encryption_service.encrypt(flight_stop_in.name)
    if flight_stop_in.description:  # description boşsa şifreleme yapma
        flight_stop_in.description = encryption_service.encrypt(flight_stop_in.description)

    # Yeni flight stop oluşturuluyor
    db_flight_stop = FlightStop(
        flight_id=flight_stop_in.flight_id,
        name=flight_stop_in.name,
        order=flight_stop_in.order,
        reward_badge=flight_stop_in.reward_badge,
        description=flight_stop_in.description  # description ekliyoruz
    )

    db.add(db_flight_stop)
    db.commit()
    db.refresh(db_flight_stop)

    # Şifrelenmiş veriyi deşifre edip döndürüyoruz
    return FlightStopRead(
        id=db_flight_stop.id,
        flight_id=db_flight_stop.flight_id,
        name=encryption_service.decrypt(db_flight_stop.name),
        order=db_flight_stop.order,
        reward_badge=db_flight_stop.reward_badge,
        description=encryption_service.decrypt(db_flight_stop.description) if db_flight_stop.description else None  # description deşifre ediliyor
    )

def update_flight_stop(
    db: Session, flight_stop_id: int, flight_stop_in: FlightStopCreate
) -> FlightStopRead:
    db_flight_stop = db.query(FlightStop).filter(FlightStop.id == flight_stop_id).first()
    if not db_flight_stop:
        raise HTTPException(status_code=404, detail="Flight stop not found")
    
    # Şifreleme işlemi
    if flight_stop_in.name:
        db_flight_stop.name = encryption_service.encrypt(flight_stop_in.name)
    if flight_stop_in.description:
        db_flight_stop.description = encryption_service.encrypt(flight_stop_in.description)

    if flight_stop_in.reward_badge is not None:
        db_flight_stop.reward_badge = flight_stop_in.reward_badge

    db.commit()
    db.refresh(db_flight_stop)

    # Deşifre edilmiş veriyi döndürüyoruz
    return FlightStopRead(
        id=db_flight_stop.id,
        flight_id=db_flight_stop.flight_id,
        name=encryption_service.decrypt(db_flight_stop.name),
        order=db_flight_stop.order,
        reward_badge=db_flight_stop.reward_badge
    )

def get_all_flight_stops(db: Session) -> List[FlightStopRead]:
    # Veritabanındaki tüm uçuş duraklarını alıyoruz
    flight_stops = db.query(FlightStop).all()

    # Şifrelenmiş alanları deşifre ediyoruz
    for flight_stop in flight_stops:
        flight_stop.name = encryption_service.decrypt(flight_stop.name)
        if flight_stop.description:
            flight_stop.description = encryption_service.decrypt(flight_stop.description)

    return flight_stops
