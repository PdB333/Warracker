-- Migration: Add warranty_type field to warranties table
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS warranty_type VARCHAR(255) DEFAULT NULL;

-- Add an index for warranty type to improve search performance
CREATE INDEX IF NOT EXISTS idx_warranty_type ON warranties(warranty_type); 