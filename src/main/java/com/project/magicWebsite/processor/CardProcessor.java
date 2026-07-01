package com.project.magicWebsite.processor;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.dto.response.RecommendedCardNameResponse;
import com.project.magicWebsite.dto.response.RecommendedCardNameListResponse;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import com.project.magicWebsite.mapper.CardStoreMapper;
import com.project.magicWebsite.provider.StoreInventoryProvider;
import com.project.magicWebsite.service.CardService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;

@Component
@Slf4j
public class CardProcessor {
    private final CardService cardService;

    private final CardStoreMapper cardStoreMapper;

    private final StoreInventoryProvider storeInventoryProvider;

    public CardProcessor(
            CardService cardService,
            CardStoreMapper cardStoreMapper,
            StoreInventoryProvider storeInventoryProvider
    ) {
        this.cardService = cardService;
        this.cardStoreMapper = cardStoreMapper;
        this.storeInventoryProvider = storeInventoryProvider;
    }

    public Flux<CardSearchResponse> getCardResponse(
            String cardName,
            BigDecimal userLatitude,
            BigDecimal userLongitude
    ) {
        return cardService.getCardByName(cardName)
                .flatMap(card -> mapCardWithStoreInventory(card, userLatitude, userLongitude));
    }

    public Mono<RecommendedCardNameListResponse> getRecommendedCardListResponse(String cardName) {
        return cardService.getCardByName(cardName)
                .flatMap(card -> storeInventoryProvider.getInventoryForCard(card, null, null)
                        .map(storeInventoryResponses -> RecommendedCardNameResponse.builder()
                                .cardName(card.getName())
                                .cardImageUrl(card.getImageUri())
                                .storeInventoryResponse(storeInventoryResponses)
                                .build()))
                .take(10)
                .collectList()
                .map(recommendedCards -> RecommendedCardNameListResponse.builder()
                        .massCardsResponseList(recommendedCards)
                        .build());
    }

    private Mono<CardSearchResponse> mapCardWithStoreInventory(
            CardEntity card,
            BigDecimal userLatitude,
            BigDecimal userLongitude
    ) {
        return storeInventoryProvider.getInventoryForCard(card, userLatitude, userLongitude)
                .map(storeInventoryResponses -> buildCardSearchResponse(card, storeInventoryResponses));
    }

    private CardSearchResponse buildCardSearchResponse(
            CardEntity card,
            List<StoreInventoryResponse> storeInventoryResponses
    ) {
        CardSearchResponse cardSearchResponse = cardStoreMapper.cardSearchResponseMapper(card);
        cardSearchResponse.setStoreInventoryResponse(storeInventoryResponses);

        return cardSearchResponse;
    }
}
