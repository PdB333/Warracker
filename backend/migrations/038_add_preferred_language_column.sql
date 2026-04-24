-- Migration: Add preferred_language column to users table
-- Date: 2024-01-01
-- Description: Add language preference support for internationalization

-- Add preferred_language column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(5) DEFAULT 'en';

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_users_preferred_language ON users(preferred_language);

-- Add constraint to ensure only valid language codes (with error handling)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'chk_users_preferred_language' 
        AND table_name = 'users'
    ) THEN
        ALTER TABLE users 
        ADD CONSTRAINT chk_users_preferred_language 
        CHECK (preferred_language IN ('en', 'fr', 'es', 'de', 'it'));
    END IF;
END $$;

COMMENT ON COLUMN users.preferred_language IS 'User preferred language for UI localization (ISO 639-1 code)';

-- Set default language for existing users
UPDATE users 
SET preferred_language = 'en' 
WHERE preferred_language IS NULL; 