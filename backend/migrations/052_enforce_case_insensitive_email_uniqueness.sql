-- Enforce case-insensitive uniqueness for user emails
DO $$
BEGIN
    IF EXISTS (
        SELECT LOWER(email)
        FROM users
        GROUP BY LOWER(email)
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Cannot enforce case-insensitive email uniqueness: duplicate emails exist when normalized to lowercase.';
    END IF;
END
$$;

UPDATE users
SET email = LOWER(email)
WHERE email <> LOWER(email);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower_unique ON users (LOWER(email));
