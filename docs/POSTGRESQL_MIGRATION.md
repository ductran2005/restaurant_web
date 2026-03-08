# PostgreSQL Migration Guide

## Tổng quan

Project đã được chuyển đổi từ SQL Server sang PostgreSQL (Supabase) với các thay đổi sau:

## 1. Thay đổi Native SQL Queries

### BookingService.java

**Trước (SQL Server):**
```java
CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2)
```

**Sau (PostgreSQL):**
```java
CAST(booking_date || ' ' || booking_time AS TIMESTAMP)
```

### TestConnection.java

**Trước (SQL Server):**
```java
SELECT DB_NAME()
```

**Sau (PostgreSQL):**
```java
SELECT current_database()
SELECT version()
```

## 2. Cập nhật Schema (supabase_seed.sql)

File `supabase_seed.sql` đã được cập nhật để giống 100% với SQL Server schema (`Restaurant_Ipos.sql`):

### Tất cả bảng (15 bảng):
1. `roles` - Vai trò người dùng
2. `users` - Tài khoản người dùng
3. `areas` - Khu vực nhà hàng
4. `tables` - Bàn ăn
5. `categories` - Danh mục món ăn
6. `products` - Sản phẩm/món ăn (có quantity)
7. `inventory` - Quản lý tồn kho
8. `inventory_log` - Lịch sử thay đổi tồn kho
9. `orders` - Đơn hàng
10. `order_details` - Chi tiết đơn hàng
11. `payments` - Thanh toán
12. `bookings` - Đặt bàn (có deposit fields)
13. `pre_order_items` - Món đặt trước
14. `system_config` - Cấu hình hệ thống
15. `permissions` - Phân quyền RBAC
16. `audit_logs` - Lịch sử thao tác
17. `user_sessions` - Phiên đăng nhập

### Tất cả constraints và indexes:
- Primary keys, foreign keys, unique constraints
- Check constraints cho status, amounts, quantities
- Indexes cho performance (date, status, phone, etc.)
- Unique indexes với WHERE clause (conditional indexes)

### Seed data đầy đủ:
- 4 roles (ADMIN, STAFF, CASHIER, CUSTOMER)
- 4 demo users với passwords
- 12 system configs (bao gồm SePay settings)
- 4 areas (Tầng 1, Tầng 2, VIP, Sân vườn)
- 7 tables (T01-T05, V01-V02)
- 4 categories
- 16 products với inventory
- RBAC permissions cho STAFF và CASHIER
- 2 demo bookings (1 có pre-order)
- 1 demo order đã PAID với payment record
- Audit logs demo

## 3. Sự khác biệt PostgreSQL vs SQL Server

| Tính năng | SQL Server | PostgreSQL |
|-----------|-----------|------------|
| Auto increment | IDENTITY(1,1) | SERIAL |
| String type | NVARCHAR | VARCHAR |
| DateTime | DATETIME2 | TIMESTAMP |
| Concatenation | CONCAT() | \|\| operator |
| Cast to string | CAST(x AS VARCHAR) | x::TEXT |
| Current time | SYSDATETIME() | NOW() |
| Current database | DB_NAME() | current_database() |
| Computed column | AS (...) PERSISTED | GENERATED ALWAYS AS (...) STORED |
| Procedural code | DECLARE/BEGIN/END | DO $$ ... END $$ |
| Conditional insert | IF NOT EXISTS | ON CONFLICT DO NOTHING |
| Scope identity | SCOPE_IDENTITY() | RETURNING id INTO variable |

## 4. Hibernate Configuration

File `hibernate.cfg.xml` đã được cấu hình cho Supabase:

```xml
<property name="hibernate.connection.driver_class">org.postgresql.Driver</property>
<property name="hibernate.connection.url">
  jdbc:postgresql://aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres?sslmode=require&amp;prepareThreshold=0
</property>
<property name="hibernate.dialect">org.hibernate.dialect.PostgreSQLDialect</property>
<property name="hibernate.hbm2ddl.auto">update</property>
```

## 5. Hướng dẫn Deploy

### Bước 1: Tạo database trên Supabase
1. Đăng nhập vào [Supabase Dashboard](https://supabase.com/dashboard)
2. Tạo project mới hoặc sử dụng project hiện có
3. Vào **SQL Editor**

### Bước 2: Chạy seed script
1. Copy toàn bộ nội dung file `database/supabase_seed.sql`
2. Paste vào SQL Editor
3. Click **Run** để tạo bảng và dữ liệu mẫu

### Bước 3: Cập nhật connection string
1. Lấy connection string từ Supabase Dashboard > Settings > Database
2. Cập nhật `hibernate.cfg.xml` với thông tin của bạn:
   - URL
   - Username
   - Password

### Bước 4: Build và deploy
```bash
mvn clean package -DskipTests
```

## 6. Lưu ý quan trọng

### Connection Pooling
- Supabase free tier: Max 60 connections
- Project config: 10 connections/instance
- Sử dụng Pooler (port 6543) thay vì direct connection (port 5432)

### Background Scheduler
- `BookingScheduler` chạy mỗi 5 phút để:
  - Auto-assign tables (60 phút trước)
  - Auto-cancel late bookings (20 phút sau)
  - Lock pre-orders (60 phút trước)
  
**Vấn đề**: Nếu deploy lên free hosting (Render, Railway), app có thể sleep → scheduler không chạy

**Giải pháp**:
1. Dùng external cron service (cron-job.org) để ping app mỗi 5 phút
2. Dùng Supabase Edge Functions + Cron Jobs
3. Upgrade hosting lên paid tier

### hbm2ddl.auto
- Hiện tại: `update` (tự động tạo/cập nhật bảng)
- Production: Nên đổi thành `validate` sau khi schema ổn định

## 7. Testing

### Test connection
```bash
mvn exec:java -Dexec.mainClass="market.restaurant_web.TestConnection"
```

### Test scheduler
1. Start server
2. Xem log console để kiểm tra scheduler chạy
3. Tạo booking test và đợi scheduler xử lý

## 8. Troubleshooting

### Lỗi: "relation does not exist"
- Chạy lại seed script
- Kiểm tra `hbm2ddl.auto=update` trong hibernate.cfg.xml

### Lỗi: "too many connections"
- Giảm `hibernate.c3p0.max_size` xuống 5
- Kiểm tra connection leaks (đóng session đúng cách)

### Scheduler không chạy
- Kiểm tra log console
- Verify app không bị sleep
- Setup external cron để keep-alive

## 9. Files đã thay đổi

- ✅ `src/main/java/market/restaurant_web/service/BookingService.java`
- ✅ `src/main/java/market/restaurant_web/TestConnection.java`
- ✅ `database/supabase_seed.sql`
- ✅ `src/main/resources/hibernate.cfg.xml` (đã có từ trước)

## 10. Files không cần sửa

- ❌ `database/Restaurant_Ipos.sql` - SQL Server schema cũ, không dùng nữa
- ❌ Entity classes - Hibernate tự động map
- ❌ DAO classes - Sử dụng HQL, không phụ thuộc database
