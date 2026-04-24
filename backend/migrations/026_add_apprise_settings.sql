-- Migration: Add Apprise notification settings
-- Description: Adds Apprise notification configuration options to site_settings table

-- Add Apprise notification settings
INSERT INTO site_settings (key, value) VALUES
('apprise_enabled', 'false'),
('apprise_urls', ''),
('apprise_expiration_days', '7,30'),
('apprise_notification_time', '09:00'),
('apprise_title_prefix', '[Warracker]'),
('apprise_test_url', '')
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = CURRENT_TIMESTAMP; 