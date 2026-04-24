-- Add tags table and warranty_tags junction table
DO $$
BEGIN
    -- Create tags table if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'tags'
    ) THEN
        CREATE TABLE tags (
            id SERIAL PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            color VARCHAR(7) NOT NULL DEFAULT '#808080',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(name)
        );

        -- Create index on tag name
        CREATE INDEX idx_tag_name ON tags(name);
    END IF;

    -- Create warranty_tags junction table if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'warranty_tags'
    ) THEN
        CREATE TABLE warranty_tags (
            warranty_id INTEGER NOT NULL,
            tag_id INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (warranty_id, tag_id),
            FOREIGN KEY (warranty_id) REFERENCES warranties(id) ON DELETE CASCADE,
            FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        );

        -- Create indexes for better query performance
        CREATE INDEX idx_warranty_tags_warranty_id ON warranty_tags(warranty_id);
        CREATE INDEX idx_warranty_tags_tag_id ON warranty_tags(tag_id);
    END IF;
END $$; 