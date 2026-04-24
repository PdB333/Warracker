-- backend/migrations/000_create_warranties_table.sql

-- Create warranties table if it doesn't exist
CREATE TABLE IF NOT EXISTS warranties (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    purchase_date DATE NOT NULL,
    warranty_years INTEGER NOT NULL,
    expiration_date DATE,
    invoice_path TEXT,
    manual_path TEXT,
    product_url TEXT,
    notes TEXT,
    -- purchase_price is added by migration 002
    -- user_id is added by migration 003
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_expiration_date ON warranties(expiration_date);
CREATE INDEX IF NOT EXISTS idx_product_name ON warranties(product_name); 