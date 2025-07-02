import json
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas
from fastapi import Form, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
import os
import uuid

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

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


@router.get("/{bericht_id}/eintraege", response_model=List[schemas.Eintrag])
def get_eintraege(bericht_id: int, db: Session = Depends(get_db)):
    eintraege = db.query(models.Eintrag).filter(models.Eintrag.bericht_id == bericht_id).all()
    return eintraege

@router.get("/{bericht_id}/stammdaten")
def get_stammdaten(bericht_id: int, db: Session = Depends(get_db)):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")

    anlage = db.query(models.Anlage).get(bericht.anlage_id)
    abteilung = db.query(models.Abteilung).get(anlage.abteilung_id)
    standort = db.query(models.Standort).get(abteilung.standort_id)
    kunde = db.query(models.Kunde).get(standort.kunde_id)

    return JSONResponse({
        "kunde": {"id": kunde.id, "name": kunde.name},
        "standort": {"id": standort.id, "name": standort.name, "adresse": standort.adresse},
        "abteilung": {"id": abteilung.id, "name": abteilung.name},
        "anlage": {"id": anlage.id, "name": anlage.name},
    })


@router.post("/{bericht_id}/eintraege/json")
async def upload_json_eintraege(
    bericht_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        print("Bericht nicht gefunden")
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")

    try:
        content = await file.read()
        print(f"Dateiinhalt: {content}")  # Debug-Ausgabe
        eintraege_data = json.loads(content)
        for eintrag_data in eintraege_data:
            print(f"Verarbeite Eintrag: {eintrag_data}")
            db_eintrag = models.Eintrag(
                titel=eintrag_data.get("titel"),
                beschreibung=eintrag_data.get("beschreibung"),
                wert=eintrag_data.get("wert"),
                bericht_id=bericht_id,
            )
            db.add(db_eintrag)
        db.commit()
        return {"detail": "Einträge gespeichert"}
    except json.JSONDecodeError:
        print(f"JSONDecodeError: {e}")
        raise HTTPException(status_code=400, detail="Ungültige JSON-Datei")
    except Exception as e:
        db.rollback()
        print(f"Exception: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{bericht_id}/eintraege/image")
async def upload_image_eintrag(
    bericht_id: int,
    titel: str = Form(...),
    beschreibung: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    bericht = db.query(models.Bericht).get(bericht_id)
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")

    try:
        # Bild speichern
        filename = f"{uuid.uuid4()}_{file.filename}"
        filepath = os.path.join(UPLOAD_DIR, filename)
        with open(filepath, "wb") as buffer:
            buffer.write(await file.read())

        # Eintrag speichern
        db_eintrag = models.Eintrag(
            titel=titel,
            beschreibung=beschreibung,
            wert=f"/uploads/{filename}",  # <-- Bild-URL im Feld wert
            bericht_id=bericht_id,
        )
        db.add(db_eintrag)
        db.commit()
        return {"detail": "Bild gespeichert"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))