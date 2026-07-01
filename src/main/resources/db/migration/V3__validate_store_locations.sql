ALTER TABLE stores
    ADD CONSTRAINT chk_stores_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    ADD CONSTRAINT chk_stores_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);

CREATE INDEX idx_stores_coordinates ON stores(latitude, longitude);

COMMENT ON COLUMN store_inventory.distance_km IS
    'Legacy seed value. API distance is calculated from store coordinates and the requesting user location.';
