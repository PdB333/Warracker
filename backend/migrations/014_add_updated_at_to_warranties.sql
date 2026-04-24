-- backend/migrations/012_add_updated_at_to_warranties.sql

-- Add the updated_at column if it doesn't exist
ALTER TABLE warranties
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create or replace a function to automatically update the timestamp on row update
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if NEW record is distinct from OLD record to avoid unnecessary updates
    IF NEW IS DISTINCT FROM OLD THEN
        NEW.updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop the trigger if it already exists to avoid errors on re-run
DROP TRIGGER IF EXISTS update_warranties_updated_at ON warranties;

-- Create the trigger to call the function before any UPDATE on the warranties table
CREATE TRIGGER update_warranties_updated_at
BEFORE UPDATE ON warranties
FOR EACH ROW
EXECUTE FUNCTION update_modified_column(); 