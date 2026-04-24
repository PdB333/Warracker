-- Add notification preferences columns if they don't exist
DO $$ 
BEGIN
    -- Check if notification_frequency column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'notification_frequency'
    ) THEN
        ALTER TABLE user_preferences 
        ADD COLUMN notification_frequency VARCHAR(10) NOT NULL DEFAULT 'daily';
    END IF;

    -- Check if notification_time column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_preferences' 
        AND column_name = 'notification_time'
    ) THEN
        ALTER TABLE user_preferences 
        ADD COLUMN notification_time VARCHAR(5) NOT NULL DEFAULT '09:00';
    END IF;
END $$; 