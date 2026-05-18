package com.project.magicWebsite.mapper;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dao.StoreEntity;
import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.dto.response.StoreInventoryResponse;
import com.project.magicWebsite.dto.response.StoreLocationResponse;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class CardStoreMapper {
    public CardSearchResponse cardSearchResponseMapper(CardEntity cardEntity) {
        CardSearchResponse cardSearchResponse = new CardSearchResponse();
        cardSearchResponse.setCardName(cardEntity.getName());
        cardSearchResponse.setCardRarity(cardEntity.getRarity());
        cardSearchResponse.setCardId(cardEntity.getId().toString());
        cardSearchResponse.setCardImageUrl(cardEntity.getImageUri());
        cardSearchResponse.setSetName(cardEntity.getSetName());

//        StoreInventoryResponse storeInventoryResponse = new StoreInventoryResponse();
//        storeInventoryResponse.setStoreId(storeEntity.getId().toString());
//        storeInventoryResponse.setStoreName(storeEntity.getName());
////        storeInventoryResponse.setFoil(storeEntity.getFoil());
//
//        StoreLocationResponse storeLocationResponse = new StoreLocationResponse();
//        storeLocationResponse.setCity(storeEntity.getCity());
//        storeLocationResponse.setLatitude(storeEntity.getLatitude());
//        storeLocationResponse.setLongitude(storeEntity.getLongitude());
//        storeLocationResponse.setState(storeEntity.getState());
//        storeLocationResponse.setCountry(storeEntity.getCountry());
//
//        storeInventoryResponse.setStoreLocation(storeLocationResponse);
//        cardSearchResponse.setStoreInventoryResponse(List.of(storeInventoryResponse));

        return cardSearchResponse;
    }
}
