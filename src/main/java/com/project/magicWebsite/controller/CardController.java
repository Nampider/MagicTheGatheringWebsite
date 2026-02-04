package com.project.magicWebsite.controller;

import com.project.magicWebsite.dto.CardSearchResponse;
import com.project.magicWebsite.processor.CardProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import javax.smartcardio.Card;

@RestController
@RequestMapping("/api/magic")
@Slf4j
public class CardController {
    private final CardProcessor cardProcessor;

    public CardController(CardProcessor cardProcessor) {
        this.cardProcessor = cardProcessor;
    }

    @GetMapping("/mtgStore/cards/{cardName}")
    public ResponseEntity<Mono<CardSearchResponse>> getCardSearchResponse(
            @PathVariable String cardName
    ) {
        return ResponseEntity.ok(cardProcessor.getCardResponse(cardName));
    }
}
