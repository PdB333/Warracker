-- Add saved_filters column to user_preferences table to store filter preferences
-- This allows filters to persist across devices for authenticated users

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'saved_filters'
    ) THEN
        ALTER TABLE user_preferences 
        ADD COLUMN saved_filters JSONB DEFAULT NULL;
        
        RAISE NOTICE 'Added saved_filters column to user_preferences table';
    ELSE
        RAISE NOTICE 'saved_filters column already exists in user_preferences table';
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON COLUMN user_preferences.saved_filters IS 'JSON object storing user filter preferences (status, tag, vendor, warranty_type, search, sortBy)';

