-- =============================================
-- SePay Payment Configuration
-- Thêm cấu hình SePay vào bảng system_config
-- =============================================

-- Số tài khoản ngân hàng nhận thanh toán
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_BANK_ACCOUNT', '', N'Số tài khoản ngân hàng nhận thanh toán SePay');

-- Tên ngân hàng (theo danh sách SePay: Vietcombank, Techcombank, VPBank, MBBank, ACB, ...)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_BANK_NAME', 'MBBank', N'Tên ngân hàng (theo chuẩn SePay)');

-- Tên chủ tài khoản (hiển thị trên giao diện)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_ACCOUNT_NAME', '', N'Tên chủ tài khoản ngân hàng');

-- Prefix nội dung chuyển khoản (content prefix)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_CONTENT_PREFIX', 'HV', N'Tiền tố nội dung chuyển khoản (VD: HV001 = HV + orderId)');

-- API Key cho webhook (để xác thực webhook từ SePay)
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_API_KEY', '', N'API Key xác thực webhook từ SePay');

-- Bật/tắt thanh toán QR
INSERT INTO system_config (config_key, config_value, description)
VALUES ('SEPAY_ENABLED', 'true', N'Bật/tắt thanh toán QR qua SePay');
