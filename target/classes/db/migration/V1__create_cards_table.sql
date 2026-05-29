CREATE TABLE cards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scryfall_id UUID UNIQUE,
    name        TEXT NOT NULL,
    card_state  TEXT,
    set_code    TEXT,
    set_name    TEXT,
    rarity      TEXT,
    type_line   TEXT,
    artist      TEXT,
    collector_number TEXT,
    image_uri   TEXT
);