from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Bericht(Base):
    __tablename__ = 'berichte'

    id = Column(Integer, primary_key=True, index=True)

    titel = Column(String, nullable=False)
    beschreibung = Column(Text, nullable=True)

    erstellt_am = Column(DateTime(timezone=True), server_default=func.now())

    # Verknüpfung zur Anlage (Pflicht)
    anlage_id = Column(Integer, ForeignKey('anlagen.id'), nullable=False)
    anlage = relationship("Anlage", back_populates="berichte")

    # Firebase-User-Infos (optional aber empfohlen)
    firebase_uid = Column(String, nullable=True)
    nutzer_name = Column(String, nullable=True)
    nutzer_email = Column(String, nullable=True)

    # Liste von Einträgen zum Bericht
    eintraege = relationship("Eintrag", back_populates="bericht", cascade="all, delete-orphan")
