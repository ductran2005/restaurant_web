-- =========================================================
-- Chatbot AI Configuration — Groq API
-- Chạy script này trên Supabase SQL Editor
-- =========================================================

-- Groq API Key (dùng cho chatbot AI)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('GROQ_API_KEY', '', 'API Key của Groq cho chatbot AI')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;

-- Groq Model (mặc định: llama-3.3-70b-versatile)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('GROQ_MODEL', 'llama-3.3-70b-versatile', 'Model AI sử dụng cho chatbot (Groq)')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;

-- Bật/tắt chatbot AI
INSERT INTO system_config (config_key, config_value, description)
VALUES ('CHATBOT_ENABLED', 'true', 'Bật/tắt chatbot AI trên trang khách hàng')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;
