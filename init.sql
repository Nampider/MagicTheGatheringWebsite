--
-- PostgreSQL database dump
--

\restrict mZMooyRzFWZBYyVchdRjGonot5v2E4XQv2mzoA9Ctum83YeofOdnrEM2AfLC74e

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.wishlists DROP CONSTRAINT IF EXISTS wishlists_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wishlist_items DROP CONSTRAINT IF EXISTS wishlist_items_wishlist_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wishlist_items DROP CONSTRAINT IF EXISTS wishlist_items_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_locations DROP CONSTRAINT IF EXISTS user_locations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.store_card_inventory DROP CONSTRAINT IF EXISTS store_card_inventory_store_id_fkey;
ALTER TABLE IF EXISTS ONLY public.store_card_inventory DROP CONSTRAINT IF EXISTS store_card_inventory_card_id_fkey;
ALTER TABLE IF EXISTS public.price_history DROP CONSTRAINT IF EXISTS price_history_store_id_fkey;
ALTER TABLE IF EXISTS public.price_history DROP CONSTRAINT IF EXISTS price_history_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_user_id_fkey;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_user_locations_user_id;
DROP INDEX IF EXISTS public.idx_stores_lat_lng;
DROP INDEX IF EXISTS public.idx_stores_is_active;
DROP INDEX IF EXISTS public.idx_stores_city;
DROP INDEX IF EXISTS public.idx_inventory_store_id;
DROP INDEX IF EXISTS public.idx_inventory_composite;
DROP INDEX IF EXISTS public.idx_inventory_card_id;
DROP INDEX IF EXISTS public.idx_cards_type_line;
DROP INDEX IF EXISTS public.idx_cards_set_code;
DROP INDEX IF EXISTS public.idx_cards_search;
DROP INDEX IF EXISTS public.idx_cards_scryfall_id;
DROP INDEX IF EXISTS public.idx_cards_name;
DROP INDEX IF EXISTS public.idx_audit_log_user_id;
DROP INDEX IF EXISTS public.idx_audit_log_created_at;
ALTER TABLE IF EXISTS ONLY public.wishlists DROP CONSTRAINT IF EXISTS wishlists_pkey;
ALTER TABLE IF EXISTS ONLY public.wishlist_items DROP CONSTRAINT IF EXISTS wishlist_items_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_locations DROP CONSTRAINT IF EXISTS user_locations_pkey;
ALTER TABLE IF EXISTS ONLY public.stores DROP CONSTRAINT IF EXISTS stores_pkey;
ALTER TABLE IF EXISTS ONLY public.store_card_inventory DROP CONSTRAINT IF EXISTS store_card_inventory_store_id_card_id_condition_foil_key;
ALTER TABLE IF EXISTS ONLY public.store_card_inventory DROP CONSTRAINT IF EXISTS store_card_inventory_pkey;
ALTER TABLE IF EXISTS ONLY public.cards DROP CONSTRAINT IF EXISTS cards_scryfall_id_key;
ALTER TABLE IF EXISTS ONLY public.cards DROP CONSTRAINT IF EXISTS cards_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
DROP TABLE IF EXISTS public.wishlists;
DROP TABLE IF EXISTS public.wishlist_items;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_locations;
DROP TABLE IF EXISTS public.stores;
DROP TABLE IF EXISTS public.store_card_inventory;
DROP TABLE IF EXISTS public.price_history_2026_02;
DROP TABLE IF EXISTS public.price_history_2026_01;
DROP TABLE IF EXISTS public.price_history;
DROP TABLE IF EXISTS public.cards;
DROP TABLE IF EXISTS public.audit_log;
DROP EXTENSION IF EXISTS pgcrypto;
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    action character varying(100) NOT NULL,
    entity_type character varying(50),
    entity_id uuid,
    changes jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO crsnam;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scryfall_id uuid,
    name character varying(255) NOT NULL,
    oracle_text text,
    card_state character varying(50),
    set_code character varying(10),
    set_name character varying(255),
    rarity character varying(50),
    type_line character varying(255),
    artist character varying(255),
    collector_number character varying(20),
    image_uri text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cards OWNER TO crsnam;

