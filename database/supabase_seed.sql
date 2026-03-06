/* =========================================================
   Restaurant_Ipos - PostgreSQL (Supabase)
   TẠO BẢNG + DỮ LIỆU MẪU
   ========================================================= */

-- 1) roles
CREATE TABLE IF NOT EXISTS roles (
    role_id      SERIAL PRIMARY KEY,
    role_name    VARCHAR(50)  NOT NULL UNIQUE,
    description  VARCHAR(255)
);

-- 2) users
CREATE TABLE IF NOT EXISTS users (
    user_id              SERIAL PRIMARY KEY,
    role_id              INT NOT NULL REFERENCES roles(role_id),
    username             VARCHAR(50) NOT NULL UNIQUE,
    password_hash        VARCHAR(255) NOT NULL,
    full_name            VARCHAR(100),
    phone                VARCHAR(20),
    email                VARCHAR(120),
    status               VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    failed_login_count   INT NOT NULL DEFAULT 0,
    last_failed_login_at TIMESTAMP,
    locked_until         TIMESTAMP
);

-- 3) areas
CREATE TABLE IF NOT EXISTS areas (
    area_id      SERIAL PRIMARY KEY,
    area_name    VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255)
);

-- 4) tables
CREATE TABLE IF NOT EXISTS tables (
    table_id     SERIAL PRIMARY KEY,
    area_id      INT NOT NULL REFERENCES areas(area_id),
    table_name   VARCHAR(50) NOT NULL UNIQUE,
    capacity     INT NOT NULL CHECK (capacity > 0),
    status       VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'
);

-- 5) categories
CREATE TABLE IF NOT EXISTS categories (
    category_id    SERIAL PRIMARY KEY,
    category_name  VARCHAR(100) NOT NULL UNIQUE,
    status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

-- 6) products
CREATE TABLE IF NOT EXISTS products (
    product_id    SERIAL PRIMARY KEY,
    category_id   INT NOT NULL REFERENCES categories(category_id),
    product_name  VARCHAR(150) NOT NULL UNIQUE,
    price         DECIMAL(18,2) NOT NULL CHECK (price >= 0),
    cost_price    DECIMAL(18,2) NOT NULL CHECK (cost_price >= 0),
    quantity      INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    status        VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    description   VARCHAR(500),
    image_path    VARCHAR(500)
);

-- 7) orders
CREATE TABLE IF NOT EXISTS orders (
    order_id         SERIAL PRIMARY KEY,
    table_id         INT NOT NULL REFERENCES tables(table_id),
    created_by       INT NOT NULL REFERENCES users(user_id),
    order_type       VARCHAR(20) NOT NULL DEFAULT 'DINE_IN',
    opened_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at        TIMESTAMP,
    status           VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    subtotal         DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    total_amount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    note             VARCHAR(500)
);

-- 8) order_details
CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id  SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id       INT NOT NULL REFERENCES products(product_id),
    quantity         INT NOT NULL CHECK (quantity > 0),
    unit_price       DECIMAL(18,2) NOT NULL CHECK (unit_price >= 0),
    line_total       DECIMAL(18,2),
    item_status      VARCHAR(20) NOT NULL DEFAULT 'ORDERED'
);

-- 9) payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id       SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES orders(order_id) UNIQUE,
    cashier_id       INT NOT NULL REFERENCES users(user_id),
    paid_at          TIMESTAMP,
    method           VARCHAR(20) NOT NULL,
    amount_paid      DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    final_amount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_status   VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    transaction_ref  VARCHAR(100)
);

-- 10) bookings
CREATE TABLE IF NOT EXISTS bookings (
    booking_id      SERIAL PRIMARY KEY,
    booking_code    VARCHAR(20) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) NOT NULL,
    customer_phone  VARCHAR(20) NOT NULL,
    booking_date    DATE NOT NULL,
    booking_time    TIME NOT NULL,
    party_size      INT NOT NULL DEFAULT 2 CHECK (party_size > 0),
    note            VARCHAR(500),
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    cancel_reason   VARCHAR(500),
    table_id        INT REFERENCES tables(table_id),
    user_id         INT REFERENCES users(user_id),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP
);

