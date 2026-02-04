package com.project.magicWebsite.dao;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.util.UUID;

@Table("stores")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class StoreEntity {
    private UUID id;

    private String name;

    private BigDecimal latitude;

    private BigDecimal longitude;

    private String address;

    private String city;

    private String state;

    private String country;

    private String postal_code;

    private String phone;

    private String email;

    private String website;
}