--
-- Name: price_history; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.price_history (
    id uuid DEFAULT gen_random_uuid(),
    card_id uuid,
    store_id uuid,
    price numeric(10,2) NOT NULL,
    condition character varying(50),
    foil boolean,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
)
PARTITION BY RANGE (recorded_at);


ALTER TABLE public.price_history OWNER TO crsnam;

--
-- Name: price_history_2026_01; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.price_history_2026_01 (
    id uuid DEFAULT gen_random_uuid(),
    card_id uuid,
    store_id uuid,
    price numeric(10,2) NOT NULL,
    condition character varying(50),
    foil boolean,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.price_history_2026_01 OWNER TO crsnam;

--
-- Name: price_history_2026_02; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.price_history_2026_02 (
    id uuid DEFAULT gen_random_uuid(),
    card_id uuid,
    store_id uuid,
    price numeric(10,2) NOT NULL,
    condition character varying(50),
    foil boolean,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.price_history_2026_02 OWNER TO crsnam;

--
-- Name: store_card_inventory; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.store_card_inventory (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    store_id uuid,
    card_id uuid,
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    condition character varying(50) DEFAULT 'near_mint'::character varying,
    foil boolean DEFAULT false,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.store_card_inventory OWNER TO crsnam;

--
-- Name: stores; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.stores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    address character varying(500),
    city character varying(100),
    state character varying(50),
    country character varying(50),
    postal_code character varying(20),
    phone character varying(50),
    email character varying(255),
    website character varying(500),
    hours_of_operation jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.stores OWNER TO crsnam;

--
-- Name: user_locations; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.user_locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name character varying(100),
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    is_default boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_locations OWNER TO crsnam;

--
-- Name: users; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO crsnam;

--
-- Name: wishlist_items; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.wishlist_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    wishlist_id uuid,
    card_id uuid,
    quantity integer DEFAULT 1,
    max_price numeric(10,2),
    notes text,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wishlist_items OWNER TO crsnam;

--
-- Name: wishlists; Type: TABLE; Schema: public; Owner: crsnam
--

CREATE TABLE public.wishlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name character varying(255) NOT NULL,
    is_public boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wishlists OWNER TO crsnam;

--
-- Name: price_history_2026_01; Type: TABLE ATTACH; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.price_history ATTACH PARTITION public.price_history_2026_01 FOR VALUES FROM ('2026-01-01 00:00:00') TO ('2026-02-01 00:00:00');


--
-- Name: price_history_2026_02; Type: TABLE ATTACH; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.price_history ATTACH PARTITION public.price_history_2026_02 FOR VALUES FROM ('2026-02-01 00:00:00') TO ('2026-03-01 00:00:00');


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.audit_log (id, user_id, action, entity_type, entity_id, changes, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.cards (id, scryfall_id, name, oracle_text, card_state, set_code, set_name, rarity, type_line, artist, collector_number, image_uri, created_at, updated_at) FROM stdin;
b30b153c-7090-4e73-a625-d4a757ba2510	a1b2c3d4-1111-2222-3333-aaaaaaaaaaaa	Black Lotus	{T}, Sacrifice Black Lotus: Add three mana of any one color.	legal	LEA	Limited Edition Alpha	rare	Artifact	Christopher Rush	233	https://cards.scryfall.io/large/front/0/0/black_lotus.jpg	2026-02-01 17:42:21.790951	2026-02-01 17:42:21.790951
c48d457c-9a48-4a8b-8d59-6605bca9f21e	b2c3d4e5-2222-3333-4444-bbbbbbbbbbbb	Lightning Bolt	Lightning Bolt deals 3 damage to any target.	legal	M11	Magic 2011	common	Instant	Christopher Moeller	146	https://cards.scryfall.io/large/front/1/1/lightning_bolt.jpg	2026-02-01 17:42:21.790951	2026-02-01 17:42:21.790951
01db5eb5-583d-40d7-ab66-591a328afbe8	c3d4e5f6-3333-4444-5555-cccccccccccc	Tarmogoyf	Tarmogoyf’s power is equal to the number of card types among cards in all graveyards.	legal	FUT	Future Sight	rare	Creature — Lhurgoyf	Justin Sweet	153	https://cards.scryfall.io/large/front/2/2/tarmogoyf.jpg	2026-02-01 17:42:21.790951	2026-02-01 17:42:21.790951
4326735c-cab8-422d-a20a-c89e9db05c15	d4e5f6a7-4444-5555-6666-dddddddddddd	Counterspell	Counter target spell.	legal	2ED	Unlimited Edition	uncommon	Instant	Mark Tedin	54	https://cards.scryfall.io/large/front/3/3/counterspell.jpg	2026-02-01 17:42:21.790951	2026-02-01 17:42:21.790951
500aa161-4a49-414d-8b05-37729cdef9c7	e5f6a7b8-5555-6666-7777-eeeeeeeeeeee	Sol Ring	{T}: Add {C}{C}.	legal	CMM	Commander Masters	uncommon	Artifact	Mike Bierek	396	https://cards.scryfall.io/large/front/4/4/sol_ring.jpg	2026-02-01 17:42:21.790951	2026-02-01 17:42:21.790951
\.


--
-- Data for Name: price_history_2026_01; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.price_history_2026_01 (id, card_id, store_id, price, condition, foil, recorded_at) FROM stdin;
\.


--
-- Data for Name: price_history_2026_02; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.price_history_2026_02 (id, card_id, store_id, price, condition, foil, recorded_at) FROM stdin;
\.


--
-- Data for Name: store_card_inventory; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.store_card_inventory (id, store_id, card_id, price, quantity, condition, foil, last_updated) FROM stdin;
\.


--
-- Data for Name: stores; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.stores (id, name, latitude, longitude, address, city, state, country, postal_code, phone, email, website, hours_of_operation, is_active, created_at, updated_at) FROM stdin;
218c5bfc-8bb2-4fe8-b567-a7800f34f027	Arcane Lotus Games	34.05223500	-118.24368300	123 Mana Way	Los Angeles	CA	USA	90012	+1-213-555-0198	contact@arcanelotusgames.com	https://arcanelotusgames.com	{"fri": "11:00-23:00", "mon": "11:00-21:00", "sat": "10:00-23:00", "sun": "10:00-20:00", "thu": "11:00-22:00", "tue": "11:00-21:00", "wed": "11:00-21:00"}	t	2026-02-03 18:34:11.159344	2026-02-03 18:34:11.159344
a816ad91-b60f-4a7c-8840-f009ecca1b3c	Black Mana Collectibles	40.71277600	-74.00597400	456 Commander Ave	New York	NY	USA	10007	+1-212-555-0142	info@blackmanacollectibles.com	https://blackmanacollectibles.com	{"fri": "12:00-22:00", "mon": "12:00-20:00", "sat": "11:00-22:00", "sun": "closed", "thu": "12:00-21:00", "tue": "12:00-20:00", "wed": "12:00-20:00"}	t	2026-02-03 18:34:11.159344	2026-02-03 18:34:11.159344
8ba8528d-6db9-4c1d-ba86-13acc91afdf0	Planeswalker’s Refuge	41.87811300	-87.62979900	789 Tap Symbol Rd	Chicago	IL	USA	60601	+1-312-555-0111	support@planeswalkersrefuge.com	https://planeswalkersrefuge.com	{"fri": "10:00-22:00", "mon": "10:00-19:00", "sat": "10:00-22:00", "sun": "12:00-18:00", "thu": "10:00-21:00", "tue": "10:00-19:00", "wed": "10:00-19:00"}	t	2026-02-03 18:34:11.159344	2026-02-03 18:34:11.159344
976a74a7-638d-4335-abfc-d316efe0c19c	Cardboard Kingdom	37.77492900	-122.41941800	321 Stack Blvd	San Francisco	CA	USA	94103	+1-415-555-0177	hello@cardboardkingdom.com	https://cardboardkingdom.com	{"fri": "11:00-22:00", "mon": "11:00-20:00", "sat": "10:00-22:00", "sun": "10:00-18:00", "thu": "11:00-21:00", "tue": "11:00-20:00", "wed": "11:00-20:00"}	t	2026-02-03 18:34:11.159344	2026-02-03 18:34:11.159344
9ab14418-7605-46af-af83-59a817dddbec	Mana Vault Trading	29.76042700	-95.36980400	654 Booster Pack Ln	Houston	TX	USA	77002	+1-713-555-0133	sales@manavaulttrading.com	https://manavaulttrading.com	{"fri": "12:00-23:00", "mon": "12:00-21:00", "sat": "11:00-23:00", "sun": "11:00-19:00", "thu": "12:00-22:00", "tue": "12:00-21:00", "wed": "12:00-21:00"}	t	2026-02-03 18:34:11.159344	2026-02-03 18:34:11.159344
\.


--
-- Data for Name: user_locations; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.user_locations (id, user_id, name, latitude, longitude, is_default, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.users (id, email, password_hash, first_name, last_name, email_verified, created_at, updated_at, last_login_at) FROM stdin;
\.


--
-- Data for Name: wishlist_items; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.wishlist_items (id, wishlist_id, card_id, quantity, max_price, notes, added_at) FROM stdin;
\.


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: crsnam
--

COPY public.wishlists (id, user_id, name, is_public, created_at, updated_at) FROM stdin;
\.


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: cards cards_scryfall_id_key; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_scryfall_id_key UNIQUE (scryfall_id);


--
-- Name: store_card_inventory store_card_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.store_card_inventory
    ADD CONSTRAINT store_card_inventory_pkey PRIMARY KEY (id);


--
-- Name: store_card_inventory store_card_inventory_store_id_card_id_condition_foil_key; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.store_card_inventory
    ADD CONSTRAINT store_card_inventory_store_id_card_id_condition_foil_key UNIQUE (store_id, card_id, condition, foil);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: user_locations user_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.user_locations
    ADD CONSTRAINT user_locations_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wishlist_items wishlist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_pkey PRIMARY KEY (id);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_log_created_at; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_audit_log_created_at ON public.audit_log USING btree (created_at);


--
-- Name: idx_audit_log_user_id; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_audit_log_user_id ON public.audit_log USING btree (user_id);


--
-- Name: idx_cards_name; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_cards_name ON public.cards USING btree (name);


--
-- Name: idx_cards_scryfall_id; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_cards_scryfall_id ON public.cards USING btree (scryfall_id);


--
-- Name: idx_cards_search; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_cards_search ON public.cards USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || COALESCE(oracle_text, ''::text)) || ' '::text) || (type_line)::text)));


