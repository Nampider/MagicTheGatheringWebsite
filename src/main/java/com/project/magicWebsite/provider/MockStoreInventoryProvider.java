package com.project.magicWebsite.provider;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import com.project.magicWebsite.dto.response.StoreLocationResponse;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;

public class MockStoreInventoryProvider implements StoreInventoryProvider {

    @Override
    public Mono<List<StoreInventoryResponse>> getInventoryForCard(
            CardEntity cardEntity,
            BigDecimal userLatitude,
            BigDecimal userLongitude
    ) {
        int cardSeed = Math.abs(cardEntity.getName().toLowerCase().hashCode());
        String basePrice = String.format("$%d.%02d", 3 + (cardSeed % 18), cardSeed % 100);
        BigDecimal sanFranciscoLatitude = new BigDecimal("37.7749");
        BigDecimal sanFranciscoLongitude = new BigDecimal("-122.4194");
        BigDecimal oaklandLatitude = new BigDecimal("37.8044");
        BigDecimal oaklandLongitude = new BigDecimal("-122.2712");

        return Mono.just(List.of(
                StoreInventoryResponse.builder()
                        .storeId("mock-store-001")
                        .storeName("Mana Vault Trading")
                        .distanceKm(distanceKm(userLatitude, userLongitude, sanFranciscoLatitude, sanFranciscoLongitude))
                        .price(basePrice)
                        .quantity(String.valueOf(1 + (cardSeed % 8)))
                        .condition("Near Mint")
                        .foil(false)
                        .storeLocation(StoreLocationResponse.builder()
                                .latitude(sanFranciscoLatitude)
                                .longitude(sanFranciscoLongitude)
                                .city("San Francisco")
                                .state("CA")
                                .country("USA")
                                .build())
                        .build(),
                StoreInventoryResponse.builder()
                        .storeId("mock-store-002")
                        .storeName("Planeswalker Games")
                        .distanceKm(distanceKm(userLatitude, userLongitude, oaklandLatitude, oaklandLongitude))
                        .price(String.format("$%d.%02d", 5 + (cardSeed % 24), (cardSeed / 3) % 100))
                        .quantity(String.valueOf(1 + ((cardSeed / 5) % 5)))
                        .condition("Lightly Played")
                        .foil(cardSeed % 2 == 0)
                        .storeLocation(StoreLocationResponse.builder()
                                .latitude(oaklandLatitude)
                                .longitude(oaklandLongitude)
                                .city("Oakland")
                                .state("CA")
                                .country("USA")
                                .build())
                        .build()
        ));
    }

    private String distanceKm(
            BigDecimal userLatitude,
            BigDecimal userLongitude,
            BigDecimal storeLatitude,
            BigDecimal storeLongitude
    ) {
        if (userLatitude == null || userLongitude == null) {
            return null;
        }

        double latitudeDelta = Math.toRadians(storeLatitude.doubleValue() - userLatitude.doubleValue());
        double longitudeDelta = Math.toRadians(storeLongitude.doubleValue() - userLongitude.doubleValue());
        double userLatitudeRadians = Math.toRadians(userLatitude.doubleValue());
        double storeLatitudeRadians = Math.toRadians(storeLatitude.doubleValue());
        double haversine = Math.pow(Math.sin(latitudeDelta / 2), 2)
                + Math.cos(userLatitudeRadians) * Math.cos(storeLatitudeRadians)
                * Math.pow(Math.sin(longitudeDelta / 2), 2);

        return String.format("%.1f", 6371.0 * 2 * Math.asin(Math.sqrt(haversine)));
    }
}
