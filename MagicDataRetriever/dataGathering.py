import requests
import json

HEADERS = {
    "User-Agent": "MyMTGApp/1.0"
}


def getBulkDownloadUrl():

    response = requests.get(
        "https://api.scryfall.com/bulk-data",
        headers=HEADERS
    )

    data = response.json()["data"]

    oracleCards = next(
        item for item in data
        if item["type"] == "oracle_cards"
    )

    return oracleCards["download_uri"]


def downloadAllCards(downloadUrl):

    print("Downloading all cards...")

    response = requests.get(
        downloadUrl,
        headers=HEADERS
    )

    return response.json()


def formatCards(cards):

    formattedCards = []

    for card in cards:

        formattedCard = {
            "id": card.get("id"),
            "name": card.get("name"),
            "rarity": card.get("rarity"),
            "setName": card.get("set_name"),
            "imageUri": (
                card.get("image_uris", {})
                    .get("large")
            )
        }

        formattedCards.append(formattedCard)

    return formattedCards


# STEP 1 — Find bulk download URL
downloadUrl = getBulkDownloadUrl()

print("Bulk URL found")

# STEP 2 — Download ALL cards
allCards = downloadAllCards(downloadUrl)

print("Total cards downloaded:", len(allCards))

# STEP 3 — Format cards
formattedCards = formatCards(allCards)

print("Cards formatted")

# STEP 4 — Save JSON file locally
with open("cards.json", "w", encoding="utf-8") as file:

    json.dump(
        formattedCards,
        file,
        indent=2,
        ensure_ascii=False
    )

print("cards.json saved successfully")