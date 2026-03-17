-- =========================================================
-- Google OAuth Config - Insert vào system_config
-- Chạy trên Supabase SQL Editor
-- =========================================================

-- 1) Thêm Google OAuth credentials
INSERT INTO system_config (config_key, config_value, description) VALUES
('GOOGLE_CLIENT_ID', '120394683638-3i5duilf0c5dcch0l82c08to6ge9nd2f.apps.googleusercontent.com', 'Google OAuth Client ID'),
('GOOGLE_CLIENT_SECRET', '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', 'Google OAuth Client Secret'),
('GOOGLE_REDIRECT_URI', 'http://localhost:8080/oauth2/google/callback', 'Google OAuth Redirect URI')
ON CONFLICT (config_key) DO NOTHING;

-- 2) Kiểm tra đã insert thành công
SELECT config_key, config_value, description
FROM system_config
WHERE config_key LIKE 'GOOGLE_%'
ORDER BY config_key;
