-- Migration 028: Fix missing notification columns
-- Description: Ensure all required notification columns exist in user_preferences table

-- Add notification_channel column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_preferences' AND column_name='notification_channel') THEN
        ALTER TABLE user_preferences ADD COLUMN notification_channel VARCHAR(10) NOT NULL DEFAULT 'email';
    END IF;
END $$;

-- Add apprise_notification_time column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_preferences' AND column_name='apprise_notification_time') THEN
        ALTER TABLE user_preferences ADD COLUMN apprise_notification_time VARCHAR(5) NOT NULL DEFAULT '09:00';
    END IF;
END $$;

-- Add apprise_notification_frequency column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_preferences' AND column_name='apprise_notification_frequency') THEN
        ALTER TABLE user_preferences ADD COLUMN apprise_notification_frequency VARCHAR(10) NOT NULL DEFAULT 'daily';
    END IF;
END $$; 