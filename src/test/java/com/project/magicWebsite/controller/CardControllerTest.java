package com.project.magicWebsite.controller;

import com.project.magicWebsite.dto.request.MassCardsRequest;
import com.project.magicWebsite.dto.response.CardSearchResponse;
import com.project.magicWebsite.processor.CardProcessor;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class CardControllerTest {

    @Mock
    private CardProcessor cardProcessor;

    @InjectMocks
    private CardController cardController;

    private MockMvc mockMvc;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(cardController).build();
    }

    @Test
    public void testSearchCardsSuccess() throws Exception {
        // Arrange
        MassCardsRequest request = new MassCardsRequest();
        CardSearchResponse response = new CardSearchResponse();
        when(cardProcessor.getCardResponse(String.valueOf(request))).thenReturn(response);

        // Act & Assert
        mockMvc.perform(MockMvcRequestBuilders.post("/cards/search")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"searchTerm\":\"test\"}"))
                .andExpect(status().isOk())
                .andExpect(MockMvcResultMatchers.content().json("{}"));
    }

    @Test
    public void testSearchCardsFailure() throws Exception {
        // Arrange
        MassCardsRequest request = new MassCardsRequest();
        when(cardProcessor.searchCards(request)).thenThrow(new RuntimeException("Error searching cards"));

        // Act & Assert
        mockMvc.perform(MockMvcRequestBuilders.post("/cards/search")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"searchTerm\":\"test\"}"))
                .andExpect(status().isInternalServerError());
    }
}