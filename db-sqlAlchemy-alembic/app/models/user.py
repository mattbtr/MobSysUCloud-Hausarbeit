#from sqlalchemy import Column, Integer, String, DateTime
#from datetime import datetime
#from app.database import Base

#class User(Base):
#    __tablename__ = "user"
#
#    id = Column(Integer, primary_key=True, index=True)
#    uid = Column(String, unique=True, nullable=False)  # Firebase UID
#    name = Column(String)
#    email = Column(String)
#    rolle = Column(String)
#    abteilung = Column(String)
#    erstellt_am = Column(DateTime, default=datetime.utcnow)
#