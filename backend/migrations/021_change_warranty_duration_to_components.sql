-- Migration: Change warranty_years to separate year, month, and day components (Revised Logic)
DO $$
DECLARE
    warranty_years_exists BOOLEAN;
BEGIN
    -- Check if the old warranty_years column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'warranties' AND column_name = 'warranty_years'
    ) INTO warranty_years_exists;

    -- Add new columns for duration components if they don't exist
    ALTER TABLE warranties
    ADD COLUMN IF NOT EXISTS warranty_duration_years INTEGER,
    ADD COLUMN IF NOT EXISTS warranty_duration_months INTEGER,
    ADD COLUMN IF NOT EXISTS warranty_duration_days INTEGER;

    -- Populate new columns ONLY IF warranty_years exists
    IF warranty_years_exists THEN
        RAISE NOTICE 'warranty_years column exists. Populating new duration columns...';

        -- Populate from existing warranty_years data where it's not NULL
        -- This assumes warranty_years was NUMERIC(5,2)
        UPDATE warranties
        SET
            warranty_duration_years = FLOOR(warranty_years),
            warranty_duration_months = ROUND((warranty_years - FLOOR(warranty_years)) * 12),
            warranty_duration_days = 0 -- Initialize days to 0 for existing data
        WHERE warranty_years IS NOT NULL; -- Only for non-lifetime warranties if they used warranty_years

        -- Set default values for new columns for rows where warranty_years might have been NULL
        -- (e.g., for lifetime warranties)
        UPDATE warranties
        SET
            warranty_duration_years = COALESCE(warranty_duration_years, 0),
            warranty_duration_months = COALESCE(warranty_duration_months, 0),
            warranty_duration_days = COALESCE(warranty_duration_days, 0)
        WHERE is_lifetime = TRUE OR warranty_years IS NULL;

    ELSE
        RAISE NOTICE 'warranty_years column does not exist. Skipping population based on it.';
    END IF;

    -- Ensure any remaining NULLs in new columns are set to 0 (covers partial runs or cases where warranty_years was already dropped)
    RAISE NOTICE 'Ensuring new duration columns have default values...';
    UPDATE warranties
    SET
        warranty_duration_years = COALESCE(warranty_duration_years, 0),
        warranty_duration_months = COALESCE(warranty_duration_months, 0),
        warranty_duration_days = COALESCE(warranty_duration_days, 0)
    WHERE warranty_duration_years IS NULL OR warranty_duration_months IS NULL OR warranty_duration_days IS NULL;

    -- Add NOT NULL constraints and DEFAULT values to the new columns
    -- These are safe to run even if they already exist (Postgres handles it)
    RAISE NOTICE 'Applying constraints and defaults to new duration columns...';
    ALTER TABLE warranties
        ALTER COLUMN warranty_duration_years SET DEFAULT 0,
        ALTER COLUMN warranty_duration_years SET NOT NULL,
        ALTER COLUMN warranty_duration_months SET DEFAULT 0,
        ALTER COLUMN warranty_duration_months SET NOT NULL,
        ALTER COLUMN warranty_duration_days SET DEFAULT 0,
        ALTER COLUMN warranty_duration_days SET NOT NULL;

    -- Add check constraints to ensure non-negative values
    -- Use IF NOT EXISTS for constraints to make it idempotent
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_warranty_duration_years' AND conrelid = 'warranties'::regclass) THEN
        ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_years CHECK (warranty_duration_years >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_warranty_duration_months' AND conrelid = 'warranties'::regclass) THEN
        ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_months CHECK (warranty_duration_months >= 0 AND warranty_duration_months < 12); -- Months should be less than 12
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_warranty_duration_days' AND conrelid = 'warranties'::regclass) THEN
        ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_days CHECK (warranty_duration_days >= 0 AND warranty_duration_days < 366); -- Days reasonable upper limit
    END IF;

    -- Drop the old warranty_years column ONLY IF it existed at the start
    IF warranty_years_exists THEN
        RAISE NOTICE 'Dropping old warranty_years column...';
        ALTER TABLE warranties DROP COLUMN warranty_years;
    END IF;

    RAISE NOTICE 'Migration 021 completed successfully.';

END $$;
