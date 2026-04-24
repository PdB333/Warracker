-- Migration: Update preferred_language constraint to include new languages
-- Date: 2024-12-26
-- Description: Update the constraint to allow new language codes: cs, nl, hi, fa, ar

-- Drop the existing constraint
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'chk_users_preferred_language' 
        AND table_name = 'users'
    ) THEN
        ALTER TABLE users DROP CONSTRAINT chk_users_preferred_language;
        RAISE NOTICE 'Dropped existing preferred_language constraint';
    ELSE
        RAISE NOTICE 'preferred_language constraint does not exist, skipping drop';
    END IF;
END $$;

-- Add updated constraint with all supported languages
DO $$
BEGIN
    ALTER TABLE users 
    ADD CONSTRAINT chk_users_preferred_language 
    CHECK (preferred_language IN ('en', 'fr', 'es', 'de', 'it', 'cs', 'nl', 'hi', 'fa', 'ar'));
    RAISE NOTICE 'Added updated preferred_language constraint with new languages';
END $$;

-- Update comment to reflect new supported languages
COMMENT ON COLUMN users.preferred_language IS 'User preferred language for UI localization (ISO 639-1 code): en, fr, es, de, it, cs, nl, hi, fa, ar'; 