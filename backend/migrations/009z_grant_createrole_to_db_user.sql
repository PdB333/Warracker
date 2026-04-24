-- Migration: Grant CREATEROLE to db_user before admin role configuration
-- This is optional and will be skipped if the user doesn't have permission

DO $$
BEGIN
    -- Try to grant CREATEROLE, but continue if it fails
    BEGIN
        ALTER ROLE %(db_user)s WITH CREATEROLE;
        RAISE NOTICE 'Successfully granted CREATEROLE to %(db_user)s';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Insufficient privileges to grant CREATEROLE to %(db_user)s - this is optional and the application will work without it';
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not grant CREATEROLE to %(db_user)s - this is optional and the application will work without it';
    END;
END
$$; 