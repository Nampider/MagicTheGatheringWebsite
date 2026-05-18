package com.project.magicWebsite.dao;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.util.UUID;

@Table("cards")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CardEntity {

    @Id
    private UUID id;

    @Column("scryfall_id")
    private UUID scryfallId;

    private String name;

    @Column("card_state")
    private String cardState;

    @Column("set_code")
    private String setCode;

    @Column("set_name")
    private String setName;

    private String rarity;

    @Column("type_line")
    private String typeLine;

    private String artist;

    @Column("collector_number")
    private String collectorNumber;

    @Column("image_uri")
    private String imageUri;
}
