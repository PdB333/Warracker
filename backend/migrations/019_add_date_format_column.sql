-- Add date_format column to user_preferences table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'date_format'
    ) THEN
        -- Add the column with a default value of 'MDY'
        ALTER TABLE user_preferences 
        ADD COLUMN date_format VARCHAR(10) NOT NULL DEFAULT 'MDY';
        
        RAISE NOTICE 'Added date_format column to user_preferences table with default MDY';
    ELSE
        RAISE NOTICE 'date_format column already exists in user_preferences table';
    END IF;
END $$; 