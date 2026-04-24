-- Migration: Add currency column to warranties table
-- This allows each warranty to have its own currency instead of using the global currency symbol

-- Add currency column with default value 'USD' to maintain compatibility
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'warranties' AND column_name = 'currency'
    ) THEN
        ALTER TABLE warranties ADD COLUMN currency VARCHAR(10) DEFAULT 'USD';
        RAISE NOTICE 'Added currency column to warranties table';
    ELSE
        RAISE NOTICE 'currency column already exists in warranties table';
    END IF;
END $$;

-- Set existing warranties to use USD as default currency
UPDATE warranties SET currency = 'USD' WHERE currency IS NULL;

-- Add check constraint to ensure valid currency codes (ISO 4217 standard)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_warranty_currency'
        AND conrelid = 'warranties'::regclass
    ) THEN
        ALTER TABLE warranties ADD CONSTRAINT chk_warranty_currency 
        CHECK (currency IN (
            'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 'KRW', 'CHF', 'CAD', 'AUD',
            'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'BGN', 'RON', 'HRK', 'RUB',
            'BRL', 'MXN', 'ARS', 'CLP', 'COP', 'PEN', 'VES', 'ZAR', 'EGP', 'NGN',
            'KES', 'GHS', 'MAD', 'TND', 'AED', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR',
            'JOD', 'LBP', 'ILS', 'TRY', 'IRR', 'PKR', 'BDT', 'LKR', 'NPR', 'BTN',
            'MMK', 'THB', 'VND', 'LAK', 'KHR', 'MYR', 'SGD', 'IDR', 'PHP', 'TWD',
            'HKD', 'MOP', 'KPW', 'MNT', 'KZT', 'UZS', 'TJS', 'KGS', 'TMT', 'AFN',
            'AMD', 'AZN', 'GEL', 'MDL', 'UAH', 'BYN', 'RSD', 'MKD', 'ALL', 'BAM',
            'ISK', 'FJD', 'PGK', 'SBD', 'TOP', 'VUV', 'WST', 'XPF', 'NZD'
        ));
        RAISE NOTICE 'Added check constraint for currency column';
    ELSE
        RAISE NOTICE 'Check constraint for currency already exists';
    END IF;
END $$;

-- Add index for better performance when filtering by currency
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_warranties_currency'
    ) THEN
        CREATE INDEX idx_warranties_currency ON warranties(currency);
        RAISE NOTICE 'Added index for currency column';
    ELSE
        RAISE NOTICE 'Index for currency column already exists';
    END IF;
END $$; 