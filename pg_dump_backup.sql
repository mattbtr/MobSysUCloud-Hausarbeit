--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abteilungen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abteilungen (
    id integer NOT NULL,
    name character varying NOT NULL,
    standort_id integer
);


ALTER TABLE public.abteilungen OWNER TO postgres;

--
-- Name: abteilungen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.abteilungen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.abteilungen_id_seq OWNER TO postgres;

--
-- Name: abteilungen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.abteilungen_id_seq OWNED BY public.abteilungen.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: anlagen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.anlagen (
    id integer NOT NULL,
    name character varying NOT NULL,
    abteilung_id integer
);


ALTER TABLE public.anlagen OWNER TO postgres;

--
-- Name: anlagen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.anlagen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.anlagen_id_seq OWNER TO postgres;

--
-- Name: anlagen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.anlagen_id_seq OWNED BY public.anlagen.id;


--
-- Name: berichte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.berichte (
    id integer NOT NULL,
    titel character varying NOT NULL,
    beschreibung text NOT NULL,
    erstellt_am timestamp with time zone DEFAULT now() NOT NULL,
    anlage_id integer NOT NULL,
    firebase_uid character varying,
    nutzer_name character varying,
    nutzer_email character varying
);


ALTER TABLE public.berichte OWNER TO postgres;

--
-- Name: berichte_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.berichte_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.berichte_id_seq OWNER TO postgres;

--
-- Name: berichte_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.berichte_id_seq OWNED BY public.berichte.id;


--
-- Name: eintraege; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eintraege (
    id integer NOT NULL,
    titel character varying NOT NULL,
    beschreibung text,
    wert character varying,
    erstellt_am timestamp with time zone DEFAULT now(),
    bericht_id integer NOT NULL
);


ALTER TABLE public.eintraege OWNER TO postgres;

--
-- Name: eintraege_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eintraege_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eintraege_id_seq OWNER TO postgres;

--
-- Name: eintraege_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.eintraege_id_seq OWNED BY public.eintraege.id;