-- 11) pre_order_items
CREATE TABLE IF NOT EXISTS pre_order_items (
    pre_order_item_id SERIAL PRIMARY KEY,
    booking_id        INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    product_id        INT NOT NULL REFERENCES products(product_id),
    quantity          INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    note              VARCHAR(255),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 12) system_config
CREATE TABLE IF NOT EXISTS system_config (
    config_key   VARCHAR(50) PRIMARY KEY,
    config_value VARCHAR(255) NOT NULL,
    description  VARCHAR(255)
);

-- 13) permissions
CREATE TABLE IF NOT EXISTS permissions (
    perm_id    SERIAL PRIMARY KEY,
    role_id    INT NOT NULL REFERENCES roles(role_id),
    permission VARCHAR(100) NOT NULL,
    UNIQUE (role_id, permission)
);

-- 14) audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id      SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(user_id),
    action      VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id   INT,
    reason      VARCHAR(500),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 15) user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id  VARCHAR(128) PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMP NOT NULL,
    ip          VARCHAR(45),
    user_agent  VARCHAR(255)
);

/* =========================================================
   SEED DATA
   ========================================================= */

-- Roles
INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'Quản trị viên'),
('STAFF', 'Nhân viên phục vụ'),
('CASHIER', 'Thu ngân'),
('CUSTOMER', 'Khách hàng')
ON CONFLICT (role_name) DO NOTHING;

-- Users
INSERT INTO users (role_id, username, password_hash, full_name, phone, email, status, created_at, failed_login_count)
VALUES
((SELECT role_id FROM roles WHERE role_name='ADMIN'), 'admin', 'admin123', 'Administrator', '0900000001', 'admin@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='STAFF'), 'staff1', 'staff123', 'Staff Demo', '0900000002', 'staff1@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='CASHIER'), 'cashier1', 'cashier123', 'Cashier Demo', '0900000003', 'cashier1@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='CUSTOMER'), 'customer1', 'customer123', 'Customer Demo', '0900000004', 'customer1@demo.local', 'ACTIVE', NOW(), 0)
ON CONFLICT (username) DO NOTHING;

-- System Config
INSERT INTO system_config (config_key, config_value, description) VALUES
('vat_rate', '10', 'VAT %'),
('service_fee_rate', '5', 'Phí dịch vụ %'),
('opening_hours', '10:00', 'Giờ mở cửa'),
('closing_hours', '22:00', 'Giờ đóng cửa'),
('hold_minutes', '15', 'Phút giữ bàn'),
('cutoff_minutes', '60', 'Hạn sửa pre-order (phút)'),
('SEPAY_BANK_ACCOUNT', '', 'Số tài khoản ngân hàng nhận thanh toán SePay'),
('SEPAY_BANK_NAME', 'MBBank', 'Tên ngân hàng (theo chuẩn SePay)'),
('SEPAY_ACCOUNT_NAME', '', 'Tên chủ tài khoản ngân hàng'),
('SEPAY_CONTENT_PREFIX', 'HV', 'Tiền tố nội dung chuyển khoản'),
('SEPAY_API_KEY', '', 'API Key xác thực webhook từ SePay'),
('SEPAY_ENABLED', 'true', 'Bật/tắt thanh toán QR qua SePay')
ON CONFLICT (config_key) DO NOTHING;

-- Areas
INSERT INTO areas (area_name, description) VALUES
('Tầng 1', 'Khu tầng 1'),
('Tầng 2', 'Khu tầng 2'),
('VIP', 'Phòng VIP'),
('Sân vườn', 'Ngoài trời')
ON CONFLICT (area_name) DO NOTHING;

-- Tables
INSERT INTO tables (area_id, table_name, capacity, status) VALUES
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T01', 4, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T02', 4, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T03', 6, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='Tầng 2'), 'T04', 4, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='Tầng 2'), 'T05', 8, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='VIP'), 'V01', 10, 'AVAILABLE'),
((SELECT area_id FROM areas WHERE area_name='VIP'), 'V02', 12, 'AVAILABLE')
ON CONFLICT (table_name) DO NOTHING;

