# app/models.py
from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base


class Kunde(Base):
    __tablename__ = "kunden"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