--
-- Name: idx_cards_set_code; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_cards_set_code ON public.cards USING btree (set_code);


--
-- Name: idx_cards_type_line; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_cards_type_line ON public.cards USING btree (type_line);


--
-- Name: idx_inventory_card_id; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_inventory_card_id ON public.store_card_inventory USING btree (card_id);


--
-- Name: idx_inventory_composite; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_inventory_composite ON public.store_card_inventory USING btree (card_id, store_id, condition);


--
-- Name: idx_inventory_store_id; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_inventory_store_id ON public.store_card_inventory USING btree (store_id);


--
-- Name: idx_stores_city; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_stores_city ON public.stores USING btree (city);


--
-- Name: idx_stores_is_active; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_stores_is_active ON public.stores USING btree (is_active);


--
-- Name: idx_stores_lat_lng; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_stores_lat_lng ON public.stores USING btree (latitude, longitude);


--
-- Name: idx_user_locations_user_id; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_user_locations_user_id ON public.user_locations USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: crsnam
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: price_history price_history_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE public.price_history
    ADD CONSTRAINT price_history_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: price_history price_history_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE public.price_history
    ADD CONSTRAINT price_history_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- Name: store_card_inventory store_card_inventory_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.store_card_inventory
    ADD CONSTRAINT store_card_inventory_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON DELETE CASCADE;


--
-- Name: store_card_inventory store_card_inventory_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.store_card_inventory
    ADD CONSTRAINT store_card_inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;


--
-- Name: user_locations user_locations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.user_locations
    ADD CONSTRAINT user_locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: wishlist_items wishlist_items_wishlist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_wishlist_id_fkey FOREIGN KEY (wishlist_id) REFERENCES public.wishlists(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crsnam
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict mZMooyRzFWZBYyVchdRjGonot5v2E4XQv2mzoA9Ctum83YeofOdnrEM2AfLC74e

