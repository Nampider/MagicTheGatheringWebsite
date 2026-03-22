package com.project.magicWebsite.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MassCardsRequest {
    @JsonProperty("quantity")
    public Integer quantity;

    @JsonProperty("name")
    public String cardName;

    @JsonProperty("set")
    public String set;

    @JsonProperty("condition")
    public String condition;
}
