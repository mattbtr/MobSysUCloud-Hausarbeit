import pytest
from datetime import datetime, timezone
from app import models

@pytest.fixture
def test_bericht_mit_eintrag(db_session, test_anlage):
    bericht = models.Bericht(
        titel="PDF-Test",
        beschreibung="Für PDF-Export",
        anlage_id=test_anlage["anlage"].id,
        erstellt_am=datetime.now(timezone.utc)
    )
    db_session.add(bericht)
    db_session.commit()

    eintrag = models.Eintrag(
        titel="PDF-Eintrag",
        beschreibung="" ,
        wert="Testwert",
        bericht_id=bericht.id
    )
    db_session.add(eintrag)
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

def test_export_bericht_pdf(client, test_bericht_mit_eintrag):
    response = client.get(f"/berichte/{test_bericht_mit_eintrag.id}/export/pdf")

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert response.headers["content-disposition"].startswith("inline")
    pdf_bytes = response.content
    assert pdf_bytes.startswith(b"%PDF"), "Antwort ist keine gültige PDF-Datei"
    assert len(pdf_bytes) > 100  # pdfs sind i.d.R. > 100 Byte

def test_export_bericht_pdf_not_found(client):
    response = client.get("/berichte/9999/export/pdf")
    assert response.status_code == 404
    assert "Bericht nicht gefunden" in response.json()["detail"]
