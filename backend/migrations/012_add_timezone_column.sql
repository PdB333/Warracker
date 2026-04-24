-- Add timezone column to user_preferences table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'timezone'
    ) THEN
        ALTER TABLE user_preferences 
        ADD COLUMN timezone VARCHAR(50) NOT NULL DEFAULT 'UTC';
        
        RAISE NOTICE 'Added timezone column to user_preferences table';
    ELSE
        RAISE NOTICE 'timezone column already exists in user_preferences table';
    END IF;
END $$; 