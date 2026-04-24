-- Add purchase_price column to warranties table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'warranties' AND column_name = 'purchase_price'
    ) THEN
        ALTER TABLE warranties ADD COLUMN purchase_price DECIMAL(10, 2);
    END IF;
END $$; 