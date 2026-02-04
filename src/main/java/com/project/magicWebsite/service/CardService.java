package com.project.magicWebsite.service;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.repository.CardRepository;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class CardService {
    private final CardRepository cardRepository;

    public CardService(CardRepository cardRepository) {
        this.cardRepository = cardRepository;
    }

    public Flux<CardEntity> getAllCards() {
        return cardRepository.findAll();
    }

    public Mono<CardEntity> getCardById(String uuid){
        return cardRepository.findById(UUID.fromString(uuid));
    }

    public Mono<CardEntity> getCardByName(String cardName) {
        return cardRepository.findByName(cardName);
    }
}
