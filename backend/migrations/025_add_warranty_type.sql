-- Migration: Create site_settings table
-- Description: Creates the site_settings table for storing application configuration

-- Create site_settings table
CREATE TABLE IF NOT EXISTS site_settings (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default values
INSERT INTO site_settings (key, value) VALUES
('registration_enabled', 'true'),
('email_base_url', 'http://localhost:8080'),
('global_view_enabled', 'true'),
('global_view_admin_only', 'false'),
('oidc_enabled', 'false'),
('oidc_only_mode', 'false'),
('oidc_provider_name', 'oidc'),
('oidc_client_id', ''),
('oidc_issuer_url', ''),
('oidc_scope', 'openid email profile')
ON CONFLICT (key) DO NOTHING;