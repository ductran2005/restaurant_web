/* =========================================================
   Restaurant_Ipos - PostgreSQL (Supabase)
   FULL SCHEMA + SEED DATA
   Converted from SQL Server schema
   ========================================================= */

-- Drop existing tables if needed (careful in production!)
-- DROP TABLE IF EXISTS user_sessions CASCADE;
-- DROP TABLE IF EXISTS audit_logs CASCADE;
-- DROP TABLE IF EXISTS permissions CASCADE;
-- DROP TABLE IF EXISTS system_config CASCADE;
-- DROP TABLE IF EXISTS pre_order_items CASCADE;
-- DROP TABLE IF EXISTS bookings CASCADE;
-- DROP TABLE IF EXISTS payments CASCADE;
-- DROP TABLE IF EXISTS order_details CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS inventory_log CASCADE;
-- DROP TABLE IF EXISTS inventory CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS categories CASCADE;
-- DROP TABLE IF EXISTS tables CASCADE;
-- DROP TABLE IF EXISTS areas CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;
-- DROP TABLE IF EXISTS roles CASCADE;

------------------------------------------------------------
-- 1) SCHEMA
------------------------------------------------------------

-- roles
CREATE TABLE IF NOT EXISTS roles (
    role_id      SERIAL PRIMARY KEY,
    role_name    VARCHAR(50)  NOT NULL UNIQUE,
    description  VARCHAR(255)
);

-- users
CREATE TABLE IF NOT EXISTS users (
    user_id              SERIAL PRIMARY KEY,
    role_id              INT NOT NULL REFERENCES roles(role_id),
    username             VARCHAR(50) NOT NULL UNIQUE,
    password_hash        VARCHAR(255) NOT NULL,
    full_name            VARCHAR(100),
    phone                VARCHAR(20),
    email                VARCHAR(120),
    status               VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE')),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    failed_login_count   INT NOT NULL DEFAULT 0,
    last_failed_login_at TIMESTAMP,
    locked_until         TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email_notnull ON users(email) WHERE email IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_users_role_id ON users(role_id);

-- areas
CREATE TABLE IF NOT EXISTS areas (
    area_id      SERIAL PRIMARY KEY,
    area_name    VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255)
);

