-- Migration: Add notes column to warranties table if it does not exist
ALTER TABLE warranties ADD COLUMN IF NOT EXISTS notes TEXT; 