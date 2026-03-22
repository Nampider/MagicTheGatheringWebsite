package com.project.magicWebsite.mapper;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.request.MassCardsRequest;
import com.project.magicWebsite.dto.response.MassCardsResponse;
import com.project.magicWebsite.dto.response.MassEntryResponse;
import org.springframework.stereotype.Component;

@Component
public class MassEntryMapper {
    public MassCardsResponse mapToMassCardsResponse(CardEntity cardEntity) {
        return MassCardsResponse.builder()
                .cardName(cardEntity.getName())
                .cardRarity(cardEntity.getRarity())
                .cardImageUrl(cardEntity.getImage_uri())
                .cardId(String.valueOf(cardEntity.getId())).build();
    }
}
