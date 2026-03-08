# Test Cases - Pre-Order & Deposit

## Chuẩn Bị

### 1. Chạy Migration
```sql
source database/migration_preorder_deposit.sql
```

### 2. Tạo Dữ Liệu Test

```sql
-- Tạo món ăn test
INSERT INTO products (category_id, product_name, price, cost_price, quantity, status)
VALUES 
(1, 'Phở Bò', 50000, 30000, 100, 'AVAILABLE'),
(1, 'Bún Chả', 45000, 25000, 50, 'AVAILABLE'),
(1, 'Cơm Tấm', 40000, 20000, 10, 'AVAILABLE'),
(1, 'Bánh Mì', 25000, 15000, 0, 'UNAVAILABLE');

-- Tạo booking test
INSERT INTO bookings (booking_code, customer_name, customer_phone, booking_date, booking_time, party_size, status)
VALUES ('BK-TEST001', 'Nguyễn Văn A', '0901234567', CURDATE(), '18:00:00', 4, 'PENDING');
```

---

## Test Cases

### Test 1: Thêm Món Vào Pre-Order ✅

**Mục đích**: Kiểm tra thêm món cơ bản

**Điều kiện**:
- Booking status = PENDING
- Món AVAILABLE và còn hàng
- Chưa quá cutoff

**Các bước**:
1. Truy cập `/customer/preorder?bookingCode=BK-TEST001`
2. Chọn "Phở Bò", số lượng: 2
3. Click "Thêm vào đơn"

**Kết quả mong đợi**:
- ✅ Món được thêm vào pre_order_items
- ✅ Tổng tiền = 100,000đ (50,000 × 2)
- ✅ Tiền cọc = 10,000đ (10%)
- ✅ Deposit status = PENDING

**Kiểm tra DB**:
```sql
SELECT 
    b.booking_code,
    p.product_name,
    poi.quantity,
    p.price,
    b.deposit_amount,
    b.deposit_status
FROM bookings b
JOIN pre_order_items poi ON b.booking_id = poi.booking_id
JOIN products p ON poi.product_id = p.product_id
WHERE b.booking_code = 'BK-TEST001';
```

---

### Test 2: Thêm Nhiều Món ✅

**Các bước**:
1. Thêm "Phở Bò" × 2 = 100,000đ
2. Thêm "Bún Chả" × 1 = 45,000đ
3. Thêm "Cơm Tấm" × 3 = 120,000đ

**Kết quả mong đợi**:
- ✅ Tổng = 265,000đ
- ✅ Cọc = 26,500đ (10%)
- ✅ 3 món trong pre_order_items

---

### Test 3: Thêm Món Trùng - Cộng Dồn Số Lượng ✅

**Các bước**:
1. Thêm "Phở Bò" × 2
2. Thêm "Phở Bò" × 1 (lần 2)

**Kết quả mong đợi**:
- ✅ Chỉ có 1 record trong pre_order_items
- ✅ Quantity = 3 (2 + 1)
- ✅ Tổng = 150,000đ (50,000 × 3)
- ✅ Cọc = 15,000đ

---

### Test 4: Thêm Món Hết Hàng ❌

**Điều kiện**: Món "Bánh Mì" có status = UNAVAILABLE

**Các bước**:
1. Thử thêm "Bánh Mì" × 1

**Kết quả mong đợi**:
- ❌ Hiển thị lỗi: "Món 'Bánh Mì' hiện không có sẵn"
- ✅ Món không được thêm vào pre-order
- ✅ Tiền cọc không thay đổi

---

### Test 5: Thêm Món Vượt Quá Số Lượng Tồn ❌

**Điều kiện**: "Cơm Tấm" chỉ còn 10 phần

**Các bước**:
1. Thử thêm "Cơm Tấm" × 15

**Kết quả mong đợi**:
- ❌ Lỗi: "Món 'Cơm Tấm' không đủ số lượng (còn: 10)"
- ✅ Món không được thêm

---

### Test 6: Cập Nhật Số Lượng ✅

