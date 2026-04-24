-- Migration: Add Paperless-ngx document ID columns to warranties table
-- This allows storing Paperless-ngx document IDs as an alternative to local file storage

-- Add columns for storing Paperless-ngx document IDs
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS paperless_invoice_id INTEGER DEFAULT NULL;
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS paperless_manual_id INTEGER DEFAULT NULL;
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS paperless_photo_id INTEGER DEFAULT NULL;
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS paperless_other_id INTEGER DEFAULT NULL;

-- Add indexes for better performance when filtering by Paperless-ngx document existence
CREATE INDEX IF NOT EXISTS idx_warranties_paperless_invoice ON warranties(paperless_invoice_id) WHERE paperless_invoice_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_warranties_paperless_manual ON warranties(paperless_manual_id) WHERE paperless_manual_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_warranties_paperless_photo ON warranties(paperless_photo_id) WHERE paperless_photo_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_warranties_paperless_other ON warranties(paperless_other_id) WHERE paperless_other_id IS NOT NULL; 