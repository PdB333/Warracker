-- Migration: Add model_number column to warranties table
-- Date: 2025-10-09

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'warranties'
          AND column_name = 'model_number'
    ) THEN
        ALTER TABLE warranties ADD COLUMN model_number VARCHAR(255) DEFAULT NULL;
        RAISE NOTICE 'Added model_number column to warranties table';
    ELSE
        RAISE NOTICE 'model_number column already exists in warranties table';
    END IF;
END $$;

-- Optional index to speed up searches/filtering by model number
CREATE INDEX IF NOT EXISTS idx_warranties_model_number ON warranties(model_number);


