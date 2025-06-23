from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/anlagen", tags=["Anlagen"])

@router.post("/", response_model=schemas.Anlage)
def create_anlage(anlage: schemas.AnlageCreate, db: Session = Depends(get_db)):
    abteilung = db.query(models.Abteilung).get(anlage.abteilung_id)
    if not abteilung:
        raise HTTPException(status_code=404, detail="Abteilung nicht gefunden")

    db_anlage = models.Anlage(**anlage.model_dump())
    db.add(db_anlage)
    db.commit()
    db.refresh(db_anlage)
    return db_anlage

@router.get("/", response_model=List[schemas.Anlage])
def get_anlagen(db: Session = Depends(get_db)):
    return db.query(models.Anlage).all()

@router.get("/{anlage_id}", response_model=schemas.Anlage)
def get_anlage(anlage_id: int, db: Session = Depends(get_db)):
    anlage = db.query(models.Anlage).get(anlage_id)
    if not anlage:
        raise HTTPException(status_code=404, detail="Anlage nicht gefunden")
    return anlage

@router.put("/{anlage_id}", response_model=schemas.Anlage)
def update_anlage(anlage_id: int, updated: schemas.AnlageCreate, db: Session = Depends(get_db)):
    anlage = db.query(models.Anlage).get(anlage_id)
    if not anlage:
        raise HTTPException(status_code=404, detail="Anlage nicht gefunden")

    for key, value in updated.model_dump().items():
        setattr(anlage, key, value)
    db.commit()
    return anlage

@router.delete("/{anlage_id}")
def delete_anlage(anlage_id: int, db: Session = Depends(get_db)):
    anlage = db.query(models.Anlage).get(anlage_id)
    if not anlage:
        raise HTTPException(status_code=404, detail="Anlage nicht gefunden")

    db.delete(anlage)
    db.commit()
    return {"detail": "Anlage gelöscht"}
