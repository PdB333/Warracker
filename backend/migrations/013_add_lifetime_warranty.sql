-- backend/migrations/011_add_lifetime_warranty.sql

-- Add is_lifetime column to warranties table if it doesn't exist
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS is_lifetime BOOLEAN NOT NULL DEFAULT FALSE;

-- Make warranty_years nullable if it's not already
ALTER TABLE warranties ALTER COLUMN warranty_years DROP NOT NULL;

-- Make expiration_date nullable if it's not already
-- Note: expiration_date might already be nullable depending on previous migrations
-- We can ensure it is nullable like this:
ALTER TABLE warranties ALTER COLUMN expiration_date DROP NOT NULL;

-- Add an index for the new column
CREATE INDEX IF NOT EXISTS idx_is_lifetime ON warranties(is_lifetime); 