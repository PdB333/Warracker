# Migration: Add currency_symbol column to user_preferences
import psycopg2

def upgrade(cur):
    # Check if column already exists
    cur.execute("""
        SELECT column_name FROM information_schema.columns 
        WHERE table_name='user_preferences' AND column_name='currency_symbol'
    """)
    if not cur.fetchone():
        cur.execute("""
            ALTER TABLE user_preferences ADD COLUMN currency_symbol VARCHAR(8) DEFAULT '$';
        """)
        print("Added currency_symbol column to user_preferences table")

def downgrade(cur):
    cur.execute("""
        ALTER TABLE user_preferences DROP COLUMN IF EXISTS currency_symbol;
    """)
    print("Removed currency_symbol column from user_preferences table") 