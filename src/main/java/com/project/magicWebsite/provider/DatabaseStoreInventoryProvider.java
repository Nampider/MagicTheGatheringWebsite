package com.project.magicWebsite.provider;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import com.project.magicWebsite.dto.response.StoreLocationResponse;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Component
public class DatabaseStoreInventoryProvider implements StoreInventoryProvider {
    private final DatabaseClient databaseClient;

    public DatabaseStoreInventoryProvider(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    @Override
    public Mono<List<StoreInventoryResponse>> getInventoryForCard(
            CardEntity cardEntity,
            BigDecimal userLatitude,
            BigDecimal userLongitude
    ) {
        boolean hasUserLocation = userLatitude != null && userLongitude != null;
        String distanceExpression = hasUserLocation
                ? """
                    CAST(
                        6371.0 * 2 * ASIN(SQRT(
                            POWER(SIN(RADIANS((s.latitude - :userLatitude) / 2)), 2)
                            + COS(RADIANS(:userLatitude)) * COS(RADIANS(s.latitude))
                            * POWER(SIN(RADIANS((s.longitude - :userLongitude) / 2)), 2)
                        ))
                        AS NUMERIC
                    ) AS distance_km
                    """
                : "NULL::NUMERIC AS distance_km";

        String sql = """
                SELECT
                    s.id AS store_id,
                    s.name AS store_name,
                    s.latitude,
                    s.longitude,
                    s.city,
                    s.state,
                    s.country,
                    %s,
                    si.price,
                    si.quantity,
                    si.condition,
                    si.foil
                FROM store_inventory si
                JOIN stores s ON s.id = si.store_id
                WHERE si.card_id = :cardId
                ORDER BY si.price ASC, s.name ASC
                """.formatted(distanceExpression);

        DatabaseClient.GenericExecuteSpec query = databaseClient.sql(sql)
                .bind("cardId", cardEntity.getId());

        if (hasUserLocation) {
            query = query
                    .bind("userLatitude", userLatitude)
                    .bind("userLongitude", userLongitude);
        }

        return query
                .map((row, metadata) -> StoreInventoryResponse.builder()
                        .storeId(String.valueOf(row.get("store_id", UUID.class)))
                        .storeName(row.get("store_name", String.class))
                        .distanceKm(formatDecimal(row.get("distance_km", BigDecimal.class)))
                        .price(formatPrice(row.get("price", BigDecimal.class)))
                        .quantity(String.valueOf(row.get("quantity", Integer.class)))
                        .condition(row.get("condition", String.class))
                        .foil(row.get("foil", Boolean.class))
                        .storeLocation(StoreLocationResponse.builder()
                                .latitude(row.get("latitude", BigDecimal.class))
                                .longitude(row.get("longitude", BigDecimal.class))
                                .city(row.get("city", String.class))
                                .state(row.get("state", String.class))
                                .country(row.get("country", String.class))
                                .build())
                        .build())
                .all()
                .collectList();
    }

    private String formatDecimal(BigDecimal value) {
        return value == null ? null : value.stripTrailingZeros().toPlainString();
    }

    private String formatPrice(BigDecimal value) {
        return value == null ? null : "$" + value.setScale(2).toPlainString();
    }
}
