CREATE TABLE stores (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL UNIQUE,
    latitude    NUMERIC,
    longitude   NUMERIC,
    address     TEXT,
    city        TEXT,
    state       TEXT,
    country     TEXT,
    postal_code TEXT,
    phone       TEXT,
    email       TEXT,
    website     TEXT
);

CREATE TABLE store_inventory (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id    UUID NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    store_id   UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    distance_km NUMERIC,
    price      NUMERIC(10, 2),
    quantity   INTEGER NOT NULL DEFAULT 0,
    condition  TEXT NOT NULL,
    foil       BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (card_id, store_id, condition, foil)
);

CREATE INDEX idx_store_inventory_card_id ON store_inventory(card_id);
CREATE INDEX idx_store_inventory_store_id ON store_inventory(store_id);
