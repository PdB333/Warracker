-- Add is_admin_tag column to tags table
ALTER TABLE tags
ADD COLUMN IF NOT EXISTS is_admin_tag BOOLEAN NOT NULL DEFAULT FALSE;

-- Optional: Add an index for faster lookups based on admin status
CREATE INDEX IF NOT EXISTS idx_tags_is_admin_tag ON tags (is_admin_tag); 