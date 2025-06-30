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

# Adressen für Standorte (fiktiv)
standort_adressen = {
    "Station 3B": "Klinikstraße 1, 12345 Frankfurt",
    "OP-Zentrum": "Chirurgenweg 5, 12345 Frankfurt",
    "Intensivstation A": "MedTech Allee 7, 67890 Berlin",
    "Reha-Bereich": "Therapiepfad 12, 67890 Berlin",
    "Labortrakt": "Analysenstraße 4, 67890 Berlin",
    "Notaufnahme": "Akutgasse 9, 54321 Hamburg",
    "Station C1": "Seniorenring 10, 54321 Hamburg",
    "Radiologiezentrum Mitte": "Röntgenstraße 8, 11111 Köln",
    "Therapiezentrum Süd": "Sonnenweg 22, 98765 München"
}

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
        adresse = standort_adressen.get(standortname, "Unbekannte Adresse")
        standort = get_or_create(
            models.Standort,
            name=standortname,
            kunde_id=kunde.id,
            defaults={"adresse": adresse}
        )

        for abteilungsname, anlagen in abteilungen.items():
            abteilung = get_or_create(models.Abteilung, name=abteilungsname, standort_id=standort.id)

            for anlage in anlagen:
                get_or_create(models.Anlage, name=anlage, abteilung_id=abteilung.id)

print("✅ Stammdaten mit Adressen erfolgreich eingefügt.")
session.close()
