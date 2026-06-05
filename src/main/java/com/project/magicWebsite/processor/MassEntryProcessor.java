package com.project.magicWebsite.processor;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.request.MassEntryRequest;
import com.project.magicWebsite.dto.response.MassCardsResponse;
import com.project.magicWebsite.dto.response.MassEntryResponse;
import com.project.magicWebsite.mapper.MassEntryMapper;
import com.project.magicWebsite.provider.StoreInventoryProvider;
import com.project.magicWebsite.service.CardService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Component
@Slf4j
public class MassEntryProcessor {
    private final CardService cardService;

    private final MassEntryMapper massEntryMapper;

    private final StoreInventoryProvider storeInventoryProvider;

    public MassEntryProcessor(
            CardService cardService,
            MassEntryMapper massEntryMapper,
            StoreInventoryProvider storeInventoryProvider
    ) {
        this.cardService = cardService;
        this.massEntryMapper = massEntryMapper;
        this.storeInventoryProvider = storeInventoryProvider;
    }

    public Mono<MassEntryResponse> getMassEntryResponse(MassEntryRequest massEntryRequest) {

        return Flux.fromIterable(massEntryRequest.getMassCardsRequestList())
                .flatMap(massEntry -> cardService.getCardByName(massEntry.getCardName()))
                .flatMap(this::mapMassCardWithStoreInventory)
                .collectList()
                .map(MassEntryResponse::new);
    }

    private Mono<MassCardsResponse> mapMassCardWithStoreInventory(CardEntity cardEntity) {
        return storeInventoryProvider.getInventoryForCard(cardEntity)
                .map(storeInventoryResponses -> massEntryMapper.mapToMassCardsResponse(
                        cardEntity,
                        storeInventoryResponses
                ));
    }
}
