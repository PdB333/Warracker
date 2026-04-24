-- Add notification_channel column to user_preferences table
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS notification_channel VARCHAR(10) NOT NULL DEFAULT 'email';

-- Add apprise_notification_time column to user_preferences table
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS apprise_notification_time VARCHAR(5) NOT NULL DEFAULT '09:00';

-- Add apprise_notification_frequency column to user_preferences table
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS apprise_notification_frequency VARCHAR(10) NOT NULL DEFAULT 'daily';
