-- Migration 031: Add the is_owner flag to the users table

-- Add the is_owner column, defaulting to FALSE for all users.
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_owner BOOLEAN NOT NULL DEFAULT FALSE;

-- Find the very first user created and promote them to be the initial application Owner
-- This is a safe, one-time operation with robust fallbacks
DO $$
DECLARE
    first_user_id INT;
    owner_count INT;
BEGIN
    -- Check if any owner is currently set
    SELECT COUNT(*) INTO owner_count FROM users WHERE is_owner = TRUE;
    
    IF owner_count = 0 THEN
        -- Try multiple strategies to find the first user
        
        -- Strategy 1: Use created_at if available
        SELECT id INTO first_user_id FROM users 
        WHERE created_at IS NOT NULL 
        ORDER BY created_at ASC, id ASC 
        LIMIT 1;
        
        -- Strategy 2: Fallback to lowest ID if created_at approach fails
        IF first_user_id IS NULL THEN
            SELECT id INTO first_user_id FROM users ORDER BY id ASC LIMIT 1;
        END IF;
        
        -- Strategy 3: If still no user found, check for any admin user
        IF first_user_id IS NULL THEN
            SELECT id INTO first_user_id FROM users WHERE is_admin = TRUE ORDER BY id ASC LIMIT 1;
        END IF;
        
        -- If we found a user, make them the owner
        IF first_user_id IS NOT NULL THEN
            UPDATE users SET is_owner = TRUE WHERE id = first_user_id;
            RAISE NOTICE 'Migration 031: User ID % has been set as the initial application owner.', first_user_id;
        ELSE
            RAISE NOTICE 'Migration 031: No users found, no owner set. The first user to register will become the owner.';
        END IF;
    ELSE
        RAISE NOTICE 'Migration 031: An owner is already set (% owner(s) found). No changes made.', owner_count;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Migration 031: Error during owner promotion: %. Will be handled by application startup.', SQLERRM;
END $$; 