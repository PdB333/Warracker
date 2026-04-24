-- Migration to add vendor field to warranties table
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS
vendor VARCHAR(255) NULL; 