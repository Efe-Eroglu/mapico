# Backend/app/routers/flight.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.flight import FlightCreate, FlightRead, FlightUpdate
from app.services.flight import get_all_flights, create_flight
from app.db.session import get_db
from app.models.flight import Flight    
from typing import List

router = APIRouter(prefix="/api/v1/flights", tags=["Flights"])

@router.post(
    "",
    response_model=FlightRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new flight",
    description="Yeni bir uçuş rotası ekler"
)
def create_new_flight(
    flight_in: FlightCreate,
    db: Session = Depends(get_db)
):
    try:
        flight = create_flight(db, flight_in)
        return flight
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Bir hata oluştu: {str(e)}"
        )


@router.get(
    "",
    response_model=List[FlightRead],
    status_code=status.HTTP_200_OK,
    summary="Get all flights",
    description="Tüm uçuş rotalarını listeler"
)
def list_flights(
    db: Session = Depends(get_db)
):
    try:
        flights = get_all_flights(db)
        return flights
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bir hata oluştu: {str(e)}"
        )