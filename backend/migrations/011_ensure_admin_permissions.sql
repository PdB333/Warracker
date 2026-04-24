-- Migration: Ensure Admin Permissions
-- This migration ensures basic permissions are granted (advanced features are optional)

DO $$
BEGIN
    -- Grant elevated privileges to db_user (removed SUPERUSER)
    -- ALTER ROLE %(db_user)s WITH SUPERUSER;

    -- Ensure all tables are accessible
    BEGIN
        GRANT ALL PRIVILEGES ON DATABASE %(db_name)s TO %(db_user)s;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO %(db_user)s;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO %(db_user)s;
        GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO %(db_user)s;
        RAISE NOTICE 'Successfully granted basic privileges to %(db_user)s';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Insufficient privileges to grant some permissions to %(db_user)s - this may limit some features';
    WHEN OTHERS THEN
        RAISE NOTICE 'Could not grant all privileges to %(db_user)s - this may limit some features';
    END;

    -- Ensure role can create and manage roles (optional)
    -- ALTER ROLE %(db_user)s WITH CREATEROLE;

    -- Try to make db_user the owner of all database objects (optional)
    BEGIN
        -- Make db_user the owner of all tables
        EXECUTE (
            SELECT 'ALTER TABLE ' || quote_ident(tablename) || ' OWNER TO %(db_user)s;'
            FROM pg_tables
            WHERE schemaname = 'public'
        );
        
        -- Make db_user the owner of all sequences
        EXECUTE (
            SELECT 'ALTER SEQUENCE ' || quote_ident(sequencename) || ' OWNER TO %(db_user)s;'
            FROM pg_sequences
            WHERE schemaname = 'public'
        );
        
        -- Make db_user the owner of all functions
        EXECUTE (
            SELECT 'ALTER FUNCTION ' || quote_ident(proname) || '(' || 
                   pg_get_function_arguments(p.oid) || ') OWNER TO %(db_user)s;'
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public'
        );
        RAISE NOTICE 'Successfully set ownership of database objects to %(db_user)s';
    EXCEPTION WHEN OTHERS THEN
        -- Log error but continue
        RAISE NOTICE 'Error setting ownership (this is optional): %%', SQLERRM;
    END;
END $$; 
