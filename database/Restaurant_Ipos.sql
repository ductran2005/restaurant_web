/* =========================================================
   Restaurant_Ipos - FULL RECREATE + FULL SEED (NEW 100%)
   - products has quantity
   - includes bookings + pre_order + config + permissions + audit + sessions
   - safe seeding order: OPEN -> details -> payment -> PAID
   ========================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID(N'Restaurant_Ipos') IS NOT NULL
BEGIN
    ALTER DATABASE Restaurant_Ipos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Restaurant_Ipos;
END
GO

CREATE DATABASE Restaurant_Ipos;
GO

USE Restaurant_Ipos;
GO


BEGIN TRY
BEGIN TRANSACTION;

------------------------------------------------------------
-- 1) SCHEMA
------------------------------------------------------------

-- roles
CREATE TABLE roles (
    role_id      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_roles PRIMARY KEY,
    role_name    NVARCHAR(50)  NOT NULL,
    description  NVARCHAR(255) NULL,
    CONSTRAINT UQ_roles_role_name UNIQUE (role_name)
);

-- users
CREATE TABLE users (
    user_id              INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_users PRIMARY KEY,
    role_id              INT           NOT NULL,
    username             NVARCHAR(50)  NOT NULL,
    password_hash        NVARCHAR(255) NOT NULL,
    full_name            NVARCHAR(100) NULL,
    phone                NVARCHAR(20)  NULL,
    email                NVARCHAR(120) NULL,
    status               NVARCHAR(20)  NOT NULL CONSTRAINT DF_users_status DEFAULT ('ACTIVE'),
    created_at           DATETIME2(0)  NOT NULL CONSTRAINT DF_users_created_at DEFAULT (SYSDATETIME()),
    failed_login_count   INT           NOT NULL CONSTRAINT DF_users_failed_login DEFAULT (0),
    last_failed_login_at DATETIME2(0)  NULL,
    locked_until         DATETIME2(0)  NULL,

    CONSTRAINT FK_users_roles FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE UNIQUE INDEX UX_users_email_notnull ON users(email) WHERE email IS NOT NULL;
CREATE INDEX IX_users_role_id ON users(role_id);

-- areas
CREATE TABLE areas (
    area_id      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_areas PRIMARY KEY,
    area_name    NVARCHAR(100) NOT NULL,
    description  NVARCHAR(255) NULL,
    CONSTRAINT UQ_areas_area_name UNIQUE (area_name)
);

-- tables
CREATE TABLE tables (
    table_id     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tables PRIMARY KEY,
    area_id      INT          NOT NULL,
    table_name   NVARCHAR(50) NOT NULL,
    capacity     INT          NOT NULL,
    status       NVARCHAR(20) NOT NULL CONSTRAINT DF_tables_status DEFAULT ('AVAILABLE'),

    CONSTRAINT FK_tables_areas FOREIGN KEY (area_id) REFERENCES areas(area_id),
    CONSTRAINT UQ_tables_table_name UNIQUE (table_name),
    CONSTRAINT CK_tables_capacity CHECK (capacity > 0),
    CONSTRAINT CK_tables_status CHECK (status IN ('AVAILABLE','IN_USE'))
);
CREATE INDEX IX_tables_area_status ON tables(area_id, status);

-- categories
CREATE TABLE categories (
    category_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_categories PRIMARY KEY,
    category_name  NVARCHAR(100) NOT NULL,
    status         NVARCHAR(20)  NOT NULL CONSTRAINT DF_categories_status DEFAULT ('ACTIVE'),

    CONSTRAINT UQ_categories_category_name UNIQUE (category_name),
    CONSTRAINT CK_categories_status CHECK (status IN ('ACTIVE','INACTIVE'))
);

-- products (✅ quantity)
CREATE TABLE products (
    product_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_products PRIMARY KEY,
    category_id   INT            NOT NULL,
    product_name  NVARCHAR(150)  NOT NULL,
    price         DECIMAL(18,2)  NOT NULL,
    cost_price    DECIMAL(18,2)  NOT NULL,
    quantity      INT            NOT NULL CONSTRAINT DF_products_quantity DEFAULT (0),
    status        NVARCHAR(20)   NOT NULL CONSTRAINT DF_products_status DEFAULT ('AVAILABLE'),
    description   NVARCHAR(500)  NULL,

    CONSTRAINT FK_products_categories FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT UQ_products_product_name UNIQUE (product_name),
    CONSTRAINT CK_products_price CHECK (price >= 0),
    CONSTRAINT CK_products_cost_price CHECK (cost_price >= 0),
    CONSTRAINT CK_products_quantity CHECK (quantity >= 0),
    CONSTRAINT CK_products_status CHECK (status IN ('AVAILABLE','UNAVAILABLE'))
);
CREATE INDEX IX_products_category ON products(category_id);
CREATE INDEX IX_products_status ON products(status);

-- inventory
CREATE TABLE inventory (
    inventory_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_inventory PRIMARY KEY,
    product_id      INT           NOT NULL,
    current_qty     INT           NOT NULL CONSTRAINT DF_inventory_current_qty DEFAULT (0),
    reorder_level   INT           NOT NULL CONSTRAINT DF_inventory_reorder_level DEFAULT (0),
    updated_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_inventory_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_inventory_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT UQ_inventory_product UNIQUE (product_id),
    CONSTRAINT CK_inventory_current_qty CHECK (current_qty >= 0),
    CONSTRAINT CK_inventory_reorder_level CHECK (reorder_level >= 0)
);

-- inventory_log
CREATE TABLE inventory_log (
    log_id          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_inventory_log PRIMARY KEY,
    inventory_id    INT           NOT NULL,
    changed_by      INT           NOT NULL,
    type            NVARCHAR(20)  NOT NULL,
    qty_change      INT           NOT NULL,
    reason          NVARCHAR(255) NULL,
    created_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_inventory_logs_created DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_inventory_logs_inventory FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    CONSTRAINT FK_inventory_logs_users FOREIGN KEY (changed_by) REFERENCES users(user_id),
    CONSTRAINT CK_inventory_logs_type CHECK (type IN ('IN','OUT','ADJUST'))
);

-- orders
CREATE TABLE orders (
    order_id         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_orders PRIMARY KEY,
    table_id         INT           NOT NULL,
    created_by       INT           NOT NULL,
    order_type       NVARCHAR(20)  NOT NULL CONSTRAINT DF_orders_order_type DEFAULT ('DINE_IN'),
    opened_at        DATETIME2(0)  NOT NULL CONSTRAINT DF_orders_opened_at DEFAULT (SYSDATETIME()),
    closed_at        DATETIME2(0)  NULL,
    status           NVARCHAR(20)  NOT NULL CONSTRAINT DF_orders_status DEFAULT ('OPEN'),
    subtotal         DECIMAL(18,2) NOT NULL CONSTRAINT DF_orders_subtotal DEFAULT (0),
    discount_amount  DECIMAL(18,2) NOT NULL CONSTRAINT DF_orders_discount DEFAULT (0),
    total_amount     DECIMAL(18,2) NOT NULL CONSTRAINT DF_orders_total DEFAULT (0),
    note             NVARCHAR(500) NULL,

    CONSTRAINT FK_orders_tables FOREIGN KEY (table_id) REFERENCES tables(table_id),
    CONSTRAINT FK_orders_users_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),

    CONSTRAINT CK_orders_order_type CHECK (order_type IN ('DINE_IN','TAKE_AWAY','DELIVERY')),
    CONSTRAINT CK_orders_status CHECK (status IN ('OPEN','SERVED','CANCELLED','PAID')),

    CONSTRAINT CK_orders_amounts CHECK (
        subtotal >= 0 AND discount_amount >= 0 AND total_amount >= 0
        AND discount_amount <= subtotal
    )
);
CREATE INDEX IX_orders_table_status_opened ON orders(table_id, status, opened_at);
CREATE INDEX IX_orders_created_by_opened   ON orders(created_by, opened_at);
CREATE INDEX IX_orders_status              ON orders(status);
CREATE INDEX IX_orders_opened_at           ON orders(opened_at);

CREATE UNIQUE INDEX UX_orders_one_open_per_table
ON orders(table_id)
WHERE status = 'OPEN';

-- order_details
CREATE TABLE order_details (
    order_detail_id  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_order_details PRIMARY KEY,
    order_id         INT           NOT NULL,
    product_id       INT           NOT NULL,
    quantity         INT           NOT NULL,
    unit_price       DECIMAL(18,2) NOT NULL,
    line_total       AS (CAST(quantity AS DECIMAL(18,2)) * unit_price) PERSISTED,
    item_status      NVARCHAR(20)  NOT NULL CONSTRAINT DF_order_details_status DEFAULT ('PENDING'),
    cancel_reason    NVARCHAR(500) NULL,

    CONSTRAINT FK_order_details_orders
        FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_order_details_products
        FOREIGN KEY (product_id) REFERENCES products(product_id),

    CONSTRAINT CK_order_details_qty CHECK (quantity > 0),
    CONSTRAINT CK_order_details_prices CHECK (unit_price >= 0),
    CONSTRAINT CK_order_details_status CHECK (item_status IN ('PENDING','ORDERED','CANCELLED'))
);

-- UNIQUE index removed to allow adding same product multiple times (e.g. separate confirmed/pending batches)
CREATE INDEX IX_order_details_order_id ON order_details(order_id);
CREATE INDEX IX_order_details_product_id ON order_details(product_id);

-- payments
CREATE TABLE payments (
    payment_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_payments PRIMARY KEY,
    order_id         INT           NOT NULL,
    cashier_id       INT           NOT NULL,
    paid_at          DATETIME2(0)  NULL,
    method           NVARCHAR(20)  NOT NULL,
    amount_paid      DECIMAL(18,2) NOT NULL CONSTRAINT DF_payments_amount_paid DEFAULT (0),
    discount_amount  DECIMAL(18,2) NOT NULL CONSTRAINT DF_payments_discount DEFAULT (0),
    final_amount     DECIMAL(18,2) NOT NULL CONSTRAINT DF_payments_final DEFAULT (0),
    payment_status   NVARCHAR(20)  NOT NULL CONSTRAINT DF_payments_status DEFAULT ('SUCCESS'),
    transaction_ref  NVARCHAR(100) NULL,

    CONSTRAINT FK_payments_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT FK_payments_users_cashier FOREIGN KEY (cashier_id) REFERENCES users(user_id),
    CONSTRAINT UQ_payments_order UNIQUE (order_id),

    CONSTRAINT CK_payments_method CHECK (method IN ('CASH','CARD','TRANSFER')),
    CONSTRAINT CK_payments_status CHECK (payment_status IN ('SUCCESS','FAILED','REFUNDED')),
    CONSTRAINT CK_payments_amounts CHECK (amount_paid >= 0 AND discount_amount >= 0 AND final_amount >= 0),
    CONSTRAINT CK_payments_paid_at_success CHECK (
        (payment_status = 'SUCCESS' AND paid_at IS NOT NULL) OR (payment_status <> 'SUCCESS')
    )
);
CREATE UNIQUE INDEX UX_payments_transaction_ref_notnull
ON payments(transaction_ref)
WHERE transaction_ref IS NOT NULL;

CREATE INDEX IX_payments_paid_at ON payments(paid_at);
CREATE INDEX IX_payments_status ON payments(payment_status);

-- bookings
CREATE TABLE bookings (
    booking_id      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bookings PRIMARY KEY,
    booking_code    NVARCHAR(20)  NOT NULL,
    customer_name   NVARCHAR(100) NOT NULL,
    customer_phone  NVARCHAR(20)  NOT NULL,
    booking_date    DATE          NOT NULL,
    booking_time    TIME          NOT NULL,
    party_size      INT           NOT NULL CONSTRAINT DF_bookings_party_size DEFAULT (2),
    note            NVARCHAR(500) NULL,
    status          NVARCHAR(20)  NOT NULL CONSTRAINT DF_bookings_status DEFAULT ('PENDING'),
    cancel_reason   NVARCHAR(500) NULL,
    table_id        INT           NULL,
    user_id         INT           NULL,
    
    -- Pre-order deposit fields
    deposit_amount     DECIMAL(18,2) NULL CONSTRAINT DF_bookings_deposit_amount DEFAULT (0.00),
    deposit_status     NVARCHAR(20)  NULL CONSTRAINT DF_bookings_deposit_status DEFAULT ('PENDING'),
    deposit_ref        NVARCHAR(100) NULL,
    preorder_locked_at DATETIME2(0)  NULL,
    
    created_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_bookings_created_at DEFAULT (SYSDATETIME()),
    updated_at      DATETIME2(0)  NULL,

    CONSTRAINT FK_bookings_tables FOREIGN KEY (table_id) REFERENCES tables(table_id),
    CONSTRAINT FK_bookings_users  FOREIGN KEY (user_id)  REFERENCES users(user_id),
    CONSTRAINT UQ_bookings_code UNIQUE (booking_code),
    CONSTRAINT CK_bookings_party CHECK (party_size > 0),
    CONSTRAINT CK_bookings_status CHECK (status IN ('PENDING','CONFIRMED','CHECKED_IN','CANCELLED','NO_SHOW','COMPLETED','SEATED')),
    CONSTRAINT CK_bookings_deposit_status CHECK (deposit_status IN ('PENDING','PAID','REFUNDED','FORFEITED'))
);
CREATE INDEX IX_bookings_date_status ON bookings(booking_date, status);
CREATE INDEX IX_bookings_phone ON bookings(customer_phone);
CREATE INDEX IX_bookings_deposit_status ON bookings(deposit_status);
CREATE INDEX IX_bookings_preorder_locked ON bookings(preorder_locked_at);

-- pre_order_items
CREATE TABLE pre_order_items (
    pre_order_item_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_pre_order_items PRIMARY KEY,
    booking_id        INT           NOT NULL,
    product_id        INT           NOT NULL,
    quantity          INT           NOT NULL CONSTRAINT DF_pre_order_qty DEFAULT (1),
    note              NVARCHAR(255) NULL,
    created_at        DATETIME2(0)  NOT NULL CONSTRAINT DF_pre_order_created DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_pre_order_bookings FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT FK_pre_order_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT CK_pre_order_qty CHECK (quantity > 0)
);

-- system_config
CREATE TABLE system_config (
    config_key   NVARCHAR(50)  NOT NULL CONSTRAINT PK_system_config PRIMARY KEY,
    config_value NVARCHAR(255) NOT NULL,
    description  NVARCHAR(255) NULL
);

-- permissions
CREATE TABLE permissions (
    perm_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_permissions PRIMARY KEY,
    role_id    INT           NOT NULL,
    permission NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_permissions_roles FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT UQ_permissions_role_perm UNIQUE (role_id, permission)
);

-- audit_logs
CREATE TABLE audit_logs (
    log_id      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_audit_logs PRIMARY KEY,
    user_id     INT           NULL,
    action      NVARCHAR(100) NOT NULL,
    target_type NVARCHAR(50)  NULL,
    target_id   INT           NULL,
    reason      NVARCHAR(500) NULL,
    created_at  DATETIME2(0)  NOT NULL CONSTRAINT DF_audit_logs_created DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_audit_logs_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE INDEX IX_audit_logs_created ON audit_logs(created_at);

-- user_sessions
CREATE TABLE user_sessions (
    session_id  NVARCHAR(128) NOT NULL CONSTRAINT PK_user_sessions PRIMARY KEY,
    user_id     INT NOT NULL,
    created_at  DATETIME2(0) NOT NULL CONSTRAINT DF_user_sessions_created_at DEFAULT (SYSDATETIME()),
    expires_at  DATETIME2(0) NOT NULL,
    ip          NVARCHAR(45) NULL,
    user_agent  NVARCHAR(255) NULL,
    CONSTRAINT FK_user_sessions_users FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
CREATE INDEX IX_user_sessions_user_expires ON user_sessions(user_id, expires_at);

-- trigger: block edit order_details if PAID/CANCELLED
EXEC('
CREATE TRIGGER TRG_BlockEditOrderDetails_WhenOrderClosed
ON order_details
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM orders o
        JOIN (
            SELECT order_id FROM inserted
            UNION
            SELECT order_id FROM deleted
        ) x ON x.order_id = o.order_id
        WHERE o.status IN (''PAID'',''CANCELLED'')
    )
    BEGIN
        RAISERROR(''Cannot modify order details when order is PAID or CANCELLED.'', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
');

------------------------------------------------------------
-- 2) SEED DATA (MỚI 100%)
------------------------------------------------------------

-- roles
INSERT INTO roles (role_name, description) VALUES
(N'ADMIN', N'Quản trị viên'),
(N'STAFF', N'Nhân viên phục vụ'),
(N'CASHIER', N'Thu ngân'),
(N'CUSTOMER', N'Khách hàng');

DECLARE @ADMIN_ROLE INT=(SELECT role_id FROM roles WHERE role_name='ADMIN');
DECLARE @STAFF_ROLE INT=(SELECT role_id FROM roles WHERE role_name='STAFF');
DECLARE @CASHIER_ROLE INT=(SELECT role_id FROM roles WHERE role_name='CASHIER');
DECLARE @CUSTOMER_ROLE INT=(SELECT role_id FROM roles WHERE role_name='CUSTOMER');

-- users (TK/MK demo đầy đủ)
INSERT INTO users (role_id, username, password_hash, full_name, phone, email, status) VALUES
(@ADMIN_ROLE,   N'admin',    N'admin123',    N'Administrator', N'0900000001', N'admin@demo.local',    N'ACTIVE'),
(@STAFF_ROLE,   N'staff1',   N'staff123',    N'Staff Demo',    N'0900000002', N'staff1@demo.local',   N'ACTIVE'),
(@CASHIER_ROLE, N'cashier1', N'cashier123',  N'Cashier Demo',  N'0900000003', N'cashier1@demo.local', N'ACTIVE'),
(@CUSTOMER_ROLE,N'customer1',N'customer123', N'Customer Demo', N'0900000004', N'customer1@demo.local',N'ACTIVE');

DECLARE @STAFF_ID INT=(SELECT user_id FROM users WHERE username='staff1');
DECLARE @CASHIER_ID INT=(SELECT user_id FROM users WHERE username='cashier1');

-- system_config
INSERT INTO system_config (config_key, config_value, description) VALUES
('vat_rate',         '10',    N'VAT %'),
('service_fee_rate', '5',     N'Phí dịch vụ %'),
('opening_hours',    '10:00', N'Giờ mở cửa'),
('closing_hours',    '22:00', N'Giờ đóng cửa'),
('hold_minutes',     '15',    N'Phút giữ bàn'),
('cutoff_minutes',   '60',    N'Hạn sửa pre-order (phút)');

-- areas
INSERT INTO areas(area_name, description) VALUES
(N'Tầng 1',N'Khu tầng 1'),
(N'Tầng 2',N'Khu tầng 2'),
(N'VIP',N'Phòng VIP'),
(N'Sân vườn',N'Ngoài trời');

DECLARE @A1 INT=(SELECT area_id FROM areas WHERE area_name=N'Tầng 1');
DECLARE @A2 INT=(SELECT area_id FROM areas WHERE area_name=N'Tầng 2');
DECLARE @VIP INT=(SELECT area_id FROM areas WHERE area_name=N'VIP');

-- tables
INSERT INTO tables(area_id, table_name, capacity, status) VALUES
(@A1,'T01',4,'AVAILABLE'),
(@A1,'T02',4,'AVAILABLE'),
(@A1,'T03',6,'AVAILABLE'),
(@A2,'T04',4,'AVAILABLE'),
(@A2,'T05',8,'AVAILABLE'),
(@VIP,'V01',10,'AVAILABLE'),
(@VIP,'V02',12,'AVAILABLE');

DECLARE @T01 INT=(SELECT table_id FROM tables WHERE table_name='T01');
DECLARE @T02 INT=(SELECT table_id FROM tables WHERE table_name='T02');
DECLARE @V01 INT=(SELECT table_id FROM tables WHERE table_name='V01');

-- categories
INSERT INTO categories(category_name, status) VALUES
(N'Món khai vị','ACTIVE'),
(N'Món chính','ACTIVE'),
(N'Đồ uống','ACTIVE'),
(N'Tráng miệng','ACTIVE');

DECLARE @CAT_APP INT=(SELECT category_id FROM categories WHERE category_name=N'Món khai vị');
DECLARE @CAT_MAIN INT=(SELECT category_id FROM categories WHERE category_name=N'Món chính');
DECLARE @CAT_DRINK INT=(SELECT category_id FROM categories WHERE category_name=N'Đồ uống');
DECLARE @CAT_DES INT=(SELECT category_id FROM categories WHERE category_name=N'Tráng miệng');

-- products (có quantity)
INSERT INTO products(category_id, product_name, price, cost_price, quantity, status, description) VALUES
(@CAT_APP,N'Gỏi cuốn tôm thịt',30000,15000,80,'AVAILABLE',N'Gỏi cuốn truyền thống'),
(@CAT_APP,N'Chả giò',35000,17000,70,'AVAILABLE',N'Chả giò chiên giòn'),
(@CAT_APP,N'Salad dầu giấm',40000,20000,40,'AVAILABLE',N'Salad rau tươi'),

(@CAT_MAIN,N'Phở bò',60000,30000,60,'AVAILABLE',N'Phở bò truyền thống'),
(@CAT_MAIN,N'Phở gà',55000,27000,50,'AVAILABLE',N'Phở gà ta'),
(@CAT_MAIN,N'Bún bò Huế',65000,32000,45,'AVAILABLE',N'Bún bò cay'),
(@CAT_MAIN,N'Cơm tấm sườn',55000,25000,55,'AVAILABLE',N'Cơm tấm sườn nướng'),
(@CAT_MAIN,N'Mì xào bò',65000,30000,35,'AVAILABLE',N'Mì xào bò rau'),
(@CAT_MAIN,N'Lẩu Thái',180000,90000,20,'AVAILABLE',N'Lẩu chua cay'),

(@CAT_DRINK,N'Trà đá',5000,1000,300,'AVAILABLE',N'Trà đá'),
(@CAT_DRINK,N'Nước suối',10000,4000,200,'AVAILABLE',N'Nước suối'),
(@CAT_DRINK,N'Coca Cola',15000,7000,120,'AVAILABLE',N'Nước ngọt'),
(@CAT_DRINK,N'Cam vắt',30000,12000,80,'AVAILABLE',N'Nước cam'),

(@CAT_DES,N'Bánh flan',20000,9000,60,'AVAILABLE',N'Flan'),
(@CAT_DES,N'Kem dừa',30000,12000,50,'AVAILABLE',N'Kem dừa'),
(@CAT_DES,N'Chè đậu xanh',20000,8000,70,'AVAILABLE',N'Chè đậu xanh');

-- RBAC permissions
INSERT INTO permissions(role_id, permission)
SELECT @STAFF_ROLE, v.perm
FROM (VALUES
    ('dashboard.view'),('tables.view'),('tables.update_status'),
    ('order.view'),('order.create'),('order.update'),
    ('categories.view'),('menu.view'),('booking.view'),('booking.manage')
) v(perm);

INSERT INTO permissions(role_id, permission)
SELECT @CASHIER_ROLE, v.perm
FROM (VALUES
    ('dashboard.view'),('order.view'),
    ('payment.view'),('payment.create')
) v(perm);

-- demo bookings + pre-order
INSERT INTO bookings(
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, note, status,
    table_id, user_id, created_at
) VALUES
('BK-2026-001', N'Nguyễn Văn A', '0911111111', CAST(GETDATE() AS DATE), CAST('18:00' AS TIME), 4, N'Gần cửa sổ', 'PENDING', @V01, @STAFF_ID, SYSDATETIME()),
('BK-2026-002', N'Trần Thị B',   '0922222222', CAST(GETDATE() AS DATE), CAST('19:00' AS TIME), 2, N'Yên tĩnh',   'CONFIRMED', @T01, @STAFF_ID, SYSDATETIME());

DECLARE @B1 INT=(SELECT booking_id FROM bookings WHERE booking_code='BK-2026-001');

DECLARE @P_PHO INT=(SELECT product_id FROM products WHERE product_name=N'Phở bò');
DECLARE @P_TRA INT=(SELECT product_id FROM products WHERE product_name=N'Trà đá');

INSERT INTO pre_order_items(booking_id, product_id, quantity, note, created_at)
VALUES
(@B1, @P_PHO, 1, N'Ít hành', SYSDATETIME()),
(@B1, @P_TRA, 2, N'Đá ít',  SYSDATETIME());

-- demo orders (đúng thứ tự tránh trigger)
DECLARE @P_COTAM INT=(SELECT product_id FROM products WHERE product_name=N'Cơm tấm sườn');

-- Order 1 PAID
INSERT INTO orders(table_id, created_by, order_type, opened_at, status, subtotal, discount_amount, total_amount, note)
VALUES (@T01, @STAFF_ID, 'DINE_IN', DATEADD(MINUTE,-60,SYSDATETIME()), 'OPEN', 0, 0, 0, N'Order demo 1');
DECLARE @O1 INT=SCOPE_IDENTITY();

INSERT INTO order_details(order_id, product_id, quantity, unit_price, item_status)
VALUES
(@O1, @P_PHO, 2, 60000, 'ORDERED'),
(@O1, @P_TRA, 2, 5000,  'ORDERED');

UPDATE orders SET subtotal=130000, discount_amount=0, total_amount=130000, status='SERVED'
WHERE order_id=@O1;

INSERT INTO payments(order_id, cashier_id, paid_at, method, amount_paid, discount_amount, final_amount, payment_status, transaction_ref)
VALUES (@O1, @CASHIER_ID, DATEADD(MINUTE,-30,SYSDATETIME()), 'CASH', 130000, 0, 130000, 'SUCCESS', 'TXN001');

UPDATE orders SET status='PAID', closed_at=DATEADD(MINUTE,-30,SYSDATETIME())
WHERE order_id=@O1;

-- Order 2 OPEN
INSERT INTO orders(table_id, created_by, order_type, opened_at, status, subtotal, discount_amount, total_amount, note)
VALUES (@T02, @STAFF_ID, 'DINE_IN', DATEADD(MINUTE,-10,SYSDATETIME()), 'OPEN', 0, 0, 0, N'Order demo 2');
DECLARE @O2 INT=SCOPE_IDENTITY();

INSERT INTO order_details(order_id, product_id, quantity, unit_price, item_status)
VALUES
(@O2, @P_COTAM, 1, 55000, 'ORDERED'),
(@O2, @P_TRA,   1, 5000,  'ORDERED');

UPDATE orders SET subtotal=60000, discount_amount=0, total_amount=60000
WHERE order_id=@O2;

-- audit logs demo
INSERT INTO audit_logs(user_id, action, target_type, target_id, reason, created_at)
VALUES
(@STAFF_ID,  'order.create',   'orders', @O1, N'Tạo đơn demo', SYSDATETIME()),
(@CASHIER_ID,'payment.create', 'orders', @O1, N'Thanh toán demo', SYSDATETIME());

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000)=ERROR_MESSAGE();
    DECLARE @Line INT=ERROR_LINE();
    RAISERROR(N'FULL recreate+seed failed at line %d: %s',16,1,@Line,@Err);
END CATCH;
GO