--
-- Name: kunden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kunden (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.kunden OWNER TO postgres;

--
-- Name: kunden_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kunden_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kunden_id_seq OWNER TO postgres;

--
-- Name: kunden_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kunden_id_seq OWNED BY public.kunden.id;


--
-- Name: standorte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.standorte (
    id integer NOT NULL,
    name character varying NOT NULL,
    adresse character varying,
    kunde_id integer
);


ALTER TABLE public.standorte OWNER TO postgres;

--
-- Name: standorte_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.standorte_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.standorte_id_seq OWNER TO postgres;

--
-- Name: standorte_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.standorte_id_seq OWNED BY public.standorte.id;


--
-- Name: abteilungen id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilungen ALTER COLUMN id SET DEFAULT nextval('public.abteilungen_id_seq'::regclass);


--
-- Name: anlagen id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anlagen ALTER COLUMN id SET DEFAULT nextval('public.anlagen_id_seq'::regclass);


--
-- Name: berichte id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.berichte ALTER COLUMN id SET DEFAULT nextval('public.berichte_id_seq'::regclass);


--
-- Name: eintraege id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eintraege ALTER COLUMN id SET DEFAULT nextval('public.eintraege_id_seq'::regclass);


--
-- Name: kunden id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kunden ALTER COLUMN id SET DEFAULT nextval('public.kunden_id_seq'::regclass);


--
-- Name: standorte id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standorte ALTER COLUMN id SET DEFAULT nextval('public.standorte_id_seq'::regclass);


--
-- Data for Name: abteilungen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abteilungen (id, name, standort_id) FROM stdin;
1	Kardiologie	1
2	Innere Medizin	1
3	Anästhesie	2
4	Chirurgie	2
5	Intensivpflege	3
6	Physiotherapie	4
7	Labortechnik	5
8	Unfallchirurgie	6
9	Geriatrie	7
10	Röntgendiagnostik	8
11	CT-Abteilung	8
12	MRT-Abteilung	8
13	Ergotherapie	9
14	Psychosomatik	9
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
d1cd65c1e7ed
\.


--
-- Data for Name: anlagen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.anlagen (id, name, abteilung_id) FROM stdin;
1	Defibrillator Modell X	1
2	EKG-Messgerät	1
3	Patientenmonitor	2
4	Narkosegerät	3
5	OP-Lampe	4
6	Elektroskalpell	4
7	Beatmungsgerät	5
8	Vitalmonitor	5
9	Infusionspumpe	5
10	Therapieliege	6
11	Blutanalysegerät	7
12	Mikroskop	7
13	Schockraum-Bett	8
14	Monitoring-System	8
15	Rollstuhl	9
16	Patientenrufsystem	9
17	Pflegebett	9
18	Röntgengerät	10
19	Bildspeicher	10
20	CT-Scanner	11
21	MRT-Gerät	12
22	Handtherapie-Station	13
23	EEG-Monitor	14
\.


--
-- Data for Name: berichte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.berichte (id, titel, beschreibung, erstellt_am, anlage_id, firebase_uid, nutzer_name, nutzer_email) FROM stdin;
1	Testbericht	Beschreibung	2025-06-30 17:40:16.438946+02	1	\N	\N	\N
2	Testbericht	Beschreibung	2025-06-04 00:00:00+02	1	\N	\N	\N
3	test111	drssgg	2025-06-04 00:00:00+02	1	\N	\N	\N
5	eeg monitor	berihct eeg monitor	2025-06-11 00:00:00+02	23	\N	\N	\N
\.


--
-- Data for Name: eintraege; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eintraege (id, titel, beschreibung, wert, erstellt_am, bericht_id) FROM stdin;
1	Temperaturmessung	Temperatur im Serverraum	23.5°C	2025-07-02 08:06:07.845447+02	1
2	Leckageprüfung	Prüfung auf Wasserschäden	Keine Leckage festgestellt	2025-07-02 08:06:07.845447+02	1
3	Bild von Anlage	Foto der Hauptanlage	/uploads/bild_anlage.jpg	2025-07-02 08:06:07.845447+02	1
4	Defibrilator 	Bild der ausgerüsteten Defis	/uploads/462bd8bd-a241-46e4-9c0e-58278ef6f2c5_Products_EmergencyCare_MonitorsandDefibs_RSeriesALS_Header.jpg	2025-07-02 08:11:35.259325+02	1
5	test bild von kamera	test	/uploads/8349e5d0-4337-4771-bffd-23039f9c7c6d_CAP4226160864417543280.jpg	2025-07-02 09:57:07.691001+02	2
\.


--
-- Data for Name: kunden; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kunden (id, name) FROM stdin;
1	Klinik Nordwest
2	MedTech Zentrum
3	Städtisches Klinikum
4	Zentrum für Radiologie
5	Klinik Sonnenhof
\.


--
-- Data for Name: standorte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.standorte (id, name, adresse, kunde_id) FROM stdin;
1	Station 3B	Klinikstraße 1, 12345 Frankfurt	1
2	OP-Zentrum	Chirurgenweg 5, 12345 Frankfurt	1
3	Intensivstation A	MedTech Allee 7, 67890 Berlin	2
4	Reha-Bereich	Therapiepfad 12, 67890 Berlin	2
5	Labortrakt	Analysenstraße 4, 67890 Berlin	2
6	Notaufnahme	Akutgasse 9, 54321 Hamburg	3
7	Station C1	Seniorenring 10, 54321 Hamburg	3
8	Radiologiezentrum Mitte	Röntgenstraße 8, 11111 Köln	4
9	Therapiezentrum Süd	Sonnenweg 22, 98765 München	5
\.


--
-- Name: abteilungen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.abteilungen_id_seq', 14, true);


--
-- Name: anlagen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.anlagen_id_seq', 23, true);


--
-- Name: berichte_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.berichte_id_seq', 5, true);


--
-- Name: eintraege_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eintraege_id_seq', 5, true);


--
-- Name: kunden_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kunden_id_seq', 5, true);


--
-- Name: standorte_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.standorte_id_seq', 9, true);


--
-- Name: abteilungen abteilungen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilungen
    ADD CONSTRAINT abteilungen_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: anlagen anlagen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anlagen
    ADD CONSTRAINT anlagen_pkey PRIMARY KEY (id);


--
-- Name: berichte berichte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.berichte
    ADD CONSTRAINT berichte_pkey PRIMARY KEY (id);


--
-- Name: eintraege eintraege_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eintraege
    ADD CONSTRAINT eintraege_pkey PRIMARY KEY (id);


--
-- Name: kunden kunden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kunden
    ADD CONSTRAINT kunden_pkey PRIMARY KEY (id);


--
-- Name: standorte standorte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standorte
    ADD CONSTRAINT standorte_pkey PRIMARY KEY (id);


--
-- Name: ix_abteilungen_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_abteilungen_id ON public.abteilungen USING btree (id);


--
-- Name: ix_anlagen_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_anlagen_id ON public.anlagen USING btree (id);


--
-- Name: ix_berichte_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_berichte_id ON public.berichte USING btree (id);


--
-- Name: ix_eintraege_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_eintraege_id ON public.eintraege USING btree (id);


--
-- Name: ix_kunden_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kunden_id ON public.kunden USING btree (id);


--
-- Name: ix_standorte_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_standorte_id ON public.standorte USING btree (id);


--
-- Name: abteilungen abteilungen_standort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilungen
    ADD CONSTRAINT abteilungen_standort_id_fkey FOREIGN KEY (standort_id) REFERENCES public.standorte(id) ON DELETE CASCADE;


--
-- Name: anlagen anlagen_abteilung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anlagen
    ADD CONSTRAINT anlagen_abteilung_id_fkey FOREIGN KEY (abteilung_id) REFERENCES public.abteilungen(id) ON DELETE CASCADE;


--
-- Name: berichte berichte_anlage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.berichte
    ADD CONSTRAINT berichte_anlage_id_fkey FOREIGN KEY (anlage_id) REFERENCES public.anlagen(id);


--
-- Name: eintraege eintraege_bericht_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eintraege
    ADD CONSTRAINT eintraege_bericht_id_fkey FOREIGN KEY (bericht_id) REFERENCES public.berichte(id) ON DELETE CASCADE;


--
-- Name: standorte standorte_kunde_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standorte
    ADD CONSTRAINT standorte_kunde_id_fkey FOREIGN KEY (kunde_id) REFERENCES public.kunden(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

