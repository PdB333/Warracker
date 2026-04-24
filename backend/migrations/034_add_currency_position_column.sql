-- Migration: Add currency_position column to user_preferences
-- This allows users to choose whether currency symbol appears on left or right of numbers

-- Add currency_position column with default value 'left' to maintain existing behavior
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_preferences' AND column_name = 'currency_position'
    ) THEN
        ALTER TABLE user_preferences ADD COLUMN currency_position VARCHAR(10) DEFAULT 'left';
        RAISE NOTICE 'Added currency_position column to user_preferences table';
    ELSE
        RAISE NOTICE 'currency_position column already exists in user_preferences table';
    END IF;
END $$;

-- Update any existing NULL or invalid values to 'left' to ensure constraint compliance
UPDATE user_preferences SET currency_position = 'left' 
WHERE currency_position IS NULL OR currency_position NOT IN ('left', 'right');

-- Add constraint to ensure only valid values (only if constraint doesn't already exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'chk_currency_position' 
        AND table_name = 'user_preferences'
    ) THEN
        ALTER TABLE user_preferences ADD CONSTRAINT chk_currency_position CHECK (currency_position IN ('left', 'right'));
        RAISE NOTICE 'Added check constraint for currency_position column';
    ELSE
        RAISE NOTICE 'Check constraint for currency_position already exists';
    END IF;
END $$; 