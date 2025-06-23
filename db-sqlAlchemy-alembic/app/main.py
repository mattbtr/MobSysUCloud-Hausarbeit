from fastapi import FastAPI
from app.database import engine
from app import models
#from app.firebase_auth import firebase_auth_setup
from app.routes import kunden, standorte, abteilungen, anlagen, berichte

# Nur einmal nötig, falls nicht Alembic benutzt wird
# models.Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def root():
    return {"msg": "Backend läuft!"}

app.include_router(kunden.router)
app.include_router(standorte.router)
app.include_router(abteilungen.router)
app.include_router(anlagen.router)
app.include_router(berichte.router)
