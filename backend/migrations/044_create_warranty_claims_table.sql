-- Migration: Create warranty claims table
-- Description: Add support for warranty claim tracking with many-to-one relationship to warranties
-- Date: 2025-01-20

-- Create warranty_claims table
CREATE TABLE IF NOT EXISTS warranty_claims (
    id SERIAL PRIMARY KEY,
    warranty_id INTEGER NOT NULL REFERENCES warranties(id) ON DELETE CASCADE,
    claim_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Submitted',
    claim_number VARCHAR(255),
    description TEXT,
    resolution TEXT,
    resolution_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_warranty_claims_warranty_id ON warranty_claims(warranty_id);
CREATE INDEX IF NOT EXISTS idx_warranty_claims_status ON warranty_claims(status);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_warranty_claims_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER warranty_claims_updated_at
    BEFORE UPDATE ON warranty_claims
    FOR EACH ROW
    EXECUTE FUNCTION update_warranty_claims_updated_at();