-- tables
CREATE TABLE IF NOT EXISTS tables (
    table_id     SERIAL PRIMARY KEY,
    area_id      INT NOT NULL REFERENCES areas(area_id),
    table_name   VARCHAR(50) NOT NULL UNIQUE,
    capacity     INT NOT NULL CHECK (capacity > 0),
    status       VARCHAR(20) NOT NULL DEFAULT 'EMPTY' 
                 CHECK (status IN ('EMPTY','RESERVED','OCCUPIED','WAITING_PAYMENT','DIRTY','DISABLED','AVAILABLE','IN_USE')),
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_tables_area_status ON tables(area_id, status);

-- categories
CREATE TABLE IF NOT EXISTS categories (
    category_id    SERIAL PRIMARY KEY,
    category_name  VARCHAR(100) NOT NULL UNIQUE,
    status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE'))
);

-- products
CREATE TABLE IF NOT EXISTS products (
    product_id    SERIAL PRIMARY KEY,
    category_id   INT NOT NULL REFERENCES categories(category_id),
    product_name  VARCHAR(150) NOT NULL UNIQUE,
    price         DECIMAL(18,2) NOT NULL CHECK (price >= 0),
    cost_price    DECIMAL(18,2) NOT NULL CHECK (cost_price >= 0),
    quantity      INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    status        VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE','UNAVAILABLE')),
    description   VARCHAR(500),
    image_path    VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS ix_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS ix_products_status ON products(status);

-- inventory
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id    SERIAL PRIMARY KEY,
    product_id      INT NOT NULL REFERENCES products(product_id) UNIQUE,
    current_qty     INT NOT NULL DEFAULT 0 CHECK (current_qty >= 0),
    reorder_level   INT NOT NULL DEFAULT 0 CHECK (reorder_level >= 0),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- inventory_log
CREATE TABLE IF NOT EXISTS inventory_log (
    log_id          SERIAL PRIMARY KEY,
    inventory_id    INT NOT NULL REFERENCES inventory(inventory_id),
    changed_by      INT NOT NULL REFERENCES users(user_id),
    type            VARCHAR(20) NOT NULL CHECK (type IN ('IN','OUT','ADJUST')),
    qty_change      INT NOT NULL,
    reason          VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- orders
CREATE TABLE IF NOT EXISTS orders (
    order_id         SERIAL PRIMARY KEY,
    table_id         INT NOT NULL REFERENCES tables(table_id),
    created_by       INT NOT NULL REFERENCES users(user_id),
    order_type       VARCHAR(20) NOT NULL DEFAULT 'DINE_IN' CHECK (order_type IN ('DINE_IN','TAKE_AWAY','DELIVERY')),
    opened_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at        TIMESTAMP,
    status           VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','SERVED','CANCELLED','PAID')),
    subtotal         DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    total_amount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    note             VARCHAR(500),
    CONSTRAINT ck_orders_amounts CHECK (
        subtotal >= 0 AND discount_amount >= 0 AND total_amount >= 0
        AND discount_amount <= subtotal
    )
);

CREATE INDEX IF NOT EXISTS ix_orders_table_status_opened ON orders(table_id, status, opened_at);
CREATE INDEX IF NOT EXISTS ix_orders_created_by_opened ON orders(created_by, opened_at);
CREATE INDEX IF NOT EXISTS ix_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS ix_orders_opened_at ON orders(opened_at);

-- Unique index: only one OPEN order per table
CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_one_open_per_table ON orders(table_id) WHERE status = 'OPEN';

-- order_details
CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id  SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id       INT NOT NULL REFERENCES products(product_id),
    quantity         INT NOT NULL CHECK (quantity > 0),
    unit_price       DECIMAL(18,2) NOT NULL CHECK (unit_price >= 0),
    line_total       DECIMAL(18,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    item_status      VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (item_status IN ('PENDING','ORDERED','CANCELLED')),
    cancel_reason    VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS ix_order_details_order_id ON order_details(order_id);
CREATE INDEX IF NOT EXISTS ix_order_details_product_id ON order_details(product_id);

-- payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id       SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES orders(order_id) UNIQUE,
    cashier_id       INT NOT NULL REFERENCES users(user_id),
    paid_at          TIMESTAMP,
    method           VARCHAR(20) NOT NULL CHECK (method IN ('CASH','CARD','TRANSFER')),
    amount_paid      DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    final_amount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_status   VARCHAR(20) NOT NULL DEFAULT 'SUCCESS' CHECK (payment_status IN ('SUCCESS','FAILED','REFUNDED')),
    transaction_ref  VARCHAR(100),
    CONSTRAINT ck_payments_amounts CHECK (amount_paid >= 0 AND discount_amount >= 0 AND final_amount >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_payments_transaction_ref_notnull ON payments(transaction_ref) WHERE transaction_ref IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_payments_paid_at ON payments(paid_at);
CREATE INDEX IF NOT EXISTS ix_payments_status ON payments(payment_status);

-- bookings
CREATE TABLE IF NOT EXISTS bookings (
    booking_id          SERIAL PRIMARY KEY,
    booking_code        VARCHAR(20) NOT NULL UNIQUE,
    customer_name       VARCHAR(100) NOT NULL,
    customer_phone      VARCHAR(20) NOT NULL,
    booking_date        DATE NOT NULL,
    booking_time        TIME NOT NULL,
    party_size          INT NOT NULL DEFAULT 2 CHECK (party_size > 0),
    note                VARCHAR(500),
    status              VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
                        CHECK (status IN ('PENDING','CONFIRMED','CHECKED_IN','CANCELLED','NO_SHOW','COMPLETED','SEATED')),
    cancel_reason       VARCHAR(500),
    table_id            INT REFERENCES tables(table_id),
    user_id             INT REFERENCES users(user_id),
    
    -- Pre-order deposit fields
    deposit_amount      DECIMAL(18,2) DEFAULT 0.00,
    deposit_status      VARCHAR(20) DEFAULT 'PENDING' CHECK (deposit_status IN ('PENDING','PAID','REFUNDED','FORFEITED')),
    deposit_ref         VARCHAR(100),
    preorder_locked_at  TIMESTAMP,
    
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_bookings_date_status ON bookings(booking_date, status);
CREATE INDEX IF NOT EXISTS ix_bookings_phone ON bookings(customer_phone);
CREATE INDEX IF NOT EXISTS ix_bookings_deposit_status ON bookings(deposit_status);
CREATE INDEX IF NOT EXISTS ix_bookings_preorder_locked ON bookings(preorder_locked_at);

-- pre_order_items
CREATE TABLE IF NOT EXISTS pre_order_items (
    pre_order_item_id SERIAL PRIMARY KEY,
    booking_id        INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    product_id        INT NOT NULL REFERENCES products(product_id),
    quantity          INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    note              VARCHAR(255),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

-- system_config
CREATE TABLE IF NOT EXISTS system_config (
    config_key   VARCHAR(50) PRIMARY KEY,
    config_value VARCHAR(255) NOT NULL,
    description  VARCHAR(255)
);

-- permissions
CREATE TABLE IF NOT EXISTS permissions (
    perm_id    SERIAL PRIMARY KEY,
    role_id    INT NOT NULL REFERENCES roles(role_id),
    permission VARCHAR(100) NOT NULL,
    UNIQUE (role_id, permission)
);

-- audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id      SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(user_id),
    action      VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id   INT,
    reason      VARCHAR(500),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_audit_logs_created ON audit_logs(created_at);

-- user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id  VARCHAR(128) PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMP NOT NULL,
    ip          VARCHAR(45),
    user_agent  VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS ix_user_sessions_user_expires ON user_sessions(user_id, expires_at);

------------------------------------------------------------
-- 2) SEED DATA
------------------------------------------------------------

-- roles
INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'Quản trị viên'),
('STAFF', 'Nhân viên phục vụ'),
('CASHIER', 'Thu ngân'),
('CUSTOMER', 'Khách hàng')
ON CONFLICT (role_name) DO NOTHING;

-- users
INSERT INTO users (role_id, username, password_hash, full_name, phone, email, status, created_at, failed_login_count)
VALUES
((SELECT role_id FROM roles WHERE role_name='ADMIN'), 'admin', 'admin123', 'Administrator', '0900000001', 'admin@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='STAFF'), 'staff1', 'staff123', 'Staff Demo', '0900000002', 'staff1@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='CASHIER'), 'cashier1', 'cashier123', 'Cashier Demo', '0900000003', 'cashier1@demo.local', 'ACTIVE', NOW(), 0),
((SELECT role_id FROM roles WHERE role_name='CUSTOMER'), 'customer1', 'customer123', 'Customer Demo', '0900000004', 'customer1@demo.local', 'ACTIVE', NOW(), 0)
ON CONFLICT (username) DO NOTHING;

-- system_config
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
('SEPAY_ENABLED', 'true', 'Bật/tắt thanh toán QR qua SePay'),
('GROQ_API_KEY', '', 'API Key của Groq cho chatbot AI'),
('GROQ_MODEL', 'llama-3.3-70b-versatile', 'Model AI sử dụng cho chatbot (Groq)'),
('CHATBOT_ENABLED', 'true', 'Bật/tắt chatbot AI trên trang khách hàng'),
('GOOGLE_CLIENT_ID', '120394683638-3i5duilf0c5dcch0l82c08to6ge9nd2f.apps.googleusercontent.com', 'Google OAuth Client ID'),
('GOOGLE_CLIENT_SECRET', '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', 'Google OAuth Client Secret'),
('GOOGLE_REDIRECT_URI', 'http://localhost:8080/oauth2/google/callback', 'Google OAuth Redirect URI')
ON CONFLICT (config_key) DO NOTHING;

-- areas
INSERT INTO areas (area_name, description) VALUES
('Tầng 1', 'Khu tầng 1'),
('Tầng 2', 'Khu tầng 2'),
('VIP', 'Phòng VIP'),
('Sân vườn', 'Ngoài trời')
ON CONFLICT (area_name) DO NOTHING;

-- tables
INSERT INTO tables (area_id, table_name, capacity, status) VALUES
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T01', 4, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T02', 4, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='Tầng 1'), 'T03', 6, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='Tầng 2'), 'T04', 4, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='Tầng 2'), 'T05', 8, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='VIP'), 'V01', 10, 'EMPTY'),
((SELECT area_id FROM areas WHERE area_name='VIP'), 'V02', 12, 'EMPTY')
ON CONFLICT (table_name) DO NOTHING;

