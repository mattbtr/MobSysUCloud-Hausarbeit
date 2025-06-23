from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Standort(Base):
    __tablename__ = "standorte"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    adresse = Column(String)
    kunde_id = Column(Integer, ForeignKey("kunden.id", ondelete="CASCADE"))

    kunde = relationship("Kunde", backref="standorte")
