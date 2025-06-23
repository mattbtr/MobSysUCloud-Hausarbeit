from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/kunden", tags=["Kunden"])

@router.post("/", response_model=schemas.Kunde)
def create_kunde(kunde: schemas.KundeCreate, db: Session = Depends(get_db)):
    db_kunde = models.Kunde(**kunde.model_dump())
    db.add(db_kunde)
    db.commit()
    db.refresh(db_kunde)
    return db_kunde

@router.get("/", response_model=List[schemas.Kunde])
def get_kunden(db: Session = Depends(get_db)):
    return db.query(models.Kunde).all()

@router.get("/{kunde_id}", response_model=schemas.Kunde)
def get_kunde(kunde_id: int, db: Session = Depends(get_db)):
    kunde = db.query(models.Kunde).get(kunde_id)
    if not kunde:
        raise HTTPException(status_code=404, detail="Kunde nicht gefunden")
    return kunde

@router.put("/{kunde_id}", response_model=schemas.Kunde)
def update_kunde(kunde_id: int, updated: schemas.KundeCreate, db: Session = Depends(get_db)):
    kunde = db.query(models.Kunde).get(kunde_id)
    if not kunde:
        raise HTTPException(status_code=404, detail="Kunde nicht gefunden")
    for key, value in updated.model_dump().items():
        setattr(kunde, key, value)
    db.commit()
    return kunde

@router.delete("/{kunde_id}")
def delete_kunde(kunde_id: int, db: Session = Depends(get_db)):
    kunde = db.query(models.Kunde).get(kunde_id)
    if not kunde:
        raise HTTPException(status_code=404, detail="Kunde nicht gefunden")
    db.delete(kunde)
    db.commit()
    return {"detail": "Kunde gelöscht"}