**Điều kiện**: Đã có "Phở Bò" × 2 trong pre-order

**Các bước**:
1. Tìm item_id của "Phở Bò"
2. Cập nhật quantity = 5

**Kết quả mong đợi**:
- ✅ Quantity thay đổi từ 2 → 5
- ✅ Tổng tiền cập nhật: 250,000đ
- ✅ Cọc cập nhật: 25,000đ

**API Call**:
```bash
curl -X POST http://localhost:8080/customer/preorder/update \
  -d "itemId=1&quantity=5&bookingCode=BK-TEST001"
```

---

### Test 7: Xóa Món Khỏi Pre-Order ✅

**Các bước**:
1. Xóa "Bún Chả" khỏi pre-order

**Kết quả mong đợi**:
- ✅ Món bị xóa khỏi pre_order_items
- ✅ Tổng tiền giảm
- ✅ Cọc tự động tính lại

---

### Test 8: Thanh Toán Tiền Cọc ✅

**Điều kiện**: Pre-order có tổng 265,000đ, cọc 26,500đ

**Các bước**:
1. Click "Thanh toán cọc"
2. Nhập payment reference: "PAY-123456"
3. Xác nhận

**Kết quả mong đợi**:
- ✅ Deposit status: PENDING → PAID
- ✅ Deposit ref = "PAY-123456"
- ✅ Hiển thị "Đã thanh toán cọc"

**Kiểm tra DB**:
```sql
SELECT booking_code, deposit_amount, deposit_status, deposit_ref
FROM bookings
WHERE booking_code = 'BK-TEST001';
```

---

### Test 9: Cutoff Time - Khóa Pre-Order ⏰

**Điều kiện**: 
- Booking lúc 18:00
- Hiện tại là 17:00 (60 phút trước)

**Test thủ công**:
```java
PreOrderService service = new PreOrderService();
service.lockPreOrder(bookingId);
```

**Kết quả mong đợi**:
- ✅ preorder_locked_at = current timestamp
- ❌ Không thể thêm món mới
- ❌ Không thể sửa số lượng
- ❌ Không thể xóa món

**Kiểm tra**:
```sql
SELECT booking_code, preorder_locked_at, 
       TIMESTAMPDIFF(MINUTE, preorder_locked_at, CONCAT(booking_date, ' ', booking_time)) as minutes_before
FROM bookings
WHERE booking_code = 'BK-TEST001';
```

---

### Test 10: Thêm Món Sau Cutoff ❌

**Điều kiện**: Pre-order đã bị khóa

**Các bước**:
1. Thử thêm "Phở Bò" × 1

**Kết quả mong đợi**:
- ❌ Lỗi: "Đã quá thời gian cho phép đặt món trước (cutoff: 60 phút trước giờ đặt bàn)"
- ✅ Món không được thêm

---

### Test 11: Auto Cleanup - Món Hết Hàng 🔄

**Điều kiện**:
- Pre-order có "Cơm Tấm" × 3
- Admin đổi "Cơm Tấm" status → UNAVAILABLE

**Trigger cleanup**:
```java
PreOrderService service = new PreOrderService();
service.cleanupUnavailableItems(bookingId);
```

**Kết quả mong đợi**:
- ✅ "Cơm Tấm" bị xóa khỏi pre-order
- ✅ Tổng tiền giảm 120,000đ
- ✅ Cọc tự động tính lại
- ✅ Log: "Removed unavailable item: Cơm Tấm"

**Kiểm tra**:
```sql
-- Không còn Cơm Tấm
SELECT * FROM pre_order_items poi
JOIN products p ON poi.product_id = p.product_id
WHERE poi.booking_id = 1 AND p.product_name = 'Cơm Tấm';
-- Kết quả: 0 rows
```

---

### Test 12: Hủy Booking Trước Cutoff - Hoàn Cọc ✅

**Điều kiện**:
- Booking lúc 18:00
- Đã thanh toán cọc 26,500đ
- Hiện tại là 16:00 (2 giờ trước cutoff)

**Các bước**:
1. Hủy booking với lý do: "Khách có việc đột xuất"

