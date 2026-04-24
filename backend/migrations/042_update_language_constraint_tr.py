import logging

try:
    # Prefer importing the live list so this migration reflects current support
    from backend.localization import SUPPORTED_LANGUAGES
except Exception:
    # Fallback (should not be used if project imports work)
    SUPPORTED_LANGUAGES = ['en', 'fr', 'es', 'de', 'it', 'cs', 'nl', 'hi', 'fa', 'ar', 'ru', 'uk', 'zh_CN', 'zh_HK', 'ja', 'pt', 'ko', 'tr']

logger = logging.getLogger(__name__)

def apply_migration(conn):
    """Drop and recreate preferred_language CHECK constraint to include new languages (adds 'tr')."""
    cur = conn.cursor()
    try:
        logger.info("Dropping existing 'chk_users_preferred_language' constraint if it exists…")
        cur.execute(
            """
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.table_constraints 
                    WHERE constraint_name = 'chk_users_preferred_language' 
                      AND table_name = 'users'
                ) THEN
                    ALTER TABLE users DROP CONSTRAINT chk_users_preferred_language;
                END IF;
            END $$;
            """
        )

        # Build the IN list from supported languages
        language_list_sql = ", ".join([f"'{lang}'" for lang in SUPPORTED_LANGUAGES])

        logger.info("Creating updated 'chk_users_preferred_language' constraint…")
        cur.execute(
            f"""
            ALTER TABLE users 
            ADD CONSTRAINT chk_users_preferred_language 
            CHECK (preferred_language IN ({language_list_sql}));
            """
        )

        cur.execute(
            f"""
            COMMENT ON COLUMN users.preferred_language IS 'User preferred language for UI localization (ISO 639-1 code): {', '.join(SUPPORTED_LANGUAGES)}';
            """
        )

        conn.commit()
        logger.info("Language constraint updated successfully.")
    except Exception as e:
        conn.rollback()
        logger.error(f"Error updating language constraint: {e}")
        raise
    finally:
        cur.close()


