import hashlib
import json
import random
import psycopg2

from psycopg2.extras import execute_batch

DB_CONFIG = {
    "host": "127.0.0.1",
    "database": "marketplace_db",
    "user": "crsnam",
    "password": "postgres",
    "port": 5433,
    "options": "-c search_path=cards_schema"
}

MOCK_STORES = [
    {
        "name": "Mana Vault Trading",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "address": "100 Market St",
        "city": "San Francisco",
        "state": "CA",
        "country": "USA",
        "postal_code": "94105",
        "phone": "415-555-0101",
        "email": "inventory@manavault.example",
        "website": "https://manavault.example"
    },
    {
        "name": "Planeswalker Games",
        "latitude": 37.8044,
        "longitude": -122.2712,
        "address": "200 Broadway",
        "city": "Oakland",
        "state": "CA",
        "country": "USA",
        "postal_code": "94607",
        "phone": "510-555-0102",
        "email": "cards@planeswalkergames.example",
        "website": "https://planeswalkergames.example"
    },
    {
        "name": "Command Tower Cards",
        "latitude": 37.3382,
        "longitude": -121.8863,
        "address": "310 San Pedro St",
        "city": "San Jose",
        "state": "CA",
        "country": "USA",
        "postal_code": "95110",
        "phone": "408-555-0103",
        "email": "sales@commandtower.example",
        "website": "https://commandtower.example"
    },
    {
        "name": "Lotus Market Games",
        "latitude": 38.5816,
        "longitude": -121.4944,
        "address": "420 Capitol Mall",
        "city": "Sacramento",
        "state": "CA",
        "country": "USA",
        "postal_code": "95814",
        "phone": "916-555-0104",
        "email": "inventory@lotusmarket.example",
        "website": "https://lotusmarket.example"
    },
    {
        "name": "Mulligan House",
        "latitude": 34.0522,
        "longitude": -118.2437,
        "address": "515 Spring St",
        "city": "Los Angeles",
        "state": "CA",
        "country": "USA",
        "postal_code": "90013",
        "phone": "213-555-0105",
        "email": "cards@mulliganhouse.example",
        "website": "https://mulliganhouse.example"
    },
    {
        "name": "Arcane Archive",
        "latitude": 32.7157,
        "longitude": -117.1611,
        "address": "610 Broadway",
        "city": "San Diego",
        "state": "CA",
        "country": "USA",
        "postal_code": "92101",
        "phone": "619-555-0106",
        "email": "orders@arcanearchive.example",
        "website": "https://arcanearchive.example"
    },
    {
        "name": "Sideboard Supply",
        "latitude": 36.7378,
        "longitude": -119.7871,
        "address": "720 Fulton St",
        "city": "Fresno",
        "state": "CA",
        "country": "USA",
        "postal_code": "93721",
        "phone": "559-555-0107",
        "email": "hello@sideboardsupply.example",
        "website": "https://sideboardsupply.example"
    },
    {
        "name": "Mythic Draw",
        "latitude": 37.4419,
        "longitude": -122.1430,
        "address": "805 University Ave",
        "city": "Palo Alto",
        "state": "CA",
        "country": "USA",
        "postal_code": "94301",
        "phone": "650-555-0108",
        "email": "shop@mythicdraw.example",
        "website": "https://mythicdraw.example"
    }
]


def load_cards():

    with open("cards.json", "r", encoding="utf-8") as file:
        return json.load(file)


def format_cards(cards):

    formatted_cards = []

    for card in cards:

        formatted_cards.append(
            (
                card.get("id"),          # scryfall_id
                card.get("name"),
                card.get("rarity"),
                card.get("set_name"),
                card.get("imageUri")
            )
        )

    return formatted_cards


