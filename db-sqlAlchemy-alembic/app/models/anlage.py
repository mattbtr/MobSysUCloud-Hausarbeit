from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Anlage(Base):
    __tablename__ = "anlagen"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    abteilung_id = Column(Integer, ForeignKey("abteilungen.id", ondelete="CASCADE"))

    abteilung = relationship("Abteilung", backref="anlagen")
    berichte = relationship("Bericht", back_populates="anlage", cascade="all, delete-orphan")
