from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.schemas.flight_stop import FlightStopCreate, FlightStopRead
from app.services.flight_stop import create_flight_stop, get_all_flight_stops
from app.db.session import get_db
from app.core.encryption import encryption_service 
from app.models.flight_stop import FlightStop

router = APIRouter(prefix="/api/v1/flight_stops", tags=["FlightStops"])

# Yeni uçuş durağı ekleme (şifreli)
@router.post(
    "",
    response_model=FlightStopRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new flight stop",
    description="Yeni bir uçuş durağı ekler"
)
def create_new_flight_stop(
    flight_stop_in: FlightStopCreate,
    db: Session = Depends(get_db)
):
    try:
        flight_stop = create_flight_stop(db, flight_stop_in)
        return flight_stop
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )

@router.get(
    "/all",
    response_model=List[FlightStopRead],
    status_code=status.HTTP_200_OK,
    summary="Get all flight stops",
    description="Tüm uçuş duraklarını listeler"
)
def get_all_flight_stops_endpoint(
    db: Session = Depends(get_db)
):
    try:
        flight_stops = get_all_flight_stops(db)
        return flight_stops
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )


# app/routers/flight_stop.py
@router.get(
    "/by_flight/{flight_id}",
    response_model=List[FlightStopRead],
    status_code=status.HTTP_200_OK,
    summary="Get flight stops for a specific flight",
    description="Belirli bir flight_id'ye sahip uçuş duraklarını listeler"
)
def get_flight_stops_by_flight_id(
    flight_id: int,
    db: Session = Depends(get_db)
):
    try:
        flight_stops = db.query(FlightStop).filter(FlightStop.flight_id == flight_id).all()

        if not flight_stops:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No flight stops found for flight ID {flight_id}"
            )

        # Şifrelenmiş verileri deşifre ediyoruz
        for flight_stop in flight_stops:
            flight_stop.name = encryption_service.decrypt(flight_stop.name)
            if flight_stop.description:
                flight_stop.description = encryption_service.decrypt(flight_stop.description)

        return flight_stops
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )
