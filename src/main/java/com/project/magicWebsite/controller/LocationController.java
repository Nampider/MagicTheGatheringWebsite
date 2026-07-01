package com.project.magicWebsite.controller;

import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.processor.CardProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/magic")
@Slf4j
public class LocationController {

    private final CardProcessor cardProcessor;

    public LocationController(CardProcessor cardProcessor) {
        this.cardProcessor = cardProcessor;
    }

    @GetMapping("/mtgStore/location/{cardName}")
    public ResponseEntity<Flux<CardSearchResponse>> getCardSearchResponse(
            @PathVariable String cardName,
            @RequestParam BigDecimal latitude,
            @RequestParam BigDecimal longitude
    ) {
        return ResponseEntity.ok(cardProcessor.getCardResponse(cardName, latitude, longitude));
    }

}
