# Fix Lỗi Thanh Toán Cọc Pre-Order

## Vấn Đề

Khi click "Xác nhận đã thanh toán" trong trang checkout, hệ thống không lưu thông tin deposit vào database.

## Nguyên Nhân

Controller `PreOrderCheckoutController` chỉ redirect với message thành công mà không cập nhật booking với thông tin deposit.

## Giải Pháp

### Bước 1: Chạy Migration Database

Trước tiên, cần thêm các cột deposit vào bảng `bookings`:

```sql
-- Chạy file migration
source database/migration_preorder_deposit.sql
```

Hoặc chạy trực tiếp:

```sql
USE Restaurant_Ipos;

-- Thêm các cột deposit
ALTER TABLE bookings 
ADD COLUMN deposit_amount DECIMAL(18,2) DEFAULT 0.00 COMMENT 'Deposit amount (10% of pre-order total)',
ADD COLUMN deposit_status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING, PAID, REFUNDED, FORFEITED',
ADD COLUMN deposit_ref VARCHAR(100) COMMENT 'Payment reference/transaction ID',
ADD COLUMN preorder_locked_at DATETIME COMMENT 'Timestamp when pre-order is locked (60 mins before booking)';

-- Thêm index
CREATE INDEX idx_bookings_deposit_status ON bookings(deposit_status);
CREATE INDEX idx_bookings_preorder_locked ON bookings(preorder_locked_at);

-- Update existing bookings
UPDATE bookings 
SET deposit_amount = 0.00, 
    deposit_status = 'PENDING' 
WHERE deposit_amount IS NULL;

COMMIT;
```

### Bước 2: Kiểm Tra Migration

```sql
-- Kiểm tra các cột đã được thêm
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    COLUMN_DEFAULT, 
    IS_NULLABLE,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'Restaurant_Ipos' 
  AND TABLE_NAME = 'bookings'
  AND COLUMN_NAME IN ('deposit_amount', 'deposit_status', 'deposit_ref', 'preorder_locked_at');
```

Kết quả mong đợi:
```
+---------------------+--------------+----------------+-------------+--------------------------------------------------+
| COLUMN_NAME         | DATA_TYPE    | COLUMN_DEFAULT | IS_NULLABLE | COLUMN_COMMENT                                   |
+---------------------+--------------+----------------+-------------+--------------------------------------------------+
| deposit_amount      | decimal      | 0.00           | YES         | Deposit amount (10% of pre-order total)          |
| deposit_status      | varchar      | PENDING        | YES         | PENDING, PAID, REFUNDED, FORFEITED               |
| deposit_ref         | varchar      | NULL           | YES         | Payment reference/transaction ID                 |
| preorder_locked_at  | datetime     | NULL           | YES         | Timestamp when pre-order is locked (60 mins...)  |
+---------------------+--------------+----------------+-------------+--------------------------------------------------+
```

### Bước 3: Rebuild Application

```bash
# Clean và rebuild
mvn clean package

# Hoặc nếu dùng IDE
# Right-click project → Maven → Reload Project
# Build → Rebuild Project
```

### Bước 4: Restart Server

Restart Tomcat hoặc server đang chạy để load code mới.

## Kiểm Tra

### Test Flow Hoàn Chỉnh

1. **Tạo booking và thêm món**
   ```
   - Truy cập: http://localhost:8080/restaurant_web/pre-order
   - Nhập mã booking hoặc SĐT
   - Thêm món vào pre-order
   ```

2. **Thanh toán cọc**
   ```
   - Click "Tiếp tục thanh toán cọc"
   - Chọn phương thức thanh toán (Bank/MoMo/ZaloPay)
   - Click "Xác nhận đã thanh toán"
   ```

3. **Kiểm tra database**
   ```sql
   SELECT 
       booking_code,
       deposit_amount,
       deposit_status,
       deposit_ref,
       updated_at
   FROM bookings
   WHERE booking_code = 'YOUR_BOOKING_CODE';
   ```

   Kết quả mong đợi:
   ```
   booking_code: BK-2026-001
   deposit_amount: 35000.00
   deposit_status: PAID
   deposit_ref: BANK_TRANSFER-1234567890
   updated_at: 2026-03-08 14:30:00
   ```

### Test Cases

#### Test 1: Thanh Toán Thành Công ✅

**Điều kiện:**
- Booking có pre-order items
- Tổng tiền: 350,000đ
- Cọc: 35,000đ (10%)

**Các bước:**
1. Vào trang checkout
2. Chọn "Chuyển khoản ngân hàng"
3. Click "Xác nhận đã thanh toán"

**Kết quả:**
- ✅ Redirect về `/pre-order?code=XXX&successMsg=...`
- ✅ Hiển thị: "Đặt cọc thành công 35000đ!"
- ✅ Database: deposit_status = PAID
- ✅ Database: deposit_amount = 35000.00
- ✅ Database: deposit_ref = BANK_TRANSFER-...

#### Test 2: Booking Không Tồn Tại ❌

**Các bước:**
1. POST với bookingCode không tồn tại

**Kết quả:**
- ❌ Redirect về checkout với error
- ✅ Hiển thị: "Lỗi: Booking không tồn tại"

