import pytest
from datetime import datetime, timezone
from app import models


# Hilfs-Fixture: Setup bis zur Anlage
@pytest.fixture
def test_anlage(db_session):
    kunde = models.Kunde(name="Testkunde")
    db_session.add(kunde)
    db_session.commit()

    standort = models.Standort(name="Hauptstandort", adresse="Straße 1", kunde_id=kunde.id)
    db_session.add(standort)
    db_session.commit()

    abteilung = models.Abteilung(name="Produktion", standort_id=standort.id)
    db_session.add(abteilung)
    db_session.commit()

    anlage = models.Anlage(name="Anlage X", abteilung_id=abteilung.id)
    db_session.add(anlage)
    db_session.commit()

    return {
        "kunde": kunde,
        "standort": standort,
        "abteilung": abteilung,
        "anlage": anlage
    }

#CRUD Tests für Bericht
def test_create_bericht(client, test_anlage):
    created_at = datetime.now(timezone.utc).isoformat()

    response = client.post("/berichte/", json={
        "titel": "Testbericht",
        "beschreibung": "Dies ist ein Bericht.",
        "anlage_id": test_anlage["anlage"].id,
        "erstellt_am": created_at
    })
    assert response.status_code == 200
    data = response.json()
    assert data["titel"] == "Testbericht"
    assert data["anlage_id"] == test_anlage["anlage"].id
    assert data["erstellt_am"].startswith(created_at[:19])


def test_get_berichte(client, db_session, test_anlage):
    bericht = models.Bericht(titel="Test", beschreibung="...", anlage_id=test_anlage["anlage"].id, erstellt_am=datetime.now(timezone.utc))
    db_session.add(bericht)
    db_session.commit()

    response = client.get("/berichte/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_single_bericht(client, db_session, test_anlage):
    bericht = models.Bericht(
        titel="Singlebericht",
        beschreibung="xyz",
        anlage_id=test_anlage["anlage"].id,
        erstellt_am=datetime.now(timezone.utc)
    )
    db_session.add(bericht)
    db_session.commit()

    response = client.get(f"/berichte/{bericht.id}")
    assert response.status_code == 200
    assert response.json()["titel"] == "Singlebericht"


def test_update_bericht(client, db_session, test_anlage):
    created_at = datetime.now(timezone.utc)

    bericht = models.Bericht(titel="Alter Bericht", beschreibung="alt", anlage_id=test_anlage["anlage"].id, erstellt_am=created_at)
    db_session.add(bericht)
    db_session.commit()

    updated_date = datetime.now(timezone.utc).isoformat()

    response = client.put(f"/berichte/{bericht.id}", json={
        "titel": "Neuer Bericht",
        "beschreibung": "neu",
        "anlage_id": test_anlage["anlage"].id,
        "erstellt_am": updated_date
    })
    assert response.status_code == 200
    assert response.json()["titel"] == "Neuer Bericht"
    assert response.json()["erstellt_am"].startswith(updated_date[:19])


def test_delete_bericht(client, db_session, test_anlage):
    bericht = models.Bericht(titel="Zu Löschen", beschreibung="x", anlage_id=test_anlage["anlage"].id, erstellt_am=datetime.now(timezone.utc))
    db_session.add(bericht)
    db_session.commit()

    response = client.delete(f"/berichte/{bericht.id}")
    assert response.status_code == 200
    assert response.json()["detail"] == "Bericht gelöscht"

    # Sicherstellen, dass löschen funktioniert hat:
    response = client.get(f"/berichte/{bericht.id}")
    assert response.status_code == 404


def test_get_stammdaten(client, db_session, test_anlage):
    bericht = models.Bericht(titel="Bericht", beschreibung="x", anlage_id=test_anlage["anlage"].id, erstellt_am=datetime.now(timezone.utc))
    db_session.add(bericht)
    db_session.commit()

    response = client.get(f"/berichte/{bericht.id}/stammdaten")
    assert response.status_code == 200
    stammdaten = response.json()
    assert stammdaten["kunde"]["name"] == "Testkunde"


def test_get_eintraege_empty(client, db_session, test_anlage):
    bericht = models.Bericht(titel="Bericht ohne Einträge", beschreibung="leer", anlage_id=test_anlage["anlage"].id, erstellt_am=datetime.now(timezone.utc))
    db_session.add(bericht)
    db_session.commit()

    response = client.get(f"/berichte/{bericht.id}/eintraege")
    assert response.status_code == 200
    assert response.json() == []
