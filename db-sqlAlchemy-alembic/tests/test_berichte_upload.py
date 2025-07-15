import io
import json
import pytest
from datetime import datetime, timezone
from app import models

@pytest.fixture
def test_bericht(db_session, test_anlage):
    bericht = models.Bericht(titel="UploadTest", beschreibung="Für Upload", anlage_id=test_anlage["anlage"].id, erstellt_am=datetime.now(timezone.utc))
    db_session.add(bericht)
    db_session.commit()
    return bericht

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

def test_upload_json_eintraege(client, test_bericht):
    # Beispiel-Inhalt für Eintrags-JSON
    entries = [
        {"titel": "Eintrag 1", "beschreibung": "Text 1", "wert": "Wert 1", "bericht_id": test_bericht.id},
        {"titel": "Eintrag 2", "beschreibung": "Text 2", "wert": "Wert 2", "bericht_id": test_bericht.id},
    ]
    file_content = json.dumps(entries).encode()
    file = io.BytesIO(file_content)
    file.name = "eintraege.json"  # FastAPI/TestClient nutzt diesen Namenshack für Files

    response = client.post(
        f"/berichte/{test_bericht.id}/eintraege/json",
        files={"file": ("eintraege.json", file, "application/json")}
    )
    assert response.status_code == 200
    # Einträge sollten jetzt vorhanden sein
    response = client.get(f"/berichte/{test_bericht.id}/eintraege")
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 2
    assert any(e["titel"] == "Eintrag 1" for e in data)

def test_upload_json_eintraege_invalidjson(client, test_bericht):
    file = io.BytesIO(b"nicht-json!")
    file.name = "falsch.json"

    response = client.post(
        f"/berichte/{test_bericht.id}/eintraege/json",
        files={"file": ("falsch.json", file, "application/json")}
    )
    assert response.status_code == 400
    assert "Ungültige JSON-Datei" in response.json()["detail"]

def test_upload_json_eintraege_bericht_not_found(client):
    entries = [{"titel": "Eintrag", "beschreibung": "x", "wert": "y"}]
    file_content = json.dumps(entries).encode()
    file = io.BytesIO(file_content)
    file.name = "eintraege.json"

    response = client.post(
        "/berichte/9999/eintraege/json",
        files={"file": ("eintraege.json", file, "application/json")}
    )
    assert response.status_code == 404
    assert "Bericht nicht gefunden" in response.json()["detail"]

def test_upload_image_eintrag(client, test_bericht):
    # Dummy-Bilddatei erzeugen (1x1 px PNG)
    img_bytes = (
        b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01'
        b'\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\nIDATx\xdac`\x00\x00\x00\x02\x00\x01'
        b'\xe2!\xbc\x33\x00\x00\x00\x00IEND\xaeB`\x82'
    )
    file = io.BytesIO(img_bytes)
    file.name = "test.png"
    data = {
        "titel": (None, "Bildtitel"),
        "beschreibung": (None, "Bildbeschreibung"),
        "file": ("test.png", file, "image/png"),
    }

    response = client.post(f"/berichte/{test_bericht.id}/eintraege/image", files=data)
    assert response.status_code == 200
    assert response.json()["detail"] == "Bild gespeichert"

    # Eintrag sollte angelegt sein:
    response = client.get(f"/berichte/{test_bericht.id}/eintraege")
    data = response.json()
    assert any(e["titel"] == "Bildtitel" and e["wert"].endswith(".png") for e in data)

def test_upload_image_eintrag_bericht_not_found(client):
    img_bytes = b'\x89PNG\r\n\x1a\n\x00\x00...'
    file = io.BytesIO(img_bytes)
    file.name = "beispiel.png"
    data = {
        "titel": (None, "foobar"),
        "beschreibung": (None, "desc"),
        "file": ("beispiel.png", file, "image/png"),
    }
    response = client.post("/berichte/9999/eintraege/image", files=data)
    assert response.status_code == 404
    assert "Bericht nicht gefunden" in response.json()["detail"]
