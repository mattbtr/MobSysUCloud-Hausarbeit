from app.database import SessionLocal
from app import models

# Erstellt eine neue Session
session = SessionLocal()

session.query(models.Anlage).delete()
session.query(models.Abteilung).delete()
session.query(models.Standort).delete()
session.query(models.Kunde).delete()
session.commit()
