-- Add serial numbers table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'serial_numbers'
    ) THEN
        CREATE TABLE serial_numbers (
            id SERIAL PRIMARY KEY,
            warranty_id INTEGER NOT NULL,
            serial_number VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (warranty_id) REFERENCES warranties(id) ON DELETE CASCADE
        );

        -- Create indexes only if we created the table
        CREATE INDEX idx_warranty_id ON serial_numbers(warranty_id);
        CREATE INDEX idx_serial_number ON serial_numbers(serial_number);
    END IF;
END $$;