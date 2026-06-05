package com.project.magicWebsite.provider;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import com.project.magicWebsite.dto.response.StoreLocationResponse;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;

public class MockStoreInventoryProvider implements StoreInventoryProvider {

    @Override
    public Mono<List<StoreInventoryResponse>> getInventoryForCard(CardEntity cardEntity) {
        int cardSeed = Math.abs(cardEntity.getName().toLowerCase().hashCode());
        String basePrice = String.format("$%d.%02d", 3 + (cardSeed % 18), cardSeed % 100);

        return Mono.just(List.of(
                StoreInventoryResponse.builder()
                        .storeId("mock-store-001")
                        .storeName("Mana Vault Trading")
                        .distanceKm("3.2")
                        .price(basePrice)
                        .quantity(String.valueOf(1 + (cardSeed % 8)))
                        .condition("Near Mint")
                        .foil(false)
                        .storeLocation(StoreLocationResponse.builder()
                                .latitude(new BigDecimal("37.7749"))
                                .longitude(new BigDecimal("-122.4194"))
                                .city("San Francisco")
                                .state("CA")
                                .country("USA")
                                .build())
                        .build(),
                StoreInventoryResponse.builder()
                        .storeId("mock-store-002")
                        .storeName("Planeswalker Games")
                        .distanceKm("7.8")
                        .price(String.format("$%d.%02d", 5 + (cardSeed % 24), (cardSeed / 3) % 100))
                        .quantity(String.valueOf(1 + ((cardSeed / 5) % 5)))
                        .condition("Lightly Played")
                        .foil(cardSeed % 2 == 0)
                        .storeLocation(StoreLocationResponse.builder()
                                .latitude(new BigDecimal("37.8044"))
                                .longitude(new BigDecimal("-122.2712"))
                                .city("Oakland")
                                .state("CA")
                                .country("USA")
                                .build())
                        .build()
        ));
    }
}
