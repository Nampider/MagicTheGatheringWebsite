--
-- Enable Extensions
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

--
-- Drop Tables (for local development reset)
--

DROP TABLE IF EXISTS public.wishlist_items CASCADE;
DROP TABLE IF EXISTS public.wishlists CASCADE;
DROP TABLE IF EXISTS public.user_locations CASCADE;
DROP TABLE IF EXISTS public.store_card_inventory CASCADE;
DROP TABLE IF EXISTS public.price_history CASCADE;
DROP TABLE IF EXISTS public.stores CASCADE;
DROP TABLE IF EXISTS public.cards CASCADE;
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

--
-- USERS
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    email varchar(255) NOT NULL UNIQUE,
    password_hash varchar(255) NOT NULL,
    first_name varchar(100),
    last_name varchar(100),
    email_verified boolean DEFAULT false,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP,
    last_login_at timestamp
);

CREATE INDEX idx_users_email
ON public.users(email);

--
-- CARDS
--

CREATE TABLE public.cards (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    scryfall_id uuid UNIQUE,

    name varchar(255) NOT NULL,

    oracle_text text,

    card_state varchar(50),

    set_code varchar(10),

    set_name varchar(255),

    rarity varchar(50),

    type_line varchar(255),

    artist varchar(255),

    collector_number varchar(20),

    image_uri text,

    created_at timestamp DEFAULT CURRENT_TIMESTAMP,

    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cards_name
ON public.cards(name);

CREATE INDEX idx_cards_scryfall_id
ON public.cards(scryfall_id);

CREATE INDEX idx_cards_set_code
ON public.cards(set_code);

CREATE INDEX idx_cards_type_line
ON public.cards(type_line);

CREATE INDEX idx_cards_search
ON public.cards
USING gin (
    to_tsvector(
        'english',
        (
            name || ' ' ||
            COALESCE(oracle_text, '') || ' ' ||
            COALESCE(type_line, '')
        )
    )
);

--
-- STORES
--

CREATE TABLE public.stores (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    name varchar(255) NOT NULL,

    latitude numeric(10,8) NOT NULL,

    longitude numeric(11,8) NOT NULL,

    address varchar(500),

    city varchar(100),

    state varchar(50),

    country varchar(50),

    postal_code varchar(20),

    phone varchar(50),

    email varchar(255),

    website varchar(500),

    hours_of_operation jsonb,

    is_active boolean DEFAULT true,

    created_at timestamp DEFAULT CURRENT_TIMESTAMP,

    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stores_city
ON public.stores(city);

CREATE INDEX idx_stores_is_active
ON public.stores(is_active);

CREATE INDEX idx_stores_lat_lng
ON public.stores(latitude, longitude);

--
-- STORE INVENTORY
--

CREATE TABLE public.store_card_inventory (

    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    store_id uuid REFERENCES public.stores(id) ON DELETE CASCADE,

    card_id uuid REFERENCES public.cards(id) ON DELETE CASCADE,

    price numeric(10,2) NOT NULL,

    quantity integer NOT NULL,

    condition varchar(50) DEFAULT 'near_mint',

    foil boolean DEFAULT false,

    last_updated timestamp DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (store_id, card_id, condition, foil)
);

CREATE INDEX idx_inventory_store_id
ON public.store_card_inventory(store_id);

CREATE INDEX idx_inventory_card_id
ON public.store_card_inventory(card_id);

CREATE INDEX idx_inventory_composite
ON public.store_card_inventory(card_id, store_id, condition);

--
-- PRICE HISTORY
--

CREATE TABLE public.price_history (

    id uuid DEFAULT gen_random_uuid(),

    card_id uuid REFERENCES public.cards(id),

    store_id uuid REFERENCES public.stores(id),

    price numeric(10,2) NOT NULL,

    condition varchar(50),

    foil boolean,

    recorded_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL

)
PARTITION BY RANGE (recorded_at);

--
-- Example Monthly Partition
--

CREATE TABLE public.price_history_2026_05
PARTITION OF public.price_history
FOR VALUES FROM ('2026-05-01')
TO ('2026-06-01');

--
-- USER LOCATIONS
--

CREATE TABLE public.user_locations (

    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,

    name varchar(100),

    latitude numeric(10,8) NOT NULL,

    longitude numeric(11,8) NOT NULL,

    is_default boolean DEFAULT false,

    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_locations_user_id
ON public.user_locations(user_id);

--
-- WISHLISTS
--

CREATE TABLE public.wishlists (

    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,

    name varchar(255) NOT NULL,

    is_public boolean DEFAULT false,

    created_at timestamp DEFAULT CURRENT_TIMESTAMP,

    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- WISHLIST ITEMS
--

CREATE TABLE public.wishlist_items (

    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    wishlist_id uuid REFERENCES public.wishlists(id) ON DELETE CASCADE,

    card_id uuid REFERENCES public.cards(id),

    quantity integer DEFAULT 1,

    max_price numeric(10,2),

    notes text,

    added_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- AUDIT LOG
--

CREATE TABLE public.audit_log (

    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    user_id uuid REFERENCES public.users(id),

    action varchar(100) NOT NULL,

    entity_type varchar(50),

    entity_id uuid,

    changes jsonb,

    ip_address inet,

    user_agent text,

    created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_user_id
ON public.audit_log(user_id);

CREATE INDEX idx_audit_log_created_at
ON public.audit_log(created_at);

--
-- OPTIONAL SMALL SEED DATA
-- (Safe to keep tiny amounts only)
--

INSERT INTO public.stores (
    name,
    latitude,
    longitude,
    city,
    state,
    country
)
VALUES
(
    'Arcane Lotus Games',
    34.05223500,
    -118.24368300,
    'Los Angeles',
    'CA',
    'USA'
);
