SET search_path TO cards_schema;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_stores_latitude'
          AND conrelid = 'cards_schema.stores'::regclass
    ) THEN
        ALTER TABLE stores
            ADD CONSTRAINT chk_stores_latitude
                CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_stores_longitude'
          AND conrelid = 'cards_schema.stores'::regclass
    ) THEN
        ALTER TABLE stores
            ADD CONSTRAINT chk_stores_longitude
                CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_stores_coordinates ON stores(latitude, longitude);

COMMENT ON COLUMN store_inventory.distance_km IS
    'Legacy seed value. API distance is calculated from store coordinates and the requesting user location.';
