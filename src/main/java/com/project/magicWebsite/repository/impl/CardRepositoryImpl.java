package com.project.magicWebsite.repository.impl;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.repository.CardRepository;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public class CardRepositoryImpl implements CardRepository {
    private final DatabaseClient databaseClient;

    public CardRepositoryImpl(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    @Override
    public Mono<CardEntity> findByName(String name) {
        return null;
    }

    @Override
    public Flux<CardEntity> searchByNameNormalized(String input) {

        if (input == null || input.isBlank()) {
            return Flux.empty();
        }

        String normalizedInput = "%" +
                input.toLowerCase()
                        .replaceAll("[^a-z0-9]", "") +
                "%";

        String sql = """
            SELECT
                id,
                name,
                set_name,
                rarity,
                image_uri
            FROM cards
            WHERE regexp_replace(
                    lower(name),
                    '[^a-z0-9]',
                    '',
                    'g'
                  ) LIKE :input
              AND name NOT LIKE '%//%'
            LIMIT 20
            """;

        return databaseClient.sql(sql)
                .bind("input", normalizedInput)
                .map((row, metadata) -> {
                    CardEntity card = new CardEntity();

                    card.setId(row.get("id", java.util.UUID.class));
                    card.setName(row.get("name", String.class));
                    card.setSetName(row.get("set_name", String.class));
                    card.setRarity(row.get("rarity", String.class));
                    card.setImageUri(row.get("image_uri", String.class));

                    return card;
                })
                .all();
    }
}
