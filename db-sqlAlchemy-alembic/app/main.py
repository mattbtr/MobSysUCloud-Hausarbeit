from fastapi import FastAPI
from app.database import engine
from app import models

# Nur einmal nötig, falls nicht Alembic benutzt wird
# models.Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def root():
    return {"msg": "Backend läuft!"}