# test_db.py
from app.database import engine, Base

# Nur zum Testen: Tabelle erstellen
Base.metadata.create_all(bind=engine)
print("Connection works.")
