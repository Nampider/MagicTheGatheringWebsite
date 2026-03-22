package com.project.magicWebsite.controller;

import com.project.magicWebsite.dto.request.MassEntryRequest;
import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.dto.response.MassEntryResponse;
import com.project.magicWebsite.dto.response.RecommendedCardNameListResponse;
import com.project.magicWebsite.processor.CardProcessor;
import com.project.magicWebsite.processor.MassEntryProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/magic")
@Slf4j
public class CardController {
    private final CardProcessor cardProcessor;

    private final MassEntryProcessor massEntryProcessor;

    public CardController(CardProcessor cardProcessor, MassEntryProcessor massEntryProcessor) {
        this.cardProcessor = cardProcessor;
        this.massEntryProcessor = massEntryProcessor;
    }

    @GetMapping("/mtgStore/cards/{cardName}")
    public ResponseEntity<Mono<CardSearchResponse>> getCardSearchResponse(
            @PathVariable String cardName
    ) {
        return ResponseEntity.ok(cardProcessor.getCardResponse(cardName));
    }

    @PostMapping("/mtgStore/massCards")
    public Mono<MassEntryResponse> getMassEntry(@RequestBody MassEntryRequest massEntryRequest) {
        return massEntryProcessor.getMassEntryResponse(massEntryRequest);
    }

    @GetMapping("/mtgStore/recommended/cardNames/{cardName}")
    public ResponseEntity<Mono<RecommendedCardNameListResponse>> getRecommendedCardNames(
            @PathVariable String cardName
    ) {
        return ResponseEntity.ok(cardProcessor.getRecommendedCardListResponse(cardName));
    }
}
