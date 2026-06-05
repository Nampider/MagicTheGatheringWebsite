package com.project.magicWebsite.mapper;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dto.response.MassCardsResponse;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class MassEntryMapper {
    public MassCardsResponse mapToMassCardsResponse(
            CardEntity cardEntity,
            List<StoreInventoryResponse> storeInventoryResponses
    ) {
        return MassCardsResponse.builder()
                .cardName(cardEntity.getName())
                .cardRarity(cardEntity.getRarity())
                .cardImageUrl(cardEntity.getImageUri())
                .setName(cardEntity.getSetName())
                .cardId(String.valueOf(cardEntity.getId()))
                .storeInventoryResponse(storeInventoryResponses)
                .build();
    }
}
