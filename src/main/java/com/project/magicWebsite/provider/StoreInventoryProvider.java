package com.project.magicWebsite.provider;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;

public interface StoreInventoryProvider {
    Mono<List<StoreInventoryResponse>> getInventoryForCard(
            CardEntity cardEntity,
            BigDecimal userLatitude,
            BigDecimal userLongitude
    );
}
