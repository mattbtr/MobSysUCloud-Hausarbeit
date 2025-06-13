-- Users
INSERT INTO users (id, email, password_hash, role, created_at)
VALUES
  (uuid_generate_v4(), 'admin@example.com', 'hash123', 'admin', NOW()),
  (uuid_generate_v4(), 'tech@example.com', 'hash456', 'editor', NOW());

-- Kunden
INSERT INTO kunden (name, user_id)
VALUES
  ('MediTech GmbH', (SELECT id FROM users WHERE email = 'admin@example.com'));

-- Standorte
INSERT INTO standorte (name, adresse, kunde_id)
VALUES
  ('Zentrale Berlin', 'Musterstraße 1, 10115 Berlin', (SELECT id FROM kunden WHERE name = 'MediTech GmbH'));

-- Abteilungen
INSERT INTO abteilungen (name, standort_id)
VALUES
  ('Wartung', (SELECT id FROM standorte WHERE name = 'Zentrale Berlin'));

-- Anlagen
INSERT INTO anlagen (name, seriennummer, abteilung_id)
VALUES
  ('Sterilisator XY-3000', 'SN123456', (SELECT id FROM abteilungen WHERE name = 'Wartung'));

-- Berichte
INSERT INTO berichte (anlage_id, user_id, titel, inhalt, datum, pdf_path, created_at)
VALUES (
  (SELECT id FROM anlagen WHERE name = 'Sterilisator XY-3000'),
  (SELECT id FROM users WHERE email = 'tech@example.com'),
  'Wartungsbericht Juni',
  'Sterilisator überprüft, Filter ersetzt. Keine Auffälligkeiten.',
  '2025-06-01',
  '/pdfs/bericht_001.pdf',
  NOW()
);

-- Bilder
INSERT INTO bilder (bericht_id, url, beschreibung)
VALUES (
  (SELECT id FROM berichte WHERE titel = 'Wartungsbericht Juni'),
  '/images/bericht1_bild1.jpg',
  'Foto des Geräteinneren nach Filtertausch'
);
