-- Migration 033: Add Apprise warranty scope setting

-- Add the setting to control which warranties are included in Apprise notifications.
-- 'all': Include warranties from all users (current behavior).
-- 'admin': Only include warranties belonging to the admin user.
INSERT INTO site_settings (key, value)
VALUES ('apprise_warranty_scope', 'all')
ON CONFLICT (key) DO NOTHING; 