import pytest
from app import models

def test_create_kunde(client):
    response = client.post("/kunden/", json={"name": "Testkunde"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Testkunde"
    assert "id" in data

def test_get_all_kunden(client, db_session):
    # Einen Kunden anlegen
    kunde = models.Kunde(name="Max Muster")
    db_session.add(kunde)
    db_session.commit()

    response = client.get("/kunden/")
    assert response.status_code == 200
    kunden = response.json()
    assert isinstance(kunden, list)
    assert any(k["name"] == "Max Muster" for k in kunden)

def test_get_single_kunde(client, db_session):
    kunde = models.Kunde(name="Anna Beispiel")
    db_session.add(kunde)
    db_session.commit()
    kunde_id = kunde.id

    response = client.get(f"/kunden/{kunde_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Anna Beispiel"

def test_get_kunde_not_found(client):
    response = client.get("/kunden/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Kunde nicht gefunden"

def test_update_kunde(client, db_session):
    kunde = models.Kunde(name="Old Name")
    db_session.add(kunde)
    db_session.commit()
    kunde_id = kunde.id

    response = client.put(f"/kunden/{kunde_id}", json={"name": "New Name"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "New Name"

def test_update_kunde_not_found(client):
    response = client.put("/kunden/9999", json={"name": "New Name"})
    assert response.status_code == 404
    assert response.json()["detail"] == "Kunde nicht gefunden"

def test_delete_kunde(client, db_session):
    kunde = models.Kunde(name="ToDelete")
    db_session.add(kunde)
    db_session.commit()
    kunde_id = kunde.id

    response = client.delete(f"/kunden/{kunde_id}")
    assert response.status_code == 200
    assert response.json()["detail"] == "Kunde gelöscht"

    # sicherstellen, dass Kunde gelöscht wurde
    response = client.get(f"/kunden/{kunde_id}")
    assert response.status_code == 404

def test_delete_kunde_not_found(client):
    response = client.delete("/kunden/9999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Kunde nicht gefunden"
