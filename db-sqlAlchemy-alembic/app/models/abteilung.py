from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Abteilung(Base):
    __tablename__ = "abteilungen"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    standort_id = Column(Integer, ForeignKey("standorte.id", ondelete="CASCADE"))

    standort = relationship("Standort", backref="abteilungen")
