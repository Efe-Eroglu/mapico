import pytest
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.schemas.flight import FlightCreate, FlightRead
from app.services.flight import create_flight, get_all_flights
from app.models.user import User
from app.models.flight import Flight
from app.core.encryption import encryption_service

def test_create_flight(test_db: Session, test_user: User):
    """
    Uçuş rotası oluşturma işlevini test eder
    """
    flight_data = FlightCreate(
        title="Test Uçuş Rotası",
        description="Bu bir test uçuş rotası açıklamasıdır"
    )
    
    # Orijinal verileri sakla
    original_title = flight_data.title
    original_description = flight_data.description
    
    # Uçuş oluştur
    flight = create_flight(test_db, flight_data)
    
    # Uçuş doğru şekilde oluşturuldu mu?
    assert flight.id is not None
    # Not: create_flight verileri şifreli olarak döndürür, o yüzden karşılaştırmak için deşifre edilmeli
    assert encryption_service.decrypt(flight.title) == original_title
    if flight.description:
        assert encryption_service.decrypt(flight.description) == original_description
    
    # Veritabanından tüm uçuşları çekip kontrol edelim
    db_flights = get_all_flights(test_db)
    assert len(db_flights) >= 1
    
    # Oluşturduğumuz uçuş listede olmalı
    created_flight = next((f for f in db_flights if f.id == flight.id), None)
    assert created_flight is not None
    assert created_flight.title == original_title  # get_all_flights verileri deşifre eder

def test_get_all_flights(test_db: Session):
    """
    Tüm uçuşları getirme işlevini test eder
    """
    # Önce veritabanını temizle
    test_db.query(Flight).delete()
    test_db.commit()
    
    # Birkaç uçuş oluştur
    flight_data1 = FlightCreate(
        title="Birinci Test Uçuşu",
        description="Birinci test uçuşu açıklaması"
    )
    
    flight_data2 = FlightCreate(
        title="İkinci Test Uçuşu",
        description="İkinci test uçuşu açıklaması"
    )
    
    create_flight(test_db, flight_data1)
    create_flight(test_db, flight_data2)
    
    # Tüm uçuşları getir
    flights = get_all_flights(test_db)
    
    # En az iki uçuş olmalı
    assert len(flights) >= 2
    
    # Oluşturduğumuz uçuşlar listede olmalı (başlık alanına göre kontrol et)
    assert any(f.title == "Birinci Test Uçuşu" for f in flights)
    assert any(f.title == "İkinci Test Uçuşu" for f in flights) 