def ensure_store_inventory_tables(cursor):

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS stores (
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
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS store_inventory (
            id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            card_id     UUID NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
            store_id    UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
            distance_km NUMERIC,
            price       NUMERIC(10, 2),
            quantity    INTEGER NOT NULL DEFAULT 0,
            condition   TEXT NOT NULL,
            foil        BOOLEAN NOT NULL DEFAULT FALSE,
            UNIQUE (card_id, store_id, condition, foil)
        )
    """)

    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_store_inventory_card_id
        ON store_inventory(card_id)
    """)

    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_store_inventory_store_id
        ON store_inventory(store_id)
    """)


def seed_mock_stores(cursor):

    query = """
        INSERT INTO stores (
            name,
            latitude,
            longitude,
            address,
            city,
            state,
            country,
            postal_code,
            phone,
            email,
            website
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (name) DO UPDATE SET
            latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            address = EXCLUDED.address,
            city = EXCLUDED.city,
            state = EXCLUDED.state,
            country = EXCLUDED.country,
            postal_code = EXCLUDED.postal_code,
            phone = EXCLUDED.phone,
            email = EXCLUDED.email,
            website = EXCLUDED.website
        RETURNING id, name
    """

    store_ids_by_name = {}

    for store in MOCK_STORES:
        cursor.execute(
            query,
            (
                store["name"],
                store["latitude"],
                store["longitude"],
                store["address"],
                store["city"],
                store["state"],
                store["country"],
                store["postal_code"],
                store["phone"],
                store["email"],
                store["website"]
            )
        )

        store_id, store_name = cursor.fetchone()
        store_ids_by_name[store_name] = store_id

    return store_ids_by_name


def build_mock_inventory_rows(card_rows, store_ids_by_name):

    inventory_rows = []
    store_names = list(store_ids_by_name.keys())
    conditions = ["Near Mint", "Lightly Played", "Moderately Played"]

    for card_id, card_name in card_rows:
        card_seed = int(hashlib.sha256(card_name.lower().encode("utf-8")).hexdigest(), 16)
        card_random = random.Random(card_seed)
        selected_store_names = card_random.sample(
            store_names,
            card_random.randint(1, min(5, len(store_names)))
        )

        for store_index, store_name in enumerate(selected_store_names):
            price_seed = card_seed + (store_index * 31)
            price = round(2 + (price_seed % 45) + ((price_seed % 100) / 100), 2)
            quantity = card_random.randint(1, 12)
            condition = conditions[card_random.randrange(len(conditions))]
            foil = card_random.random() < 0.25

            inventory_rows.append(
                (
                    card_id,
                    store_ids_by_name[store_name],
                    price,
                    quantity,
                    condition,
                    foil
                )
            )

    return inventory_rows


def seed_mock_inventory(cursor):

    cursor.execute("SELECT id, name FROM cards")
    card_rows = cursor.fetchall()

    store_ids_by_name = seed_mock_stores(cursor)
    inventory_rows = build_mock_inventory_rows(card_rows, store_ids_by_name)

    cursor.execute("DELETE FROM store_inventory")

    query = """
        INSERT INTO store_inventory (
            card_id,
            store_id,
            price,
            quantity,
            condition,
            foil
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (card_id, store_id, condition, foil) DO UPDATE SET
            price = EXCLUDED.price,
            quantity = EXCLUDED.quantity
    """

    execute_batch(
        cursor,
        query,
        inventory_rows,
        page_size=1000
    )

    print("STORE INVENTORY ROWS UPSERTED:", len(inventory_rows))


def bulk_insert_cards(cards):

    connection = psycopg2.connect(**DB_CONFIG)

    print("CONNECTED")

    cursor = connection.cursor()

    ensure_store_inventory_tables(cursor)

    query = """
        INSERT INTO cards (
            scryfall_id,
            name,
            rarity,
            set_name,
            image_uri
        )
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (scryfall_id) DO NOTHING
    """

    execute_batch(
        cursor,
        query,
        cards,
        page_size=1000
    )

    seed_mock_inventory(cursor)

    connection.commit()

    print("COMMIT COMPLETE")

    cursor.execute("SELECT COUNT(*) FROM cards")

    count = cursor.fetchone()[0]

    print("TOTAL ROWS:", count)

    cursor.close()
    connection.close()


def main():

    cards = load_cards()

    print("JSON COUNT:", len(cards))

    formatted_cards = format_cards(cards)

    bulk_insert_cards(formatted_cards)


if __name__ == "__main__":
    main()
