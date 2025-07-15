import pytest
from app import models

# Hilfs-Fixture: Erstelle eine Test-Kette bis zum Standort
@pytest.fixture
def test_standort(db_session):
    kunde = models.Kunde(name="Testkunde")
    db_session.add(kunde)
    db_session.commit()

    standort = models.Standort(name="Teststandort", adresse="Hauptstr.", kunde_id=kunde.id)
    db_session.add(standort)
    db_session.commit()

    return standort  # .id verfügbar als standort.id


def test_create_abteilung(client, test_standort):
    response = client.post("/abteilungen/", json={
        "name": "Instandhaltung",
        "standort_id": test_standort.id
    })
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Instandhaltung"
    assert data["standort_id"] == test_standort.id


def test_create_abteilung_invalid_standort(client):
    response = client.post("/abteilungen/", json={
        "name": "IT",
        "standort_id": 99999
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Standort nicht gefunden"


def test_get_all_abteilungen(client, db_session, test_standort):
    abt = models.Abteilung(name="Fertigung", standort_id=test_standort.id)
    db_session.add(abt)
    db_session.commit()

    response = client.get("/abteilungen/")
    assert response.status_code == 200
    data = response.json()
    assert any(a["name"] == "Fertigung" for a in data)


def test_get_single_abteilung(client, db_session, test_standort):
    abt = models.Abteilung(name="Qualität", standort_id=test_standort.id)
    db_session.add(abt)
    db_session.commit()

    response = client.get(f"/abteilungen/{abt.id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Qualität"


def test_get_abteilung_not_found(client):
    response = client.get("/abteilungen/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Abteilung nicht gefunden"


def test_update_abteilung(client, db_session, test_standort):
    abt = models.Abteilung(name="Altname", standort_id=test_standort.id)
    db_session.add(abt)
    db_session.commit()

    response = client.put(f"/abteilungen/{abt.id}", json={
        "name": "Neu",
        "standort_id": test_standort.id
    })
    assert response.status_code == 200
    assert response.json()["name"] == "Neu"


def test_update_abteilung_not_found(client, test_standort):
    response = client.put("/abteilungen/9999", json={
        "name": "Unbekannt",
        "standort_id": test_standort.id
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Abteilung nicht gefunden"


def test_delete_abteilung(client, db_session, test_standort):
    abt = models.Abteilung(name="Wird gelöscht", standort_id=test_standort.id)
    db_session.add(abt)
    db_session.commit()

    response = client.delete(f"/abteilungen/{abt.id}")
    assert response.status_code == 200
    assert response.json()["detail"] == "Abteilung gelöscht"

    # sicherstellen: nicht mehr abrufbar
    response = client.get(f"/abteilungen/{abt.id}")
    assert response.status_code == 404


def test_delete_abteilung_not_found(client):
    response = client.delete("/abteilungen/99999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Abteilung nicht gefunden"


def test_get_abteilungen_by_standort(client, db_session, test_standort):
    a1 = models.Abteilung(name="A1", standort_id=test_standort.id)
    a2 = models.Abteilung(name="A2", standort_id=test_standort.id)
    db_session.add_all([a1, a2])
    db_session.commit()

    response = client.get(f"/abteilungen/standort/{test_standort.id}")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    assert any(a["name"] == "A1" for a in data)
