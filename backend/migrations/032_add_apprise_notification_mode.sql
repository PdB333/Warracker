-- Migration 032: Add Apprise notification mode setting

-- Add the setting to control how Apprise notifications are sent.
-- 'global': One summary notification for all expiring warranties.
-- 'individual': Separate notifications sent to each user based on their preferences.
INSERT INTO site_settings (key, value)
VALUES ('apprise_notification_mode', 'global')
ON CONFLICT (key) DO NOTHING; 