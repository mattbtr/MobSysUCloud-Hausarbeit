# 📋 Kundendokumentation-Builder

Ein Cross-Plattform-System zur Erstellung technischer Berichte inkl. strukturierter Datenerfassung, Bild-Upload und PDF-Export. Die Lösung richtet sich an Außendiensttechniker und ermöglicht die einfache Erstellung, Verwaltung und Archivierung von Berichten über Kundenanlagen.

---

## Features

- **Flutter Mobile App** mit Kameraanbindung, Daten-/Bilderfassung
- **Authentifizierung** (OAuth2/JWT-basiert) ????
- **Offline-Modus** mit Synchronisierung bei Verbindung
- **PDF-Erzeugung** aus strukturierten Daten + Bildern (z. B. via ReportLab) ????
- **Hierarchisches Datenmodell**: Kunde → Standort → Abteilung → Anlage → Bericht
- **Optionaler E-Mail-Versand** von Berichten
- **Cloud-/Container-ready** via Docker
- **CI/CD-Pipeline** mit GitHub Actions
- **Tests**: Unit + Integration (Backend & App)

---

## Architektur

![Architekturdiagramm](docs/architecture.png)

- **Frontend**: Flutter (Android/iOS)
- **Backend**: FastAPI (Python) ????
- **Datenbank**: PostgreSQL ????
- **PDF-Erstellung**: ReportLab oder LaTeX (Microservice-Option)
- **Containerisierung**: Docker, optional Docker Compose

---

## Installation & Setup

### Voraussetzungen

- Docker & Docker Compose
- Flutter SDK
- Python 3.11+
- Git

### Backend Setup (lokal)

- cd backend/
- python3 -m venv venv
- source venv/bin/activate
- pip install -r requirements.txt
- uvicorn main:app --reload

### Docker (Backend + DB)

- docker-compose up --build

### Flutter App starten

- cd app/
- flutter pub get
- flutter run

## Datenmodell

Hierarchische Struktur:

- Kunde
  - Standort
    - Abteilung
      - Anlage
        - Bericht (mit Bildern, Daten, Metadaten)

Jeder Bericht enthält strukturierte Daten (z. B. Checklisten), Text, Bilder und wird als PDF exportiert.

## Dokumentation

Alle relevanten Unterlagen im `docs/`-Ordner:

- `architecture.drawio` – Architekturdiagramm
- `user_stories.md` – User Stories
- `data_model.md` – Datenbankmodell
- `workflows.md` – typische Nutzungsabläufe
