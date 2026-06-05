# Magic Marketplace

A full-stack Magic: The Gathering trading card marketplace platform designed to help users quickly locate cards from nearby local game stores.

## Overview

Magic Marketplace is a location-aware trading card platform that allows users to search for Magic: The Gathering cards across multiple nearby stores in real time.

The platform automatically detects the user’s location, identifies nearby participating card shops, and displays inventory availability for requested cards. Users can search for single cards or perform large bulk imports containing hundreds of cards at once.

The goal of the platform is to simplify the process of finding cards locally while supporting local game stores and reducing the time players spend manually searching multiple websites.

---

# Features

## Location-Based Store Discovery

* Automatically detects user location
* Finds nearby local game stores
* Displays store distance and available inventory
* Supports expanding search radius

## Card Search

* Search for individual Magic: The Gathering cards
* View available copies across nearby stores
* Compare availability between stores
* Search by:

  * Card name
  * Set
  * Collector number
  * Rarity
  * Foil/non-foil

## Bulk Card Entry

Users can mass import large card lists (100+ cards) using:

* Text input
* CSV upload
* Deck list paste
* Wishlist imports

The system processes the list asynchronously and aggregates results from multiple stores.

## Inventory Aggregation

* Combines inventory data from multiple vendors
* Displays best local availability
* Optimized search performance for large card lists

## Responsive UI

* Mobile-friendly interface
* Fast search experience
* Real-time search feedback
* Clean marketplace browsing experience

---

# Tech Stack

## Backend

* Java
* Spring Boot
* Spring WebFlux
* PostgreSQL
* Redis / Hazelcast (Caching)
* REST APIs
* Reactive Programming

## Frontend

* React
* TypeScript
* HTML/CSS
* Responsive UI Design

## Infrastructure

* Docker
* Docker Compose
* Kubernetes (planned)
* CI/CD Pipelines (planned)

---

# Architecture Goals

This project focuses heavily on:

* Scalability
* High-performance reactive APIs
* Efficient inventory searching
* Low-latency bulk processing
* Clean architecture and maintainability

The backend is designed to support large-scale concurrent card searches and asynchronous processing for bulk imports.

---

# Future Features

* User accounts and authentication
* Saved wishlists
* Deck building tools
* Price comparison across stores
* Marketplace purchasing integration
* Real-time inventory synchronization
* Notifications for card availability
* AI-powered card recommendations
* TCGPlayer / Scryfall integration
* Store owner dashboards

---

# Example Use Cases

## Single Card Search

A user searches for:

* “Black Lotus”
* “Lightning Bolt”
* “Dockside Extortionist”

The system:

1. Detects the user location
2. Finds nearby participating stores
3. Aggregates inventory
4. Displays stores with available copies

## Bulk Import

A user pastes a 150-card Commander deck list.

The platform:

1. Parses the list
2. Searches inventory asynchronously
3. Aggregates matches across nearby stores
4. Returns the best local availability results

---

# Performance Considerations

The platform is designed to support:

* Large inventory datasets
* High concurrent search traffic
* Reactive non-blocking APIs
* Efficient caching strategies
* Batch processing for large imports

---

# Project Status

🚧 Currently in active development.

Core features being developed:

* Store inventory aggregation
* Bulk card processing
* Geolocation services
* Reactive search APIs
* Marketplace UI

---

# Local Docker Automation

Use the helper script to package the Spring app, rebuild the website Docker image when app files changed, and restart the infrastructure Docker Compose stack:

```bash
./scripts/restart-website-stack.sh
```

Common options:

```bash
./scripts/restart-website-stack.sh --no-cache
./scripts/restart-website-stack.sh --push
./scripts/restart-website-stack.sh --seed
./scripts/restart-website-stack.sh --push --seed --no-cache
```

The script builds `kriznn/magicthegatheringwebsite:latest` by default and uses the infrastructure repo at `../MagicTheGatheringInfrastructure`. Override those when needed:

```bash
IMAGE_NAME=yourrepo/magicthegatheringwebsite:latest \
INFRA_DIR=/path/to/MagicTheGatheringInfrastructure \
./scripts/restart-website-stack.sh --push
```

---

# Vision

Magic Marketplace aims to become a modern local-first ecosystem for trading card players and stores by bridging the gap between online convenience and local game shop communities.

---

# License

This project is currently private and under active development.