-- Categories
INSERT INTO categories (category_name, status) VALUES
('Món khai vị', 'ACTIVE'),
('Món chính', 'ACTIVE'),
('Đồ uống', 'ACTIVE'),
('Tráng miệng', 'ACTIVE')
ON CONFLICT (category_name) DO NOTHING;

-- Products
INSERT INTO products (category_id, product_name, price, cost_price, quantity, status, description) VALUES
((SELECT category_id FROM categories WHERE category_name='Món khai vị'), 'Gỏi cuốn tôm thịt', 30000, 15000, 80, 'AVAILABLE', 'Gỏi cuốn truyền thống'),
((SELECT category_id FROM categories WHERE category_name='Món khai vị'), 'Chả giò', 35000, 17000, 70, 'AVAILABLE', 'Chả giò chiên giòn'),
((SELECT category_id FROM categories WHERE category_name='Món khai vị'), 'Salad dầu giấm', 40000, 20000, 40, 'AVAILABLE', 'Salad rau tươi'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Phở bò', 60000, 30000, 60, 'AVAILABLE', 'Phở bò truyền thống'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Phở gà', 55000, 27000, 50, 'AVAILABLE', 'Phở gà ta'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Bún bò Huế', 65000, 32000, 45, 'AVAILABLE', 'Bún bò cay'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Cơm tấm sườn', 55000, 25000, 55, 'AVAILABLE', 'Cơm tấm sườn nướng'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Mì xào bò', 65000, 30000, 35, 'AVAILABLE', 'Mì xào bò rau'),
((SELECT category_id FROM categories WHERE category_name='Món chính'), 'Lẩu Thái', 180000, 90000, 20, 'AVAILABLE', 'Lẩu chua cay'),
((SELECT category_id FROM categories WHERE category_name='Đồ uống'), 'Trà đá', 5000, 1000, 300, 'AVAILABLE', 'Trà đá'),
((SELECT category_id FROM categories WHERE category_name='Đồ uống'), 'Nước suối', 10000, 4000, 200, 'AVAILABLE', 'Nước suối'),
((SELECT category_id FROM categories WHERE category_name='Đồ uống'), 'Coca Cola', 15000, 7000, 120, 'AVAILABLE', 'Nước ngọt'),
((SELECT category_id FROM categories WHERE category_name='Đồ uống'), 'Cam vắt', 30000, 12000, 80, 'AVAILABLE', 'Nước cam'),
((SELECT category_id FROM categories WHERE category_name='Tráng miệng'), 'Bánh flan', 20000, 9000, 60, 'AVAILABLE', 'Flan'),
((SELECT category_id FROM categories WHERE category_name='Tráng miệng'), 'Kem dừa', 30000, 12000, 50, 'AVAILABLE', 'Kem dừa'),
((SELECT category_id FROM categories WHERE category_name='Tráng miệng'), 'Chè đậu xanh', 20000, 8000, 70, 'AVAILABLE', 'Chè đậu xanh')
ON CONFLICT (product_name) DO NOTHING;

-- Permissions (RBAC)
INSERT INTO permissions (role_id, permission)
SELECT r.role_id, p.perm
FROM roles r, (VALUES
    ('dashboard.view'), ('tables.view'), ('tables.update_status'),
    ('order.view'), ('order.create'), ('order.update'),
    ('categories.view'), ('menu.view'), ('booking.view'), ('booking.manage')
) AS p(perm)
WHERE r.role_name = 'STAFF'
ON CONFLICT (role_id, permission) DO NOTHING;

INSERT INTO permissions (role_id, permission)
SELECT r.role_id, p.perm
FROM roles r, (VALUES
    ('dashboard.view'), ('order.view'),
    ('payment.view'), ('payment.create')
) AS p(perm)
WHERE r.role_name = 'CASHIER'
ON CONFLICT (role_id, permission) DO NOTHING;
