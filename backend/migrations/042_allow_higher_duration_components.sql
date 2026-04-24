-- Migration: Allow higher values for warranty duration months and days

DO $$
BEGIN
    ALTER TABLE warranties DROP CONSTRAINT IF EXISTS chk_warranty_duration_months;
    ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_months CHECK (warranty_duration_months >= 0);

    ALTER TABLE warranties DROP CONSTRAINT IF EXISTS chk_warranty_duration_days;
    ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_days CHECK (warranty_duration_days >= 0);

    ALTER TABLE warranties DROP CONSTRAINT IF EXISTS chk_warranty_duration_years;
    ALTER TABLE warranties ADD CONSTRAINT chk_warranty_duration_years CHECK (warranty_duration_years >= 0);
END $$; 