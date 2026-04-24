"""
Migration 004: Add user_preferences table
"""

def upgrade(cursor):
    """
    Add user_preferences table to store user settings
    """
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_preferences (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
            default_view VARCHAR(10) NOT NULL DEFAULT 'grid',
            theme VARCHAR(10) NOT NULL DEFAULT 'light',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(user_id)
        )
    """)
    
    # Add index for faster lookups
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id)
    """)
    
    print("Created user_preferences table")

def downgrade(cursor):
    """
    Remove user_preferences table
    """
    cursor.execute("""
        DROP TABLE IF EXISTS user_preferences CASCADE
    """)
    
    print("Dropped user_preferences table") 