from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/abteilungen", tags=["Abteilungen"])

@router.post("/", response_model=schemas.Abteilung)
def create_abteilung(abteilung: schemas.AbteilungCreate, db: Session = Depends(get_db)):
    standort = db.query(models.Standort).get(abteilung.standort_id)
    if not standort:
        raise HTTPException(status_code=404, detail="Standort nicht gefunden")

    db_abteilung = models.Abteilung(**abteilung.model_dump())
    db.add(db_abteilung)
    db.commit()
    db.refresh(db_abteilung)
    return db_abteilung

@router.get("/", response_model=List[schemas.Abteilung])
def get_abteilungen(db: Session = Depends(get_db)):
    return db.query(models.Abteilung).all()

@router.get("/{abteilung_id}", response_model=schemas.Abteilung)
def get_abteilung(abteilung_id: int, db: Session = Depends(get_db)):
    abteilung = db.query(models.Abteilung).get(abteilung_id)
    if not abteilung:
        raise HTTPException(status_code=404, detail="Abteilung nicht gefunden")
    return abteilung

@router.put("/{abteilung_id}", response_model=schemas.Abteilung)
def update_abteilung(abteilung_id: int, updated: schemas.AbteilungCreate, db: Session = Depends(get_db)):
    abteilung = db.query(models.Abteilung).get(abteilung_id)
    if not abteilung:
        raise HTTPException(status_code=404, detail="Abteilung nicht gefunden")

    for key, value in updated.model_dump().items():
        setattr(abteilung, key, value)
    db.commit()
    return abteilung

@router.delete("/{abteilung_id}")
def delete_abteilung(abteilung_id: int, db: Session = Depends(get_db)):
    abteilung = db.query(models.Abteilung).get(abteilung_id)
    if not abteilung:
        raise HTTPException(status_code=404, detail="Abteilung nicht gefunden")

    db.delete(abteilung)
    db.commit()
    return {"detail": "Abteilung gelöscht"}


@router.get("/standort/{standort_id}", response_model=List[schemas.Abteilung])
def get_abteilungen_by_standort(standort_id: int, db: Session = Depends(get_db)):
    abteilungen = db.query(models.Abteilung).filter(models.Abteilung.standort_id == standort_id).all()
    return abteilungen