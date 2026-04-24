-- Migration: Add paperless_view_in_app preference to user_preferences table
-- This allows users to choose whether to view Paperless-ngx documents within Warracker or in the Paperless domain

-- Add column for storing Paperless-ngx document viewing preference
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS paperless_view_in_app BOOLEAN DEFAULT FALSE;

-- Add comment for documentation
COMMENT ON COLUMN user_preferences.paperless_view_in_app IS 'Whether to view Paperless-ngx documents within Warracker interface instead of opening them in Paperless domain'; 