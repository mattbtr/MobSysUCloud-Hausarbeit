# Stammdaten des Datenmodells

from app.database import SessionLocal
from app import models

# Erstellt eine neue Session
session = SessionLocal()

# Hilfsfunktion, um doppelte Einträge zu vermeiden
def get_or_create(model, defaults=None, **kwargs):
    instance = session.query(model).filter_by(**kwargs).first()
    if instance:
        return instance
    else:
        params = dict((k, v) for k, v in kwargs.items())
        params.update(defaults or {})
        instance = model(**params)
        session.add(instance)
        session.commit()
        return instance

kunden_data = {
    "Klinik Nordwest": {
        "Station 3B": {
            "Kardiologie": ["Defibrillator Modell X", "EKG-Messgerät"],
            "Innere Medizin": ["Patientenmonitor"]
        },
        "OP-Zentrum": {
            "Anästhesie": ["Narkosegerät"],
            "Chirurgie": ["OP-Lampe", "Elektroskalpell"]
        }
    },
    "MedTech Zentrum": {
        "Intensivstation A": {
            "Intensivpflege": ["Beatmungsgerät", "Vitalmonitor", "Infusionspumpe"]
        },
        "Reha-Bereich": {
            "Physiotherapie": ["Therapieliege"]
        },
        "Labortrakt": {
            "Labortechnik": ["Blutanalysegerät", "Mikroskop"]
        }
    },
    "Städtisches Klinikum": {
        "Notaufnahme": {
            "Unfallchirurgie": ["Schockraum-Bett", "Monitoring-System"]
        },
        "Station C1": {
            "Geriatrie": ["Rollstuhl", "Patientenrufsystem", "Pflegebett"]
        }
    },
    "Zentrum für Radiologie": {
        "Radiologiezentrum Mitte": {
            "Röntgendiagnostik": ["Röntgengerät", "Bildspeicher"],
            "CT-Abteilung": ["CT-Scanner"],
            "MRT-Abteilung": ["MRT-Gerät"]
        }
    },
    "Klinik Sonnenhof": {
        "Therapiezentrum Süd": {
            "Ergotherapie": ["Handtherapie-Station"],
            "Psychosomatik": ["EEG-Monitor"]
        }
    }
}

for kundenname, standorte in kunden_data.items():
    kunde = get_or_create(models.Kunde, name=kundenname)

    for standortname, abteilungen in standorte.items():
        standort = get_or_create(models.Standort, name=standortname, kunde_id=kunde.id)

        for abteilungsname, anlagen in abteilungen.items():
            abteilung = get_or_create(models.Abteilung, name=abteilungsname, standort_id=standort.id)

            for anlage in anlagen:
                get_or_create(models.Anlage, name=anlage, abteilung_id=abteilung.id)

print("✅ Stammdaten erfolgreich eingefügt.")

# Schließt die Session
session.close()