# app/models/eintrag.py
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Eintrag(Base):
    __tablename__ = "eintraege"

    id           = Column(Integer, primary_key=True, index=True)
    titel        = Column(String, nullable=False)
    beschreibung = Column(Text, nullable=True)

    # z. B. Messwert, Status-Code, Bild-URL usw.
    wert         = Column(String, nullable=True)

    erstellt_am  = Column(DateTime(timezone=True), server_default=func.now())

    # FK zum Bericht
    bericht_id   = Column(Integer, ForeignKey("berichte.id", ondelete="CASCADE"), nullable=False)
    bericht      = relationship("Bericht", back_populates="eintraege")
