package com.project.magicWebsite.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoreInventoryResponse {

    @JsonProperty("storeId")
    public String storeId;

    @JsonProperty("storeName")
    public String storeName;

    @JsonProperty("distanceKm")
    public String distanceKm;

    @JsonProperty("price")
    public String price;

    @JsonProperty("quantity")
    public String quantity;

    @JsonProperty("condition")
    public String condition;

    @JsonProperty("foil")
    public Boolean foil;

    @JsonProperty("storeLocation")
    public StoreLocationResponse storeLocation;
}
