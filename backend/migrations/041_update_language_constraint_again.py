import os
import sys
import psycopg2

# Add project root to the Python path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0, project_root)

try:
    from backend.localization import SUPPORTED_LANGUAGES
    from backend.db_handler import get_db_connection, release_db_connection
except ImportError as e:
    print(f"Error importing project modules: {e}")
    # Provide a fallback for environments where the script is run directly
    # This is a simplified example; a more robust solution might use a config file
    SUPPORTED_LANGUAGES = ['en', 'fr', 'es', 'de', 'it', 'cs', 'nl', 'hi', 'fa', 'ar', 'ru', 'uk', 'zh_CN', 'zh_HK', 'ja', 'pt', 'ko']
    # Define a dummy db_handler if not available
    class DummyDBHandler:
        def get_db_connection(self):
            # This would need to be configured to connect to your database
            # For example, using environment variables
            return psycopg2.connect(
                dbname=os.getenv("DB_NAME"),
                user=os.getenv("DB_USER"),
                password=os.getenv("DB_PASSWORD"),
                host=os.getenv("DB_HOST")
            )
        def release_db_connection(self, conn):
            if conn:
                conn.close()
    db_handler = DummyDBHandler()

def apply_migration(conn):
    """
    Applies the database migration to update the language constraint.
    """
    cursor = conn.cursor()
    try:
        print("Applying migration: 040_update_language_constraint.py")

        # Drop the existing constraint if it exists
        print("Dropping existing constraint 'chk_users_preferred_language' if it exists...")
        cursor.execute("""
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.table_constraints 
                    WHERE constraint_name = 'chk_users_preferred_language' 
                    AND table_name = 'users'
                ) THEN
                    ALTER TABLE users DROP CONSTRAINT chk_users_preferred_language;
                    RAISE NOTICE 'Dropped existing preferred_language constraint';
                ELSE
                    RAISE NOTICE 'preferred_language constraint does not exist, skipping drop';
                END IF;
            END $$;
        """)

        # Create the new constraint dynamically
        print("Creating new constraint with all supported languages...")
        # Format the language list for the SQL IN clause
        language_list_sql = ", ".join([f"'{lang}'" for lang in SUPPORTED_LANGUAGES])
        
        constraint_sql = f"""
            ALTER TABLE users 
            ADD CONSTRAINT chk_users_preferred_language 
            CHECK (preferred_language IN ({language_list_sql}));
        """
        cursor.execute(constraint_sql)
        print("New constraint 'chk_users_preferred_language' created successfully.")

        # Update the comment on the column
        print("Updating column comment...")
        comment_sql = f"""
            COMMENT ON COLUMN users.preferred_language IS 'User preferred language for UI localization (ISO 639-1 code): {', '.join(SUPPORTED_LANGUAGES)}';
        """
        cursor.execute(comment_sql)
        print("Column comment updated successfully.")

        conn.commit()
        print("Migration 040_update_language_constraint.py applied successfully.")
    except Exception as e:
        conn.rollback()
        print(f"Error applying migration 040_update_language_constraint.py: {e}")
        raise
    finally:
        cursor.close()

if __name__ == "__main__":
    # This allows the script to be run directly
    connection = None
    try:
        # In a real application, you would get the connection details from a config file or environment variables
        connection = db_handler.get_db_connection()
        apply_migration(connection)
    except Exception as e:
        print(f"Migration failed: {e}")
    finally:
        if connection:
            db_handler.release_db_connection(connection)