**Kết quả mong đợi**:
- ✅ Booking status → CANCELLED
- ✅ Deposit status → REFUNDED
- ✅ Bàn được giải phóng (nếu đã gán)
- ✅ Log: "Deposit refunded for booking: BK-TEST001"

**Kiểm tra**:
```sql
SELECT booking_code, status, deposit_status, cancel_reason
FROM bookings
WHERE booking_code = 'BK-TEST001';
-- status=CANCELLED, deposit_status=REFUNDED
```

---

### Test 13: Hủy Booking Sau Cutoff - Giữ Cọc ❌

**Điều kiện**:
- Booking lúc 18:00
- Đã thanh toán cọc 26,500đ
- Hiện tại là 17:30 (30 phút sau cutoff)

**Các bước**:
1. Hủy booking

**Kết quả mong đợi**:
- ✅ Booking status → CANCELLED
- ✅ Deposit status → FORFEITED (bị tịch thu)
- ✅ Log: "Deposit forfeited (cancelled after cutoff)"

**Kiểm tra**:
```sql
SELECT booking_code, status, deposit_status
FROM bookings
WHERE booking_code = 'BK-TEST001';
-- status=CANCELLED, deposit_status=FORFEITED
```

---

### Test 14: Scheduler - Auto Lock Pre-Order ⏰

**Mục đích**: Kiểm tra scheduler tự động khóa pre-order

**Chuẩn bị**:
```sql
-- Tạo booking 65 phút sau (sẽ bị lock trong 5 phút)
INSERT INTO bookings (booking_code, customer_name, customer_phone, booking_date, booking_time, party_size, status)
VALUES ('BK-AUTOLOCK', 'Test User', '0900000000', CURDATE(), ADDTIME(CURTIME(), '01:05:00'), 2, 'CONFIRMED');
```

**Đợi scheduler chạy** (mỗi 5 phút)

**Kết quả mong đợi**:
- ✅ Sau 5-10 phút, booking bị lock
- ✅ preorder_locked_at != NULL
- ✅ Log: "Locked pre-order for booking: BK-AUTOLOCK"

---

### Test 15: Chuyển Pre-Order Thành Order 🔄

**Điều kiện**:
- Booking đã CONFIRMED
- Pre-order có 3 món
- Khách đã đến nhà hàng

**Các bước**:
1. Staff check-in booking
2. Tạo Order từ pre-order items
3. Chuyển tất cả món sang order_details

**Code mẫu**:
```java
// Check-in
bookingService.checkIn(bookingId);

// Tạo order
Order order = new Order();
order.setTable(booking.getTable());
order.setStatus("PENDING");

// Chuyển items
for (PreOrderItem preItem : booking.getPreOrderItems()) {
    OrderDetail detail = new OrderDetail();
    detail.setOrder(order);
    detail.setProduct(preItem.getProduct());
    detail.setQuantity(preItem.getQuantity());
    detail.setPrice(preItem.getProduct().getPrice());
    order.getOrderDetails().add(detail);
}

orderService.save(order);
```

**Kết quả mong đợi**:
- ✅ Order được tạo với status = PENDING
- ✅ Tất cả pre-order items → order_details
- ✅ Giá món được copy từ pre-order
- ✅ Booking status → SEATED

---

### Test 16: Thanh Toán Cuối - Trừ Cọc 💰

**Điều kiện**:
- Pre-order: 265,000đ (đã cọc 26,500đ)
- Gọi thêm tại bàn: 150,000đ
- Tổng hóa đơn: 415,000đ

**Tính toán**:
```
Tổng order: 415,000đ
Tiền cọc: -26,500đ
Còn phải trả: 388,500đ
```

**Kiểm tra**:
```sql
SELECT 
    b.booking_code,
    b.deposit_amount as deposit_paid,
    SUM(od.quantity * od.price) as order_total,
    (SUM(od.quantity * od.price) - b.deposit_amount) as amount_due
FROM bookings b
JOIN orders o ON o.table_id = b.table_id
JOIN order_details od ON od.order_id = o.order_id
WHERE b.booking_code = 'BK-TEST001'
GROUP BY b.booking_id;
```

