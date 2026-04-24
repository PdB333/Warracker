-- Add user_id column to tags table and update constraints
DO $$
BEGIN
    -- Add user_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tags' AND column_name = 'user_id'
    ) THEN
        -- First, add the column as nullable
        ALTER TABLE tags ADD COLUMN user_id INTEGER;
        
        -- Update existing tags to have user_id = 1 (assuming this is the admin user)
        UPDATE tags SET user_id = 1 WHERE user_id IS NULL;
        
        -- Make the column NOT NULL
        ALTER TABLE tags ALTER COLUMN user_id SET NOT NULL;
        
        -- Add foreign key constraint
        ALTER TABLE tags ADD CONSTRAINT fk_tags_user_id 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
            
        -- Drop the old unique constraint on name
        ALTER TABLE tags DROP CONSTRAINT IF EXISTS tags_name_key;
        
        -- Add new unique constraint on name and user_id
        ALTER TABLE tags ADD CONSTRAINT tags_name_user_id_key 
            UNIQUE (name, user_id);
            
        -- Create index for faster lookups
        CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags (user_id);
    END IF;
END $$; 