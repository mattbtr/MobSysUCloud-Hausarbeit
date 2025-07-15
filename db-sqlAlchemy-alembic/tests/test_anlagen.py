import pytest
from app import models

# Hilfs-Fixture: Erstellt bis zur Abteilung
@pytest.fixture
def test_abteilung(db_session):
    kunde = models.Kunde(name="Testkunde")
    db_session.add(kunde)
    db_session.commit()

    standort = models.Standort(name="Teststandort", adresse="Straße 1", kunde_id=kunde.id)
    db_session.add(standort)
    db_session.commit()

    abteilung = models.Abteilung(name="Technik", standort_id=standort.id)
    db_session.add(abteilung)
    db_session.commit()

    return abteilung  # hat .id


def test_create_anlage(client, test_abteilung):
    response = client.post("/anlagen/", json={
        "name": "Anlage 1",
        "abteilung_id": test_abteilung.id
    })
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Anlage 1"
    assert data["abteilung_id"] == test_abteilung.id


def test_create_anlage_invalid_abteilung(client):
    response = client.post("/anlagen/", json={
        "name": "FehlendeAbteilung",
        "abteilung_id": 99999
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Abteilung nicht gefunden"


def test_get_all_anlagen(client, db_session, test_abteilung):
    anlage = models.Anlage(name="AnlageXY", abteilung_id=test_abteilung.id)
    db_session.add(anlage)
    db_session.commit()

    response = client.get("/anlagen/")
    assert response.status_code == 200
    assert any(a["id"] == anlage.id for a in response.json())


def test_get_single_anlage(client, db_session, test_abteilung):
    anlage = models.Anlage(name="EinzelAnlage", abteilung_id=test_abteilung.id)
    db_session.add(anlage)
    db_session.commit()

    response = client.get(f"/anlagen/{anlage.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "EinzelAnlage"


def test_get_anlage_not_found(client):
    response = client.get("/anlagen/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Anlage nicht gefunden"


def test_update_anlage(client, db_session, test_abteilung):
    anlage = models.Anlage(name="Vorher", abteilung_id=test_abteilung.id)
    db_session.add(anlage)
    db_session.commit()

    response = client.put(f"/anlagen/{anlage.id}", json={
        "name": "Nachher",
        "abteilung_id": test_abteilung.id,
    })
    assert response.status_code == 200
    assert response.json()["name"] == "Nachher"


def test_update_anlage_not_found(client, test_abteilung):
    response = client.put("/anlagen/9999", json={
        "name": "WirdNichtGefunden",
        "abteilung_id": test_abteilung.id
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Anlage nicht gefunden"


def test_delete_anlage(client, db_session, test_abteilung):
    anlage = models.Anlage(name="KillMe", abteilung_id=test_abteilung.id)
    db_session.add(anlage)
    db_session.commit()

    response = client.delete(f"/anlagen/{anlage.id}")
    assert response.status_code == 200
    assert response.json()["detail"] == "Anlage gelöscht"

    response = client.get(f"/anlagen/{anlage.id}")
    assert response.status_code == 404


def test_delete_anlage_not_found(client):
    response = client.delete("/anlagen/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Anlage nicht gefunden"


def test_get_anlagen_by_abteilung(client, db_session, test_abteilung):
    a1 = models.Anlage(name="Pumpe", abteilung_id=test_abteilung.id)
    a2 = models.Anlage(name="Motor", abteilung_id=test_abteilung.id)
    db_session.add_all([a1, a2])
    db_session.commit()

    response = client.get(f"/anlagen/abteilung/{test_abteilung.id}")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2
    assert any(a["name"] == "Pumpe" for a in data)