#### Test 3: Thanh Toán Nhiều Lần

**Các bước:**
1. Thanh toán lần 1 → PAID
2. Thanh toán lần 2 → PAID (ghi đè)

**Kết quả:**
- ✅ deposit_ref được update với timestamp mới
- ✅ deposit_status vẫn là PAID

## Các Trường Hợp Lỗi Thường Gặp

### Lỗi 1: Column 'deposit_amount' doesn't exist

**Nguyên nhân:** Chưa chạy migration

**Giải pháp:**
```sql
source database/migration_preorder_deposit.sql
```

### Lỗi 2: NullPointerException khi lưu deposit

**Nguyên nhân:** Booking entity chưa có getter/setter cho deposit fields

**Kiểm tra:**
```java
// Trong Booking.java phải có:
public BigDecimal getDepositAmount() { ... }
public void setDepositAmount(BigDecimal depositAmount) { ... }
public String getDepositStatus() { ... }
public void setDepositStatus(String depositStatus) { ... }
public String getDepositRef() { ... }
public void setDepositRef(String depositRef) { ... }
```

### Lỗi 3: Redirect về trang checkout với error

**Nguyên nhân:** Exception trong quá trình lưu

**Debug:**
```java
// Xem log trong console
// Hoặc thêm try-catch để log chi tiết
catch (Exception e) {
    e.printStackTrace();
    System.err.println("Error saving deposit: " + e.getMessage());
}
```

### Lỗi 4: Deposit amount = 0

**Nguyên nhân:** Pre-order items rỗng hoặc giá món = 0

**Kiểm tra:**
```sql
-- Xem pre-order items
SELECT 
    poi.pre_order_item_id,
    p.product_name,
    p.price,
    poi.quantity,
    (p.price * poi.quantity) as subtotal
FROM pre_order_items poi
JOIN products p ON poi.product_id = p.product_id
WHERE poi.booking_id = YOUR_BOOKING_ID;
```

## Workflow Sau Khi Fix

```
1. Customer chọn món → Pre-order items được lưu
2. Customer click "Thanh toán cọc" → Redirect to /pre-order/checkout
3. Trang checkout hiển thị:
   - Danh sách món
   - Tổng tiền
   - Tiền cọc (10%)
   - Phương thức thanh toán
4. Customer chọn phương thức và click "Xác nhận"
5. Controller:
   - Tính deposit = subtotal × 10%
   - Update booking:
     * deposit_amount = calculated amount
     * deposit_status = PAID
     * deposit_ref = method-timestamp
   - Commit transaction
6. Redirect về /pre-order với success message
7. Customer thấy thông báo "Đặt cọc thành công!"
```

## Tích Hợp Với Booking Flow

### Khi Khách Check-In

Staff cần biết booking đã thanh toán cọc:

```sql
-- Xem booking với deposit info
SELECT 
    b.booking_code,
    b.customer_name,
    b.deposit_amount,
    b.deposit_status,
    COUNT(poi.pre_order_item_id) as preorder_count
FROM bookings b
LEFT JOIN pre_order_items poi ON b.booking_id = poi.booking_id
WHERE b.booking_date = CURDATE()
  AND b.status = 'CONFIRMED'
GROUP BY b.booking_id;
```

### Khi Thanh Toán Cuối

Trừ tiền cọc vào hóa đơn:

```java
// Trong payment logic
BigDecimal orderTotal = calculateOrderTotal(order);
BigDecimal depositPaid = booking.getDepositAmount();
BigDecimal amountDue = orderTotal.subtract(depositPaid);

// Hiển thị cho cashier
System.out.println("Tổng hóa đơn: " + orderTotal);
System.out.println("Đã cọc: -" + depositPaid);
System.out.println("Còn phải trả: " + amountDue);
```

## Monitoring

### Dashboard Query

```sql
-- Thống kê deposit hôm nay
SELECT 
    deposit_status,
    COUNT(*) as count,
    SUM(deposit_amount) as total_amount
FROM bookings
WHERE DATE(created_at) = CURDATE()
  AND deposit_amount > 0
GROUP BY deposit_status;
```

### Alert Query

```sql
-- Tìm booking đã thanh toán cọc nhưng chưa check-in
SELECT 
    booking_code,
    customer_name,
    booking_date,
    booking_time,
    deposit_amount,
    TIMESTAMPDIFF(MINUTE, NOW(), CONCAT(booking_date, ' ', booking_time)) as minutes_until
FROM bookings
WHERE deposit_status = 'PAID'
  AND status = 'CONFIRMED'
  AND booking_date = CURDATE()
  AND CONCAT(booking_date, ' ', booking_time) > NOW()
ORDER BY booking_time;
```

## Hoàn Thành

Sau khi thực hiện các bước trên, tính năng thanh toán cọc sẽ hoạt động đầy đủ:
- ✅ Lưu deposit vào database
- ✅ Hiển thị thông báo thành công
- ✅ Có thể tra cứu deposit status
- ✅ Tích hợp với booking workflow
- ✅ Sẵn sàng cho payment flow cuối
