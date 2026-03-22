package com.project.magicWebsite.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CardSearchResponse {

    @JsonProperty("id")
    public String cardId;

    @JsonProperty("name")
    public String cardName;

    @JsonProperty("rarity")
    public String cardRarity;

    @JsonProperty("setName")
    public String setName;

    @JsonProperty("imageUri")
    public String cardImageUrl;

    @JsonProperty("stores")
    public List<StoreInventoryResponse> storeInventoryResponse;
}
