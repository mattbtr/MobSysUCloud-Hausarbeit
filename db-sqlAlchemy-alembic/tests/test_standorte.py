import pytest
from app import models

@pytest.fixture
def test_kunde(db_session):
    kunde = models.Kunde(name="Kunde mit Standort")
    db_session.add(kunde)
    db_session.commit()
    return kunde


def test_create_standort(client, test_kunde):
    response = client.post("/standorte/", json={
        "name": "Zentrale",
        "adresse": "Industriestraße 1",
        "kunde_id": test_kunde.id
    })
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Zentrale"
    assert data["kunde_id"] == test_kunde.id


def test_create_standort_with_invalid_kunde(client):
    response = client.post("/standorte/", json={
        "name": "Unbekannt",
        "adresse": "Straße 404",
        "kunde_id": 9999
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Kunde nicht gefunden"


def test_get_all_standorte(client, db_session, test_kunde):
    # Standort erstellen
    standort = models.Standort(name="Werk 1", adresse="Straße A", kunde_id=test_kunde.id)
    db_session.add(standort)
    db_session.commit()

    response = client.get("/standorte/")
    assert response.status_code == 200
    data = response.json()
    assert any(s["id"] == standort.id for s in data)


def test_get_single_standort(client, db_session, test_kunde):
    standort = models.Standort(name="Werk 2", adresse="Straße B", kunde_id=test_kunde.id)
    db_session.add(standort)
    db_session.commit()

    response = client.get(f"/standorte/{standort.id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Werk 2"


def test_get_standort_not_found(client):
    response = client.get("/standorte/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Standort nicht gefunden"


def test_update_standort(client, db_session, test_kunde):
    standort = models.Standort(name="Altname", adresse="Altstraße", kunde_id=test_kunde.id)
    db_session.add(standort)
    db_session.commit()

    response = client.put(f"/standorte/{standort.id}", json={
        "name": "Neu",
        "adresse": "Neustraße",
        "kunde_id": test_kunde.id
    })
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Neu"
    assert data["adresse"] == "Neustraße"


def test_update_standort_not_found(client, test_kunde):
    response = client.put("/standorte/9999", json={
        "name": "Neu",
        "adresse": "Neuestraße",
        "kunde_id": test_kunde.id
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Standort nicht gefunden"


def test_delete_standort(client, db_session, test_kunde):
    standort = models.Standort(name="Zu löschen", adresse="X", kunde_id=test_kunde.id)
    db_session.add(standort)
    db_session.commit()

    response = client.delete(f"/standorte/{standort.id}")
    assert response.status_code == 200
    assert response.json()["detail"] == "Standort gelöscht"

    # Prüfen ob gelöscht
    response = client.get(f"/standorte/{standort.id}")
    assert response.status_code == 404


def test_delete_standort_not_found(client):
    response = client.delete("/standorte/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Standort nicht gefunden"


def test_get_standorte_by_kunde(client, db_session, test_kunde):
    s1 = models.Standort(name="S1", adresse="A1", kunde_id=test_kunde.id)
    s2 = models.Standort(name="S2", adresse="A2", kunde_id=test_kunde.id)
    db_session.add_all([s1, s2])
    db_session.commit()

    response = client.get(f"/standorte/kunde/{test_kunde.id}")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    assert any(s["name"] == "S1" for s in data)
