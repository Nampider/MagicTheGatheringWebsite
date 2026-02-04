package com.project.magicWebsite.repository;

import com.project.magicWebsite.dao.CardEntity;
import com.project.magicWebsite.dao.StoreEntity;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface StoreRepository extends ReactiveCrudRepository<StoreEntity, UUID> {
    Flux<StoreEntity> findByNameContainingIgnoreCase(String name);

    Mono<StoreEntity> findByName(String name);
}
