ALTER TABLE warranties ADD COLUMN IF NOT EXISTS archived_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_warranties_archived_at_null ON warranties (archived_at) WHERE archived_at IS NULL;


