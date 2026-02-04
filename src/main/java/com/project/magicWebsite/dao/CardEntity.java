package com.project.magicWebsite.dao;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.util.UUID;

@Table("cards")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CardEntity {
    @Id
    private UUID id;

    private UUID scryfall_id;

    private String name;

    private String card_state;

    private String set_code;

    private String set_name;

    private String rarity;

    private String type_line;

    private String artist;

    private String collector_number;

    private String image_uri;
}
