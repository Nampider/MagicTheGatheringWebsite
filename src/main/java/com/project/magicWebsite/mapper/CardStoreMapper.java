package com.project.magicWebsite.mapper;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.CardSearchResponse;
import org.springframework.stereotype.Component;

@Component
public class CardStoreMapper {
    public CardSearchResponse cardSearchResponseMapper(CardEntity cardEntity) {
        CardSearchResponse cardSearchResponse = new CardSearchResponse();
        cardSearchResponse.setCardName(cardEntity.getName());
        cardSearchResponse.setCardRarity(cardEntity.getRarity());
        cardSearchResponse.setCardId(cardEntity.getId().toString());
        cardSearchResponse.setCardImageUrl(cardEntity.getImageUri());
        cardSearchResponse.setSetName(cardEntity.getSetName());

        return cardSearchResponse;
    }
}
