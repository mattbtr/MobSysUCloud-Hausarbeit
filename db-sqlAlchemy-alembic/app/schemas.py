# app/schemas.py
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class KundeBase(BaseModel):
    name: str
    adresse: str

class KundeCreate(KundeBase):
    pass

class Kunde(KundeBase):
    id: int
    created_at: datetime

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
    created_at: datetime

    class Config:
        from_attributes = True


class AbteilungBase(BaseModel):
    name: str
    standort_id: int

class AbteilungCreate(AbteilungBase):
    pass

class Abteilung(AbteilungBase):
    id:int
    created_at: datetime

    class Config:
        from_attributes = True


class AnlageBase(BaseModel):
    name: str
    abteilung_id: int

class AnlageCreate(AnlageBase):
    pass

class Anlage(AnlageBase):
    id:int
    created_at: datetime

    class Config:
        from_attributes = True


class BerichtBase(BaseModel):
    titel: str
    inhalt: str
    datum: datetime
    anlage_id: int

class BerichtCreate(BerichtBase):
    pass

class Bericht(BerichtBase):
    id:int
    created_at: datetime

    class Config:
        from_attributes = True