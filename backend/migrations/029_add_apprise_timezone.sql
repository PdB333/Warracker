-- Add the apprise_timezone column to the user_preferences table
ALTER TABLE user_preferences
ADD COLUMN apprise_timezone VARCHAR(50);

-- Update existing rows to have a default value if the main timezone is set
-- This ensures that users who have already configured a timezone will have it
-- copied to the new Apprise-specific setting.
UPDATE user_preferences
SET apprise_timezone = timezone
WHERE timezone IS NOT NULL;
