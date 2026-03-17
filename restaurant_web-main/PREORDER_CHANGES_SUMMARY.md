# Tóm tắt Thay đổi: Tích hợp Pre-order vào Order

## Files đã thay đổi

### 1. Entity Layer
- ✅ `src/main/java/market/restaurant_web/entity/Order.java`
  - Thêm trường `booking` (@ManyToOne)
  - Thêm getter/setter cho booking

### 2. DAO Layer
- ✅ `src/main/java/market/restaurant_web/dao/BookingDao.java`
  - Thêm method `findActiveBookingByTable(Session s, int tableId)`

### 3. Service Layer
- ✅ `src/main/java/market/restaurant_web/service/BookingService.java`
  - Thêm method `findActiveBookingByTable(int tableId)`

- ✅ `src/main/java/market/restaurant_web/service/OrderService.java`
  - Cập nhật `createOrder()`: Tự động tìm booking, copy pre-order items

### 4. Controller Layer
- ✅ `src/main/java/market/restaurant_web/controller/cashier/CheckoutController.java`
  - Cập nhật `doGet()`: Tính depositAmount và finalAmountToPay
  - Truyền các giá trị xuống JSP

### 5. View Layer
- ✅ `src/main/webapp/WEB-INF/views/cashier/checkout.jsp`
  - Hiển thị dòng "Tiền đã cọc" (nếu có)
  - Đổi "Tổng cộng" thành "Cần thanh toán"
  - Cập nhật QR Code SePay sử dụng finalAmountToPay

### 6. Database
- ✅ `database/migration_add_booking_to_order.sql`
  - Thêm cột `booking_id` vào bảng `orders`
  - Thêm foreign key constraint
  - Thêm index

### 7. Documentation
- ✅ `PREORDER_INTEGRATION_GUIDE.md` - Hướng dẫn chi tiết
- ✅ `PREORDER_CHANGES_SUMMARY.md` - File này

## Các bước triển khai

### Bước 1: Chạy Database Migration
```bash
psql -U [username] -d [database_name] -f database/migration_add_booking_to_order.sql
```

### Bước 2: Build và Deploy
```bash
mvn clean package
# Deploy WAR file to Tomcat/Server
```

### Bước 3: Test
1. Tạo booking có pre-order và thanh toán cọc
2. Check-in và assign table
3. Tạo order cho bàn → Verify món pre-order tự động thêm vào
4. Thanh toán → Verify tiền cọc được trừ

## Tính năng mới

✨ **Tự động copy Pre-order items**: Khi tạo Order cho bàn có Booking, các món Pre-order tự động được thêm vào Order

✨ **Hiển thị tiền cọc**: Màn hình thanh toán hiển thị rõ số tiền đã cọc và số tiền còn phải trả

✨ **Trừ tiền cọc tự động**: Số tiền cần thanh toán = Tổng bill - Tiền cọc

✨ **QR Code chính xác**: Mã QR thanh toán hiển thị đúng số tiền sau khi trừ cọc

## Kiểm tra nhanh

```sql
-- Kiểm tra cột booking_id đã được thêm
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'orders' AND column_name = 'booking_id';

-- Kiểm tra foreign key
SELECT constraint_name, table_name, column_name 
FROM information_schema.key_column_usage 
WHERE constraint_name = 'fk_orders_booking';
```

## Liên hệ
Nếu có vấn đề, vui lòng tham khảo file `PREORDER_INTEGRATION_GUIDE.md` để biết chi tiết.
