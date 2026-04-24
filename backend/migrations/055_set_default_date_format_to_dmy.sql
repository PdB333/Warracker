-- Ensure new user preferences default to DMY (dd/mm/yyyy)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_preferences'
          AND column_name = 'date_format'
    ) THEN
        ALTER TABLE user_preferences
        ALTER COLUMN date_format SET DEFAULT 'DMY';

        -- Backfill only invalid empty values, keep existing explicit formats untouched
        UPDATE user_preferences
        SET date_format = 'DMY'
        WHERE date_format IS NULL OR TRIM(date_format) = '';

        RAISE NOTICE 'Set user_preferences.date_format default to DMY';
    ELSE
        RAISE NOTICE 'Skipped: user_preferences.date_format column not found';
    END IF;
END $$;
