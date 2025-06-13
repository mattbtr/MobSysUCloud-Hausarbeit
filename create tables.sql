CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE kunden (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE standorte (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    adresse TEXT,
    kunde_id INT REFERENCES kunden(id) ON DELETE CASCADE
);

CREATE TABLE abteilungen (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    standort_id INT REFERENCES standorte(id) ON DELETE CASCADE
);

CREATE TABLE anlagen (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    seriennummer VARCHAR(255),
    abteilung_id INT REFERENCES abteilungen(id) ON DELETE CASCADE
);

CREATE TABLE berichte (
    id SERIAL PRIMARY KEY,
    anlage_id INT REFERENCES anlagen(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    titel VARCHAR(255),
    inhalt TEXT,
    datum DATE,
    pdf_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE bilder (
    id SERIAL PRIMARY KEY,
    bericht_id INT REFERENCES berichte(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    beschreibung TEXT
);
