ALTER TABLE warranties
ADD COLUMN IF NOT EXISTS additional_notification_email VARCHAR(255);
