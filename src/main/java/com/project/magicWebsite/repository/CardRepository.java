package com.project.magicWebsite.repository;

import com.project.magicWebsite.dao.CardEntity;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface CardRepository {
    Mono<CardEntity> findByName(String name);

    Flux<CardEntity> searchByNameNormalized(String name);
}