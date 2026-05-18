import json
import psycopg2

from psycopg2.extras import execute_batch

DB_CONFIG = {
    "host": "localhost",
    "database": "MagicTheGathering",
    "user": "crsnam",
    "password": "postgres",
    "port": 5433
}

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


def bulk_insert_cards(cards):

    connection = psycopg2.connect(**DB_CONFIG)

    print("CONNECTED")

    cursor = connection.cursor()

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
