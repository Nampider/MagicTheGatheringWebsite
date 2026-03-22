package com.project.magicWebsite.processor;

import com.project.magicWebsite.dto.request.MassEntryRequest;
import com.project.magicWebsite.dto.response.MassEntryResponse;
import com.project.magicWebsite.mapper.MassEntryMapper;
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

    public MassEntryProcessor(CardService cardService, MassEntryMapper massEntryMapper) {
        this.cardService = cardService;
        this.massEntryMapper = massEntryMapper;
    }

    public Mono<MassEntryResponse> getMassEntryResponse(MassEntryRequest massEntryRequest) {

        return Flux.fromIterable(massEntryRequest.getMassCardsRequestList())
                .flatMap(massEntry -> cardService.getCardByName(massEntry.getCardName()).map(massEntryMapper::mapToMassCardsResponse)).collectList()
                .map(MassEntryResponse::new);
    }
}
