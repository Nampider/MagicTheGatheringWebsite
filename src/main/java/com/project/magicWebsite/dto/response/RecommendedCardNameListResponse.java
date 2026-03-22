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
public class RecommendedCardNameListResponse {
    @JsonProperty("recommendedCardNames")
    private List<RecommendedCardNameResponse> massCardsResponseList;
}