-- categories
INSERT INTO categories (category_name, status) VALUES
('Món khai vị', 'ACTIVE'),
('Món chính', 'ACTIVE'),
('Đồ uống', 'ACTIVE'),
('Tráng miệng', 'ACTIVE')
ON CONFLICT (category_name) DO NOTHING;

-- products
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

-- RBAC permissions for STAFF
INSERT INTO permissions (role_id, permission)
SELECT r.role_id, p.perm
FROM roles r, (VALUES
    ('dashboard.view'), ('tables.view'), ('tables.update_status'),
    ('order.view'), ('order.create'), ('order.update'),
    ('categories.view'), ('menu.view'), ('booking.view'), ('booking.manage')
) AS p(perm)
WHERE r.role_name = 'STAFF'
ON CONFLICT (role_id, permission) DO NOTHING;

-- RBAC permissions for CASHIER
INSERT INTO permissions (role_id, permission)
SELECT r.role_id, p.perm
FROM roles r, (VALUES
    ('dashboard.view'), ('order.view'),
    ('payment.view'), ('payment.create')
) AS p(perm)
WHERE r.role_name = 'CASHIER'
ON CONFLICT (role_id, permission) DO NOTHING;

-- Demo bookings with pre-orders
DO $$
DECLARE
    v_booking_id INT;
    v_product_pho INT;
    v_product_tra INT;
    v_table_v01 INT;
    v_table_t01 INT;
    v_staff_id INT;
