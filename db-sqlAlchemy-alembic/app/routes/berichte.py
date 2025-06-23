from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/berichte", tags=["Berichte"])

@router.post("/", response_model=schemas.Bericht)
def create_bericht(bericht: schemas.BerichtCreate, db: Session = Depends(get_db)):
    anlage = db.query(models.Anlage).get(bericht.anlage_id)
    if not anlage:
        raise HTTPException(status_code=404, detail="Anlage nicht gefunden")

    db_bericht = models.Bericht(**bericht.model_dump())
    db.add(db_bericht)
    db.commit()
    db.refresh(db_bericht)
    return db_bericht

@router.get("/", response_model=List[schemas.Bericht])
def get_berichte(db: Session = Depends(get_db)):
    return db.query(models.Bericht).all()

@router.get("/{bericht_id}", response_model=schemas.Bericht)
def get_bericht(bericht_id: int, db: Session = Depends(get_db)):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")
    return bericht

@router.put("/{bericht_id}", response_model=schemas.Bericht)
def update_bericht(bericht_id: int, updated: schemas.BerichtCreate, db: Session = Depends(get_db)):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")

    for key, value in updated.model_dump().items():
        setattr(bericht, key, value)
    db.commit()
    return bericht

@router.delete("/{bericht_id}")
def delete_bericht(bericht_id: int, db: Session = Depends(get_db)):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")

    db.delete(bericht)
    db.commit()
    return {"detail": "Bericht gelöscht"}
