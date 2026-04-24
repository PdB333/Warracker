-- Fix tags table constraints to allow per-user tag names
DO $$
BEGIN
    -- Check if user_id column exists, if not add it
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tags' AND column_name = 'user_id'
    ) THEN
        -- Add user_id column as nullable first
        ALTER TABLE tags ADD COLUMN user_id INTEGER;
        
        -- Update existing tags to have user_id = 1 (assuming admin user)
        UPDATE tags SET user_id = 1 WHERE user_id IS NULL;
        
        -- Make the column NOT NULL
        ALTER TABLE tags ALTER COLUMN user_id SET NOT NULL;
        
        -- Add foreign key constraint
        ALTER TABLE tags ADD CONSTRAINT fk_tags_user_id 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;
    
    -- Drop the old unique constraint on name only (if it exists)
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'tags' AND constraint_name = 'tags_name_key'
    ) THEN
        ALTER TABLE tags DROP CONSTRAINT tags_name_key;
        RAISE NOTICE 'Dropped old tags_name_key constraint';
    END IF;
    
    -- Add new unique constraint on name and user_id (if it doesn't exist)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'tags' AND constraint_name = 'tags_name_user_id_key'
    ) THEN
        ALTER TABLE tags ADD CONSTRAINT tags_name_user_id_key 
            UNIQUE (name, user_id);
        RAISE NOTICE 'Added new tags_name_user_id_key constraint';
    END IF;
    
    -- Create index for faster lookups (if it doesn't exist)
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'tags' AND indexname = 'idx_tags_user_id'
    ) THEN
        CREATE INDEX idx_tags_user_id ON tags (user_id);
        RAISE NOTICE 'Created idx_tags_user_id index';
    END IF;
    
    RAISE NOTICE 'Tags table constraint fix completed successfully';
END $$; 