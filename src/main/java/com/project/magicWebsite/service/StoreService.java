package com.project.magicWebsite.service;

import com.project.magicWebsite.dao.StoreEntity;
import com.project.magicWebsite.repository.StoreRepository;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
public class StoreService {
    private final StoreRepository storeRepository;

    public StoreService(StoreRepository storeRepository) {
        this.storeRepository = storeRepository;
    }

    public Flux<StoreEntity> getAllStores() {
        return storeRepository.findAll();
    }

    public Mono<StoreEntity> getStoreById(String uuid){
        return storeRepository.findById(UUID.fromString(uuid));
    }

    public Mono<StoreEntity> getStoreByName(String storeName) {
        return storeRepository.findByName(storeName);
    }
}
