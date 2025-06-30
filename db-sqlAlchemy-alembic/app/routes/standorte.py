from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/standorte", tags=["Standorte"])

@router.post("/", response_model=schemas.Standort)
def create_standort(standort: schemas.StandortCreate, db: Session = Depends(get_db)):
    # Prüfen, ob der Kunde existiert
    kunde = db.query(models.Kunde).get(standort.kunde_id)
    if not kunde:
        raise HTTPException(status_code=404, detail="Kunde nicht gefunden")
    
    db_standort = models.Standort(**standort.model_dump())
    db.add(db_standort)
    db.commit()
    db.refresh(db_standort)
    return db_standort

@router.get("/", response_model=List[schemas.Standort])
def get_standorte(db: Session = Depends(get_db)):
    return db.query(models.Standort).all()

@router.get("/{standort_id}", response_model=schemas.Standort)
def get_standort(standort_id: int, db: Session = Depends(get_db)):
    standort = db.query(models.Standort).get(standort_id)
    if not standort:
        raise HTTPException(status_code=404, detail="Standort nicht gefunden")
    return standort

@router.put("/{standort_id}", response_model=schemas.Standort)
def update_standort(standort_id: int, updated: schemas.StandortCreate, db: Session = Depends(get_db)):
    standort = db.query(models.Standort).get(standort_id)
    if not standort:
        raise HTTPException(status_code=404, detail="Standort nicht gefunden")
    
    for key, value in updated.model_dump().items():
        setattr(standort, key, value)
    db.commit()
    return standort

@router.delete("/{standort_id}")
def delete_standort(standort_id: int, db: Session = Depends(get_db)):
    standort = db.query(models.Standort).get(standort_id)
    if not standort:
        raise HTTPException(status_code=404, detail="Standort nicht gefunden")
    
    db.delete(standort)
    db.commit()
    return {"detail": "Standort gelöscht"}

# get Standorte zu einem bestimmten Kunden (KundenId)
@router.get("/kunde/{kunde_id}", response_model=List[schemas.Standort])
def get_standorte_by_kunde(kunde_id: int, db: Session = Depends(get_db)):
    standorte = db.query(models.Standort).filter(models.Standort.kunde_id == kunde_id).all()
    return standorte

