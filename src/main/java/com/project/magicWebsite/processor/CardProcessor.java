package com.project.magicWebsite.processor;

import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.dto.response.RecommendedCardNameListResponse;
import com.project.magicWebsite.mapper.CardStoreMapper;
import com.project.magicWebsite.service.CardService;
import com.project.magicWebsite.service.StoreService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Component
@Slf4j
public class CardProcessor {
    private final CardService cardService;

    private final StoreService storeService;

    private final CardStoreMapper cardStoreMapper;

    public CardProcessor(CardService cardService, StoreService storeService, CardStoreMapper cardStoreMapper) {
        this.cardService = cardService;
        this.storeService = storeService;
        this.cardStoreMapper = cardStoreMapper;
    }

    public Mono<CardSearchResponse> getCardResponse(String cardName) {
        return cardService.getCardByName(cardName).flatMap(card -> {
            return storeService.getStoreByName("Mana Vault Trading").map(store -> {
                return cardStoreMapper.cardSearchResponseMapper(card, store);
            });
        }).single();
    }

    public Mono<RecommendedCardNameListResponse> getRecommendedCardListResponse(String cardName) {
        return Mono.just(new RecommendedCardNameListResponse());
    }
}
