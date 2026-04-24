-- Migration: Add document URL columns to warranties table
-- Description: Add support for external URLs for invoices, manuals, and other documents
-- Date: 2025-01-20

-- Add nullable TEXT columns for storing document URLs
ALTER TABLE warranties
ADD COLUMN IF NOT EXISTS invoice_url TEXT,
ADD COLUMN IF NOT EXISTS manual_url TEXT,
ADD COLUMN IF NOT EXISTS other_document_url TEXT;
