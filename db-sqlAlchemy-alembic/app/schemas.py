# app/schemas.py
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class KundeBase(BaseModel):
    name: str

class KundeCreate(KundeBase):
    pass

class Kunde(KundeBase):
    id: int

    class Config:
        from_attributes = True


class StandortBase(BaseModel):
    name: str
    adresse: str
    kunde_id: int

class StandortCreate(StandortBase):
    pass

class Standort(StandortBase):
    id: int

    class Config:
        from_attributes = True


class AbteilungBase(BaseModel):
    name: str
    standort_id: int

class AbteilungCreate(AbteilungBase):
    pass

class Abteilung(AbteilungBase):
    id:int

    class Config:
        from_attributes = True


class AnlageBase(BaseModel):
    name: str
    abteilung_id: int

class AnlageCreate(AnlageBase):
    pass

class Anlage(AnlageBase):
    id:int

    class Config:
        from_attributes = True


class BerichtBase(BaseModel):
    titel: str
    beschreibung: str
    anlage_id: int
    erstellt_am: datetime

class BerichtCreate(BerichtBase):
    pass

class Bericht(BerichtBase):
    id:int
    erstellt_am: datetime

    class Config:
        from_attributes = True

class EintragBase(BaseModel):
    titel: str
    beschreibung: Optional[str] = None
    wert: Optional[str] = None
    bericht_id: int

class EintragCreate(EintragBase):
    pass

class Eintrag(EintragBase):
    id: int
    erstellt_am: datetime

    class Config:
        from_attributes = True


class EmailRequest(BaseModel):
    recipient: EmailStr