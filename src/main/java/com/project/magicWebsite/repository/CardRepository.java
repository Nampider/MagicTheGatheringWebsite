package com.project.magicWebsite.repository;

import com.project.magicWebsite.dao.CardEntity;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface CardRepository extends ReactiveCrudRepository<CardEntity, UUID> {
    Flux<CardEntity> findByNameContainingIgnoreCase(String name);

    Mono<CardEntity> findByName(String name);
}