BEGIN
    -- Get IDs
    SELECT user_id INTO v_staff_id FROM users WHERE username = 'staff1';
    SELECT table_id INTO v_table_v01 FROM tables WHERE table_name = 'V01';
    SELECT table_id INTO v_table_t01 FROM tables WHERE table_name = 'T01';
    SELECT product_id INTO v_product_pho FROM products WHERE product_name = 'Phở bò';
    SELECT product_id INTO v_product_tra FROM products WHERE product_name = 'Trà đá';
    
    -- Booking 1: PENDING with pre-order
    INSERT INTO bookings (
        booking_code, customer_name, customer_phone,
        booking_date, booking_time, party_size, note, status,
        table_id, user_id, created_at
    ) VALUES (
        'BK-2026-001', 'Nguyễn Văn A', '0911111111',
        CURRENT_DATE, '18:00'::TIME, 4, 'Gần cửa sổ', 'PENDING',
        v_table_v01, v_staff_id, NOW()
    )
    ON CONFLICT (booking_code) DO NOTHING
    RETURNING booking_id INTO v_booking_id;
    
    -- Add pre-order items for booking 1
    IF v_booking_id IS NOT NULL THEN
        INSERT INTO pre_order_items (booking_id, product_id, quantity, note, created_at)
        VALUES
        (v_booking_id, v_product_pho, 1, 'Ít hành', NOW()),
        (v_booking_id, v_product_tra, 2, 'Đá ít', NOW())
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Booking 2: CONFIRMED
    INSERT INTO bookings (
        booking_code, customer_name, customer_phone,
        booking_date, booking_time, party_size, note, status,
        table_id, user_id, created_at
    ) VALUES (
        'BK-2026-002', 'Trần Thị B', '0922222222',
        CURRENT_DATE, '19:00'::TIME, 2, 'Yên tĩnh', 'CONFIRMED',
        v_table_t01, v_staff_id, NOW()
    )
    ON CONFLICT (booking_code) DO NOTHING;
