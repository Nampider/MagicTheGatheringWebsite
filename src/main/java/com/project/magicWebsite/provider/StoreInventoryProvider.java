package com.project.magicWebsite.provider;

import com.project.magicWebsite.dto.response.CardSearchResponse;
import reactor.core.publisher.Flux;

public interface StoreInventoryProvider {
    Flux<CardSearchResponse> getCards();
}
