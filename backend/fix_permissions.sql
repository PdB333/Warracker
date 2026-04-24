-- Script to fix PostgreSQL permissions for db_user

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

-- Ensure all database objects are accessible
GRANT ALL PRIVILEGES ON DATABASE %(db_name)s TO %(db_user)s;
GRANT ALL PRIVILEGES ON SCHEMA public TO %(db_user)s;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO %(db_user)s;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO %(db_user)s;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO %(db_user)s;

-- Make db_user the owner of all tables
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(rec.tablename) || ' OWNER TO %(db_user)s';
    END LOOP;
END $$;

-- Make db_user the owner of all sequences
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT sequencename FROM pg_sequences WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER SEQUENCE public.' || quote_ident(rec.sequencename) || ' OWNER TO %(db_user)s';
    END LOOP;
END $$;

-- Make db_user the owner of all functions
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT proname, p.oid FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public'
    LOOP
        BEGIN
            EXECUTE 'ALTER FUNCTION public.' || quote_ident(rec.proname) || '(' || pg_get_function_arguments(rec.oid) || ') OWNER TO %(db_user)s';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error changing ownership of function %%: %%', rec.proname, SQLERRM;
        END;
    END LOOP;
END $$;
