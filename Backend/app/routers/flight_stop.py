from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.schemas.flight_stop import FlightStopCreate, FlightStopRead
from app.services.flight_stop import create_flight_stop, get_all_flight_stops, update_flight_stop
from app.db.session import get_db

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

# Tüm uçuş duraklarını listeleme (şifreli)
@router.get(
    "",
    response_model=List[FlightStopRead],
    status_code=status.HTTP_200_OK,
    summary="Get all flight stops",
    description="Tüm uçuş duraklarını listeler"
)
def list_flight_stops(
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

# Uçuş durağını güncelleme (şifreli)
@router.put(
    "/{flight_stop_id}",
    response_model=FlightStopRead,
    status_code=status.HTTP_200_OK,
    summary="Update a flight stop",
    description="Bir uçuş durağını günceller"
)
def update_flight_stop_endpoint(
    flight_stop_id: int,
    flight_stop_in: FlightStopCreate,
    db: Session = Depends(get_db)
):
    try:
        flight_stop = update_flight_stop(db, flight_stop_id, flight_stop_in)
        return flight_stop
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )
