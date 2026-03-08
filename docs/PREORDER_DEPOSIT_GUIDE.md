# Hướng Dẫn Đặt Món Trước & Chính Sách Cọc

## Tổng Quan

Hệ thống cho phép khách đặt món trước (pre-order) khi tạo booking, kèm theo chính sách cọc 10% để đảm bảo cam kết. Điều này giúp nhà hàng chuẩn bị nguyên liệu tốt hơn và giảm thời gian chờ cho khách.

## Quy Trình Pre-Order

### 1. Điều Kiện Đặt Món Trước

Khách chỉ được phép đặt món trước khi:
- Booking có status = `PENDING` hoặc `CONFIRMED`
- Chưa quá thời gian cutoff (60 phút trước giờ đặt bàn)

### 2. Thêm Món Vào Pre-Order

```java
preOrderService.addPreOrderItem(bookingId, productId, quantity, note);
```

**Kiểm tra tự động:**
- ✅ Món còn hàng (quantity > 0)
- ✅ Món đang AVAILABLE
- ✅ Chưa quá cutoff time
- ✅ Booking ở trạng thái hợp lệ

**Nếu món đã có trong pre-order:**
- Tự động cộng dồn số lượng
- Cập nhật note nếu có

### 3. Tính Tiền Cọc

**Công thức:**
```
Tổng tiền pre-order = Σ (Giá món × Số lượng)
Tiền cọc = Tổng tiền × 10%
```

**Ví dụ:**
```
Món A: 100,000đ × 2 = 200,000đ
Món B: 150,000đ × 1 = 150,000đ
Tổng: 350,000đ
Cọc: 35,000đ (10%)
```

**Tự động cập nhật:**
- Mỗi khi thêm/sửa/xóa món
- Hệ thống tự động tính lại tổng tiền và tiền cọc

### 4. Thanh Toán Tiền Cọc

```java
preOrderService.markDepositPaid(bookingId, paymentRef);
```

**Trạng thái deposit:**
- `PENDING` - Chưa thanh toán
- `PAID` - Đã thanh toán
- `REFUNDED` - Đã hoàn trả
- `FORFEITED` - Bị tịch thu (hủy sau cutoff)

### 5. Cutoff Time - Khóa Pre-Order

**Thời điểm khóa:** 60 phút trước giờ đặt bàn

**Ví dụ:**
```
Booking: 18:00
Cutoff: 17:00 (60 phút trước)
```

**Sau cutoff:**
- ❌ Không thể thêm món
- ❌ Không thể sửa số lượng
- ❌ Không thể xóa món
- ✅ Chỉ xem được danh sách

**Tự động khóa bởi Scheduler:**
```java
// Chạy mỗi 5 phút
preOrderService.lockPreOrder(bookingId);
```

## Quản Lý Món Hết Hàng

### Tự Động Loại Bỏ

Scheduler chạy mỗi 5 phút để kiểm tra:

```java
preOrderService.cleanupUnavailableItems(bookingId);
```

**Loại bỏ món khi:**
- Status = `UNAVAILABLE`
- Quantity < số lượng đặt
- Món bị xóa khỏi menu

**Sau khi loại bỏ:**
- Tự động tính lại tổng tiền
- Tự động tính lại tiền cọc
- Thông báo cho khách (nếu có)

### Ví Dụ

```
Pre-order ban đầu:
- Món A: 100,000đ × 2 = 200,000đ
- Món B: 150,000đ × 1 = 150,000đ
Tổng: 350,000đ, Cọc: 35,000đ

Món B hết hàng → Tự động loại bỏ

Pre-order sau khi cleanup:
- Món A: 100,000đ × 2 = 200,000đ
Tổng: 200,000đ, Cọc: 20,000đ
```

## Chính Sách Hoàn Cọc

### Hủy Trước Cutoff ✅

**Điều kiện:**
- Hủy trước 60 phút
- Deposit status = `PAID`

**Kết quả:**
- Hoàn 100% tiền cọc
- Deposit status → `REFUNDED`

```java
// Tự động kiểm tra trong cancel()
bookingService.cancel(bookingId, "Khách có việc đột xuất");
// → Deposit REFUNDED nếu trước cutoff
```

### Hủy Sau Cutoff ❌

**Điều kiện:**
- Hủy sau 60 phút trước giờ đặt
- Deposit status = `PAID`

**Kết quả:**
- Tiền cọc bị giữ lại
- Deposit status → `FORFEITED`

```java
bookingService.cancel(bookingId, "Hủy muộn");
// → Deposit FORFEITED (không hoàn)
```

### No-Show ❌

**Khi khách không đến:**
- Tiền cọc bị giữ lại
- Deposit status → `FORFEITED`

```java
bookingService.markNoShow(bookingId);
// → Deposit FORFEITED
```

## Chuyển Pre-Order Thành Order

### Khi Khách Check-In

**Quy trình:**
1. Staff check-in booking
2. Tạo Order cho bàn
3. Chuyển tất cả pre-order items → order items
4. Bắt đầu phục vụ

**Code mẫu:**
```java
// 1. Check-in
bookingService.checkIn(bookingId);

// 2. Tạo order từ pre-order
Order order = new Order();
order.setTable(booking.getTable());
order.setStatus("PENDING");

// 3. Chuyển pre-order items
for (PreOrderItem preItem : booking.getPreOrderItems()) {
    OrderDetail detail = new OrderDetail();
    detail.setOrder(order);
    detail.setProduct(preItem.getProduct());
    detail.setQuantity(preItem.getQuantity());
    detail.setNote(preItem.getNote());
    detail.setPrice(preItem.getProduct().getPrice());
    order.getOrderDetails().add(detail);
}

orderService.save(order);
```

### Thanh Toán Cuối

**Tính toán:**
```
Tổng hóa đơn = Tổng order items
Tiền cọc đã trả = booking.depositAmount
Còn phải trả = Tổng hóa đơn - Tiền cọc
```

**Ví dụ:**
```
Pre-order: 350,000đ (đã cọc 35,000đ)
Gọi thêm tại bàn: 200,000đ
Tổng hóa đơn: 550,000đ
Đã cọc: -35,000đ
Còn phải trả: 515,000đ
```

## API Endpoints

### Customer Pre-Order

```
GET /customer/preorder?bookingCode=BK12345678
- Xem pre-order và menu
- Params: bookingCode

POST /customer/preorder/add
- Thêm món vào pre-order
- Params: bookingId, productId, quantity, note

POST /customer/preorder/update
- Cập nhật số lượng món
- Params: itemId, quantity

POST /customer/preorder/remove
- Xóa món khỏi pre-order
- Params: itemId

POST /customer/preorder/pay-deposit
- Xác nhận thanh toán cọc
- Params: bookingId, paymentRef
```

### Staff Management

```
GET /staff/bookings/{id}/preorder
- Xem pre-order của booking

POST /staff/preorder/lock
- Khóa pre-order thủ công
- Params: bookingId

POST /staff/preorder/cleanup
- Loại bỏ món hết hàng thủ công
- Params: bookingId
```

## Workflow Hoàn Chỉnh

### Scenario 1: Pre-Order Thành Công

```
1. [Customer] Tạo booking lúc 18:00
   → Status: PENDING

2. [Customer] Thêm món vào pre-order
   - Món A: 100,000đ × 2
   - Món B: 150,000đ × 1
   → Tổng: 350,000đ, Cọc: 35,000đ

3. [Customer] Thanh toán cọc 35,000đ
   → Deposit status: PAID

4. [Staff] Xác nhận booking
   → Status: CONFIRMED

5. [Scheduler] 16:55 - Tự động cleanup
   → Kiểm tra món còn hàng

6. [Scheduler] 17:00 - Tự động lock pre-order
   → preorder_locked_at = 17:00

7. [Customer] 18:00 - Đến nhà hàng
   → Staff check-in, tạo Order

8. [Staff] Chuyển pre-order → order items
   → Bắt đầu phục vụ

9. [Customer] 19:30 - Thanh toán
   → Tổng: 550,000đ
   → Trừ cọc: -35,000đ
   → Còn: 515,000đ
```

### Scenario 2: Hủy Trước Cutoff

```
1-3. Giống scenario 1

4. [Customer] 16:00 - Hủy booking (1 giờ trước cutoff)
   → Booking: CANCELLED
   → Deposit: REFUNDED
   → Hoàn 100% tiền cọc
```

### Scenario 3: Hủy Sau Cutoff

```
1-6. Giống scenario 1

7. [Customer] 17:30 - Hủy booking (30 phút sau cutoff)
   → Booking: CANCELLED
   → Deposit: FORFEITED
   → Tiền cọc bị giữ lại
```

### Scenario 4: Món Hết Hàng

```
1-3. Giống scenario 1

4. [Scheduler] 16:55 - Món B hết hàng
   → Tự động loại Món B khỏi pre-order
   → Tổng mới: 200,000đ
   → Cọc mới: 20,000đ

5. [System] Thông báo khách về thay đổi
   → Email/SMS: "Món B không còn, cọc giảm xuống 20,000đ"
```

## Kiểm Tra Bằng SQL

### 1. Xem pre-order của booking

```sql
SELECT 
    b.booking_code,
    b.deposit_amount,
    b.deposit_status,
    b.preorder_locked_at,
    p.product_name,
    poi.quantity,
    p.price,
    (poi.quantity * p.price) as subtotal
FROM bookings b
JOIN pre_order_items poi ON b.booking_id = poi.booking_id
JOIN products p ON poi.product_id = p.product_id
WHERE b.booking_code = 'BK12345678';
```

### 2. Tính tổng pre-order

```sql
SELECT 
    b.booking_code,
    SUM(poi.quantity * p.price) as total_preorder,
    b.deposit_amount,
    b.deposit_status
FROM bookings b
JOIN pre_order_items poi ON b.booking_id = poi.booking_id
JOIN products p ON poi.product_id = p.product_id
WHERE b.booking_code = 'BK12345678'
GROUP BY b.booking_id;
```

### 3. Tìm booking cần lock pre-order

```sql
SELECT 
    booking_code,
    booking_date,
    booking_time,
    CONCAT(booking_date, ' ', booking_time) as booking_datetime,
    DATE_SUB(CONCAT(booking_date, ' ', booking_time), INTERVAL 60 MINUTE) as cutoff_time,
    NOW() as current_time
FROM bookings
WHERE status IN ('PENDING', 'CONFIRMED')
  AND preorder_locked_at IS NULL
  AND DATE_SUB(CONCAT(booking_date, ' ', booking_time), INTERVAL 60 MINUTE) <= NOW();
```

### 4. Thống kê deposit

```sql
SELECT 
    deposit_status,
    COUNT(*) as count,
    SUM(deposit_amount) as total_amount
FROM bookings
WHERE deposit_amount > 0
GROUP BY deposit_status;
```

## Cấu Hình

### Thay Đổi Tỷ Lệ Cọc

Mặc định: 10%

Để thay đổi, sửa trong `PreOrderService.java`:

```java
private static final BigDecimal DEPOSIT_RATE = new BigDecimal("0.15"); // 15%
```

### Thay Đổi Cutoff Time

Mặc định: 60 phút

Để thay đổi, sửa trong `PreOrderService.java`:

```java
private static final int CUTOFF_MINUTES = 90; // 90 phút
```

## Best Practices

1. **Luôn kiểm tra cutoff** trước khi cho phép sửa pre-order
2. **Tự động cleanup** món hết hàng để tránh nhầm lẫn
3. **Thông báo khách** khi có thay đổi về món hoặc tiền cọc
4. **Ghi log** tất cả thay đổi về deposit (PAID, REFUNDED, FORFEITED)
5. **Backup pre-order** trước khi chuyển sang order
6. **Kiểm tra inventory** trước khi lock pre-order
7. **Email xác nhận** sau khi thanh toán cọc

## Xử Lý Lỗi Thường Gặp

### "Đã quá thời gian cho phép đặt món trước"
- Nguyên nhân: Đã quá cutoff (60 phút trước)
- Giải pháp: Khách gọi món trực tiếp tại bàn

### "Món không có sẵn"
- Nguyên nhân: Status = UNAVAILABLE hoặc quantity = 0
- Giải pháp: Chọn món khác hoặc đợi nhập hàng

### "Không thể hoàn cọc"
- Nguyên nhân: Hủy sau cutoff
- Giải pháp: Giải thích chính sách cho khách

### "Pre-order bị khóa"
- Nguyên nhân: Đã đến cutoff time
- Giải pháp: Khách gọi thêm tại bàn