---

## Workflow Test Hoàn Chỉnh

### Scenario: Pre-Order Thành Công

```
1. [Customer] 10:00 - Tạo booking lúc 18:00
   → Status: PENDING

2. [Customer] 10:05 - Thêm món vào pre-order
   - Phở Bò × 2 = 100,000đ
   - Bún Chả × 1 = 45,000đ
   → Tổng: 145,000đ, Cọc: 14,500đ

3. [Customer] 10:10 - Thanh toán cọc
   → Deposit: PAID

4. [Staff] 11:00 - Xác nhận booking
   → Status: CONFIRMED

5. [Scheduler] 16:55 - Auto cleanup
   → Kiểm tra món còn hàng ✅

6. [Scheduler] 17:00 - Auto lock pre-order
   → preorder_locked_at = 17:00

7. [Customer] 17:30 - Thử thêm món
   → ❌ Lỗi: "Đã quá cutoff"

8. [Customer] 18:00 - Đến nhà hàng
   → Staff check-in

9. [Staff] Tạo Order từ pre-order
   → Chuyển 2 món sang order_details

10. [Customer] Gọi thêm: Cơm Tấm × 1 = 40,000đ
    → Tổng order: 185,000đ

11. [Customer] 19:30 - Thanh toán
    → Tổng: 185,000đ
    → Trừ cọc: -14,500đ
    → Còn: 170,500đ
```

---

## SQL Queries Hữu Ích

### Xem tất cả pre-orders hôm nay
```sql
SELECT 
    b.booking_code,
    b.customer_name,
    b.booking_time,
    COUNT(poi.pre_order_item_id) as item_count,
    SUM(poi.quantity * p.price) as total,
    b.deposit_amount,
    b.deposit_status,
    b.preorder_locked_at
FROM bookings b
LEFT JOIN pre_order_items poi ON b.booking_id = poi.booking_id
LEFT JOIN products p ON poi.product_id = p.product_id
WHERE b.booking_date = CURDATE()
GROUP BY b.booking_id;
```

### Tìm pre-orders cần lock
```sql
SELECT 
    booking_code,
    booking_time,
    DATE_SUB(CONCAT(booking_date, ' ', booking_time), INTERVAL 60 MINUTE) as cutoff_time,
    NOW() as current_time
FROM bookings
WHERE status IN ('PENDING', 'CONFIRMED')
  AND preorder_locked_at IS NULL
  AND DATE_SUB(CONCAT(booking_date, ' ', booking_time), INTERVAL 60 MINUTE) <= NOW();
```

### Thống kê deposit
```sql
SELECT 
    DATE(created_at) as date,
    deposit_status,
    COUNT(*) as count,
    SUM(deposit_amount) as total
FROM bookings
WHERE deposit_amount > 0
GROUP BY DATE(created_at), deposit_status
ORDER BY date DESC;
```

---

## Checklist

### Pre-Order
- [ ] Thêm món thành công
- [ ] Thêm món trùng → cộng dồn
- [ ] Không thêm được món hết hàng
- [ ] Không thêm được món vượt tồn kho
- [ ] Cập nhật số lượng
- [ ] Xóa món
- [ ] Tính tiền cọc đúng (10%)

### Cutoff & Lock
- [ ] Tự động lock sau 60 phút
- [ ] Không thêm/sửa/xóa sau lock
- [ ] Scheduler chạy đúng

### Deposit
- [ ] Thanh toán cọc thành công
- [ ] Hoàn cọc khi hủy trước cutoff
- [ ] Giữ cọc khi hủy sau cutoff
- [ ] Trừ cọc vào hóa đơn cuối

### Cleanup
- [ ] Tự động xóa món hết hàng
- [ ] Tính lại tiền cọc sau cleanup
- [ ] Log đúng

### Integration
- [ ] Chuyển pre-order → order
- [ ] Thanh toán cuối trừ cọc
- [ ] Booking workflow hoàn chỉnh
