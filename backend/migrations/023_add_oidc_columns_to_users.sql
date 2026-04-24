-- Add oidc_sub and oidc_issuer columns to the users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS oidc_sub VARCHAR(255),
ADD COLUMN IF NOT EXISTS oidc_issuer VARCHAR(255);

-- Make password_hash nullable for OIDC-only users
-- This assumes the column 'password_hash' exists.
-- If it might not, the original DO $$ block with IF EXISTS for the column is safer.
-- However, given it's a core user attribute, it should exist.
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- Add a unique constraint for oidc_sub and oidc_issuer.
-- This will fail if the constraint already exists, which is acceptable as the migration runner
-- should catch the error and skip/log if the migration was already partially applied.
-- A more robust way is to check information_schema, but we're simplifying due to `RAISE` issues.
ALTER TABLE users ADD CONSTRAINT uq_users_oidc_sub_issuer UNIQUE (oidc_sub, oidc_issuer);

-- Add login_method to user_sessions table
ALTER TABLE user_sessions
ADD COLUMN IF NOT EXISTS login_method VARCHAR(50) DEFAULT 'local';

-- Update existing sessions to 'local' if login_method is NULL
UPDATE user_sessions
SET login_method = 'local'
WHERE login_method IS NULL;

-- Make login_method not nullable after updating existing rows
-- This assumes the column 'login_method' now exists.
ALTER TABLE user_sessions ALTER COLUMN login_method SET NOT NULL;

-- End of migration
