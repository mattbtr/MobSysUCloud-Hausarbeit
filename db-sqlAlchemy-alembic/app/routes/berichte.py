import json
import tempfile
from fastapi import APIRouter, Depends, HTTPException, Response, BackgroundTasks
from fastapi.responses import JSONResponse
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app import models, schemas
from fastapi import Form, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
import os
import uuid
import requests
from reportlab.lib.utils import ImageReader
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import io
from app.schemas import EmailRequest


router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

router = APIRouter(prefix="/berichte", tags=["Berichte"])

from fastapi_mail import ConnectionConfig

conf = ConnectionConfig(
    MAIL_USERNAME = "kundendokumentation@gmail.com",
    MAIL_PASSWORD = "qmrg ozmw jgth cqqc",
    MAIL_FROM = "kundendokumentation@gmail.com",
    MAIL_PORT = 587,
    MAIL_SERVER = "smtp.gmail.com",
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
    USE_CREDENTIALS = True
)


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


@router.get("/{bericht_id}/export/pdf")
def export_bericht_pdf(bericht_id: int, db: Session = Depends(get_db)):
    # Bericht und Einträge aus der DB laden
    bericht = db.query(models.Bericht).filter(models.Bericht.id == bericht_id).first()
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")
    
    eintraege = db.query(models.Eintrag).filter(models.Eintrag.bericht_id == bericht_id).all()

    # PDF im Speicher erzeugen
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4

    # Titel und Metadaten
    c.setFont("Helvetica-Bold", 18)
    c.drawString(50, height - 50, f"Bericht: {bericht.titel}")
    c.setFont("Helvetica", 12)
    c.drawString(50, height - 80, f"Erstellt am: {bericht.erstellt_am.strftime('%d.%m.%Y %H:%M')}")
    c.drawString(50, height - 100, f"Beschreibung: {bericht.beschreibung}")

    y = height - 140
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, y, "Einträge:")
    y -= 20

    c.setFont("Helvetica", 12)
    for eintrag in eintraege:
        if y < 120:
            c.showPage()
            y = height - 50
            c.setFont("Helvetica", 12)
        c.drawString(65, y, f"- {eintrag.titel}")
        y -= 18
        if eintrag.beschreibung:
            c.drawString(80, y, f"Beschreibung: {eintrag.beschreibung}")
            y -= 16
        if eintrag.wert:
            # Prüfe, ob Wert ein Bildpfad ist
            if any(eintrag.wert.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".png"]):
                bild_url = f"http://192.168.0.108:8000{eintrag.wert}" if eintrag.wert.startswith("/uploads/") else eintrag.wert
                try:
                    response = requests.get(bild_url, timeout=10)
                    if response.status_code == 200:
                        img = ImageReader(io.BytesIO(response.content))
                        c.drawImage(img, 80, y-110, width=150, height=100)
                        y -= 110
                    else:
                        c.drawString(80, y, f"[Bild konnte nicht geladen werden: {bild_url}]")
                        y -= 16
                except Exception as e:
                    c.drawString(80, y, f"[Bild-Fehler: {e}]")
                    y -= 16
            else:
                c.drawString(80, y, f"Wert: {eintrag.wert}")
                y -= 16
        y -= 4

    c.save()
    buffer.seek(0)
    pdf_bytes = buffer.read()

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"inline; filename=bericht_{bericht_id}.pdf"
        }
    )

async def send_pdf_email(
    recipient: str,
    subject: str,
    body: str,
    pdf_bytes: bytes,
    filename: str
):
    
    # Temporäre Datei anlegen
    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
        tmp_file.write(pdf_bytes)
        tmp_file_path = tmp_file.name
    """
    Versendet eine E-Mail mit PDF-Anhang an den Empfänger.
    """
    try:
        message = MessageSchema(
            subject=subject,
            recipients=[recipient],  # Muss eine Liste sein!
            body=body,
            attachments=[tmp_file_path],  # Pfad zur temporären Datei
            subtype="plain"
    )
        fm = FastMail(conf)
        await fm.send_message(message)
    finally:
        # Temporäre Datei löschen
        if os.path.exists(tmp_file_path):
            os.remove(tmp_file_path)

@router.post("/{bericht_id}/export/email")
async def export_pdf_and_send_email(
    bericht_id: int,
    request: EmailRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    # Bericht und Einträge aus der DB laden
    bericht = db.query(models.Bericht).filter(models.Bericht.id == bericht_id).first()
    if not bericht:
        raise HTTPException(status_code=404, detail="Bericht nicht gefunden")
    
    eintraege = db.query(models.Eintrag).filter(models.Eintrag.bericht_id == bericht_id).all()

    # PDF generieren (Beispiel)
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4
    
    # Titel und Metadaten
    c.setFont("Helvetica-Bold", 18)
    c.drawString(50, height - 50, f"Bericht: {bericht.titel}")
    c.setFont("Helvetica", 12)
    c.drawString(50, height - 80, f"Erstellt am: {bericht.erstellt_am.strftime('%d.%m.%Y %H:%M')}")
    c.drawString(50, height - 100, f"Beschreibung: {bericht.beschreibung}")

    y = height - 140
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, y, "Einträge:")
    y -= 20

    c.setFont("Helvetica", 12)
    for eintrag in eintraege:
        if y < 120:
            c.showPage()
            y = height - 50
            c.setFont("Helvetica", 12)
        c.drawString(65, y, f"- {eintrag.titel}")
        y -= 18
        if eintrag.beschreibung:
            c.drawString(80, y, f"Beschreibung: {eintrag.beschreibung}")
            y -= 16
        if eintrag.wert:
            # Prüfe, ob Wert ein Bildpfad ist
            if any(eintrag.wert.lower().endswith(ext) for ext in [".jpg", ".jpeg", ".png"]):
                if eintrag.wert.startswith("/uploads/"):
                    bild_url = os.path.join("uploads", os.path.basename(eintrag.wert))
                    if os.path.exists(bild_url):
                        img = ImageReader(bild_url)
                        c.drawImage(img, 80, y-110, width=150, height=100)
                        y -= 110
                    else:
                        c.drawString(80, y, f"[Bild konnte nicht geladen werden: {bild_url}]")
                        y -= 16
                
                else:
                    c.drawString(80, y, f"Wert: {eintrag.wert}")
                y -= 16
        y -= 4

    c.save()
    buffer.seek(0)
    pdf_bytes = buffer.read()

    # E-Mail-Versand als Background-Task starten
    subject = "Ihr Bericht als PDF"
    body = "Im Anhang finden Sie den Bericht als PDF."
    filename = f"bericht_{bericht_id}.pdf"
    background_tasks.add_task(
        send_pdf_email,
        request.recipient,
        subject,
        body,
        pdf_bytes,
        filename
    )

    return {"detail": f"PDF wird an {request.recipient} im Hintergrund gesendet."}