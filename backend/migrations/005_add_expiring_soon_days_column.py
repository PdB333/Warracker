"""
Migration 007: Add expiring_soon_days to user_preferences
"""

def upgrade(cursor):
    """
    Create user_preferences table if it doesn't exist and
    add expiring_soon_days column to user_preferences table to allow customization of 
    how many days before expiration a warranty should be considered "expiring soon"
    """
    # Check if user_preferences table exists
    cursor.execute("""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'user_preferences'
        )
    """)
    
    table_exists = cursor.fetchone()[0]
    
    if not table_exists:
        # Create the user_preferences table
        cursor.execute("""
            CREATE TABLE user_preferences (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
                default_view VARCHAR(10) NOT NULL DEFAULT 'grid',
                theme VARCHAR(10) NOT NULL DEFAULT 'light',
                expiring_soon_days INTEGER NOT NULL DEFAULT 30,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                UNIQUE(user_id)
            )
        """)
        
        # Add index for faster lookups
        cursor.execute("""
            CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id)
        """)
        
        print("Created user_preferences table with expiring_soon_days column")
    else:
        # Add expiring_soon_days column if it doesn't exist
        cursor.execute("""
            ALTER TABLE user_preferences
            ADD COLUMN IF NOT EXISTS expiring_soon_days INTEGER NOT NULL DEFAULT 30
        """)
        
        print("Added expiring_soon_days column to existing user_preferences table")

def downgrade(cursor):
    """
    Remove expiring_soon_days column from user_preferences
    """
    # Check if user_preferences table exists
    cursor.execute("""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = 'user_preferences'
        )
    """)
    
    table_exists = cursor.fetchone()[0]
    
    if table_exists:
        # Check if column exists
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.columns 
                WHERE table_name = 'user_preferences' AND column_name = 'expiring_soon_days'
            )
        """)
        
        column_exists = cursor.fetchone()[0]
        
        if column_exists:
            cursor.execute("""
                ALTER TABLE user_preferences
                DROP COLUMN IF EXISTS expiring_soon_days
            """)
            
            print("Removed expiring_soon_days column from user_preferences table")
    else:
        print("user_preferences table does not exist, nothing to downgrade") 