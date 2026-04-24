-- Migration: Change warranty_years to NUMERIC(5,2) to allow fractional years
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'warranties' AND column_name = 'warranty_years' AND data_type = 'integer'
    ) THEN
        ALTER TABLE warranties ALTER COLUMN warranty_years TYPE NUMERIC(5,2) USING warranty_years::NUMERIC(5,2);
    END IF;
END $$;