END $$;

-- Demo orders (PAID order example)
DO $$
DECLARE
    v_order_id INT;
    v_table_t01 INT;
    v_staff_id INT;
    v_cashier_id INT;
    v_product_pho INT;
    v_product_tra INT;
BEGIN
    -- Get IDs
    SELECT user_id INTO v_staff_id FROM users WHERE username = 'staff1';
    SELECT user_id INTO v_cashier_id FROM users WHERE username = 'cashier1';
    SELECT table_id INTO v_table_t01 FROM tables WHERE table_name = 'T01';
    SELECT product_id INTO v_product_pho FROM products WHERE product_name = 'Phở bò';
    SELECT product_id INTO v_product_tra FROM products WHERE product_name = 'Trà đá';
    
    -- Create OPEN order
    INSERT INTO orders (
        table_id, created_by, order_type, opened_at, status,
        subtotal, discount_amount, total_amount, note
    ) VALUES (
        v_table_t01, v_staff_id, 'DINE_IN', NOW() - INTERVAL '60 minutes', 'OPEN',
        0, 0, 0, 'Order demo 1'
    )
    RETURNING order_id INTO v_order_id;
    
    -- Add order details
    INSERT INTO order_details (order_id, product_id, quantity, unit_price, item_status)
    VALUES
    (v_order_id, v_product_pho, 2, 60000, 'ORDERED'),
    (v_order_id, v_product_tra, 2, 5000, 'ORDERED');
    
    -- Update order totals and mark as SERVED
    UPDATE orders SET
        subtotal = 130000,
        discount_amount = 0,
        total_amount = 130000,
        status = 'SERVED'
    WHERE order_id = v_order_id;
    
    -- Create payment
    INSERT INTO payments (
        order_id, cashier_id, paid_at, method,
        amount_paid, discount_amount, final_amount,
        payment_status, transaction_ref
    ) VALUES (
        v_order_id, v_cashier_id, NOW() - INTERVAL '30 minutes', 'CASH',
        130000, 0, 130000,
        'SUCCESS', 'TXN001'
    );
    
    -- Mark order as PAID
    UPDATE orders SET
        status = 'PAID',
        closed_at = NOW() - INTERVAL '30 minutes'
    WHERE order_id = v_order_id;
    
    -- Add audit logs
    INSERT INTO audit_logs (user_id, action, target_type, target_id, reason, created_at)
    VALUES
    (v_staff_id, 'order.create', 'orders', v_order_id, 'Tạo đơn demo', NOW()),
    (v_cashier_id, 'payment.create', 'orders', v_order_id, 'Thanh toán demo', NOW());
END $$;

------------------------------------------------------------
-- 3) NOTES
------------------------------------------------------------

-- PostgreSQL differences from SQL Server:
-- 1. SERIAL instead of IDENTITY(1,1)
-- 2. VARCHAR instead of NVARCHAR
-- 3. TIMESTAMP instead of DATETIME2
-- 4. NOW() instead of SYSDATETIME()
-- 5. GENERATED ALWAYS AS ... STORED instead of computed columns with PERSISTED
-- 6. DO $$ ... END $$ blocks instead of DECLARE/BEGIN/END for procedural code
-- 7. ON CONFLICT DO NOTHING instead of checking for existence before INSERT
-- 8. No triggers needed - application handles business logic

-- To run this script:
-- 1. Copy entire content
-- 2. Paste into Supabase SQL Editor
-- 3. Click "Run"
-- 4. Verify tables and data created successfully
