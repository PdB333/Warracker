-- Migration: Add product_photo_path column to warranties table
-- This allows storing product photos for warranty cards

ALTER TABLE warranties ADD COLUMN IF NOT EXISTS product_photo_path VARCHAR(255) DEFAULT NULL;

-- Add index for better performance when filtering by photo existence
CREATE INDEX IF NOT EXISTS idx_warranties_photo_path ON warranties(product_photo_path) WHERE product_photo_path IS NOT NULL; 