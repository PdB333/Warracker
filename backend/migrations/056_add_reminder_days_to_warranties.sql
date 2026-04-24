-- Add per-warranty custom reminder days (comma-separated list, e.g. "30,7,1")
ALTER TABLE warranties
ADD COLUMN IF NOT EXISTS reminder_days TEXT;
