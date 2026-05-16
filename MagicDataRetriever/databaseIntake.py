import json
import psycopg2

from psycopg2.extras import execute_batch


DB_CONFIG = {
    "host": "localhost",
    "database": "MagicTheGathering",
    "user": "crsnam",
    "password": "postgres",
    "port": 5432
}


def load_cards():

    with open("cards.json", "r", encoding="utf-8") as file:
        return json.load(file)


def format_cards(cards):

    formatted_cards = []

    for card in cards:

        formatted_cards.append(
            (
                card.get("id"),
                card.get("name"),
                card.get("rarity"),
                card.get("setName"),
                card.get("imageUri")
            )
        )

    return formatted_cards


def bulk_insert_cards(cards):

    connection = psycopg2.connect(**DB_CONFIG)

    cursor = connection.cursor()

    query = """
        INSERT INTO cards (
            id,
            name,
            rarity,
            set_name,
            image_uri
        )
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (id) DO NOTHING
    """

    execute_batch(
        cursor,
        query,
        cards,
        page_size=1000
    )

    connection.commit()

    cursor.close()
    connection.close()

    print("Cards inserted successfully")


def main():

    print("Loading cards.json...")

    cards = load_cards()

    print("Total cards loaded:", len(cards))

    formatted_cards = format_cards(cards)

    print("Starting bulk insert...")

    bulk_insert_cards(formatted_cards)

    print("Done")


if __name__ == "__main__":
    main()