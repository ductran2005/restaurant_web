# Hướng Dẫn Kiểm Tra Nghiệp Vụ Booking

## Chuẩn Bị Dữ Liệu Test

### 1. Tạo Bàn Test
Đảm bảo có các bàn với capacity khác nhau:

```sql
-- Bàn 2 chỗ
INSERT INTO tables (area_id, table_name, capacity, status) 
VALUES (1, 'T01', 2, 'EMPTY');

-- Bàn 4 chỗ
INSERT INTO tables (area_id, table_name, capacity, status) 
VALUES (1, 'T02', 4, 'EMPTY');

-- Bàn 6 chỗ
INSERT INTO tables (area_id, table_name, capacity, status) 
VALUES (1, 'T03', 6, 'EMPTY');

-- Bàn 8 chỗ
INSERT INTO tables (area_id, table_name, capacity, status) 
VALUES (1, 'T04', 8, 'EMPTY');
```

## Test Cases

### Test 1: Tạo Booking Mới ✅

**Mục đích**: Kiểm tra tạo booking cơ bản

**Các bước**:
1. Truy cập trang đặt bàn (customer hoặc staff)
2. Nhập thông tin:
   - Tên: "Nguyễn Văn A"
   - SĐT: "0901234567"
   - Ngày: Hôm nay
   - Giờ: 18:00
   - Số khách: 4
3. Submit form

**Kết quả mong đợi**:
- ✅ Booking được tạo với status = PENDING
- ✅ Có mã booking (VD: BK12345678)
- ✅ Hiển thị thông báo thành công

**Kiểm tra DB**:
```sql
SELECT booking_code, customer_name, party_size, status, table_id 
FROM bookings 
WHERE customer_phone = '0901234567';
```

---

### Test 2: Gán Bàn Tự Động - Capacity Phù Hợp ✅

**Mục đích**: Kiểm tra hệ thống chọn bàn có capacity gần nhất

**Điều kiện**: 
- Có booking 4 khách
- Có bàn: 2 chỗ, 4 chỗ, 6 chỗ, 8 chỗ (tất cả EMPTY)

**Các bước**:
1. Vào `/staff/bookings`
2. Tìm booking vừa tạo
3. Click "Xác nhận" → status = CONFIRMED
4. Click "Gán bàn tự động"

**Kết quả mong đợi**:
- ✅ Hệ thống chọn bàn 4 chỗ (không phải 6 hay 8)
- ✅ Booking.table_id = ID của bàn 4 chỗ
- ✅ Bàn 4 chỗ có status = RESERVED
- ✅ Thông báo "Tự động gán bàn thành công!"

**Kiểm tra DB**:
```sql
-- Kiểm tra booking đã gán bàn
SELECT b.booking_code, b.party_size, t.table_name, t.capacity, t.status
FROM bookings b
JOIN tables t ON b.table_id = t.table_id
WHERE b.booking_code = 'BK12345678';

-- Kết quả: party_size=4, capacity=4, status=RESERVED
```

---

### Test 3: Gán Bàn Tự Động - Không Đủ Capacity ❌

**Mục đích**: Kiểm tra validation capacity

**Điều kiện**:
- Tạo booking 10 khách
- Bàn lớn nhất chỉ có 8 chỗ

**Các bước**:
1. Tạo booking với party_size = 10
2. Xác nhận booking
3. Click "Gán bàn tự động"

**Kết quả mong đợi**:
- ❌ Hiển thị lỗi: "Không tìm thấy bàn phù hợp cho 10 khách"
- ✅ Booking vẫn CONFIRMED nhưng chưa có table_id
- ✅ Không có bàn nào bị đổi status

---

### Test 4: Kiểm Tra Trùng Thời Gian ❌

**Mục đích**: Đảm bảo một bàn không bị gán 2 booking trùng giờ

**Các bước**:
1. Tạo Booking A:
   - Ngày: Hôm nay
   - Giờ: 18:00
   - Số khách: 4
2. Xác nhận và gán bàn T02 (4 chỗ)
3. Tạo Booking B:
   - Ngày: Hôm nay (cùng ngày)
   - Giờ: 19:00 (trong khoảng 18:00-20:00)
   - Số khách: 4
4. Thử gán thủ công bàn T02 cho Booking B

**Kết quả mong đợi**:
- ❌ Hiển thị lỗi: "Bàn T02 đã có booking trùng thời gian"
- ✅ Booking B không được gán bàn T02
- ✅ Nếu dùng auto-assign, hệ thống sẽ chọn bàn khác (T03 hoặc T04)

**Kiểm tra thời gian overlap**:
```
Booking A: 18:00 - 20:00 (2 giờ)
Booking B: 19:00 - 21:00 (2 giờ)
→ TRÙNG ❌

Booking A: 18:00 - 20:00
Booking C: 20:00 - 22:00
→ OK ✅ (không overlap)
```

---

### Test 5: Trùng Thời Gian - Auto Assign Chọn Bàn Khác ✅

**Mục đích**: Kiểm tra auto-assign tránh bàn bị trùng

**Các bước**:
1. Booking A: 18:00, 4 khách → Gán bàn T02
2. Booking B: 19:00, 4 khách → Click "Gán bàn tự động"

**Kết quả mong đợi**:
- ✅ Hệ thống bỏ qua bàn T02 (đã có booking)
- ✅ Chọn bàn T03 (6 chỗ) - capacity gần nhất còn trống
- ✅ Booking B được gán bàn T03
- ✅ Bàn T03 status = RESERVED

---

### Test 6: Khách Đến - Seat Customer ✅

**Mục đích**: Kiểm tra chuyển trạng thái khi khách ngồi vào bàn

**Điều kiện**: Booking đã CONFIRMED và có table_id

**Các bước**:
1. Vào `/staff/bookings`
2. Tìm booking đã gán bàn
3. Click "Khách đã đến" hoặc "Seat"

**Kết quả mong đợi**:
- ✅ Booking status: CONFIRMED → SEATED
- ✅ Table status: RESERVED → OCCUPIED
- ✅ Có thể tạo Order để phục vụ

**Kiểm tra DB**:
```sql
SELECT b.booking_code, b.status, t.table_name, t.status
FROM bookings b
JOIN tables t ON b.table_id = t.table_id
WHERE b.booking_code = 'BK12345678';

-- Kết quả: b.status=SEATED, t.status=OCCUPIED
```

---

### Test 7: No-Show - Giải Phóng Bàn ✅

**Mục đích**: Kiểm tra xử lý khách không đến

**Điều kiện**: Booking CONFIRMED, đã gán bàn, quá giờ 30 phút

**Các bước**:
1. Tạo booking giờ 18:00
2. Gán bàn → status RESERVED
3. Đợi đến 18:30 (hoặc test thủ công)
4. Click "No-Show"

**Kết quả mong đợi**:
- ✅ Booking status: CONFIRMED → NO_SHOW
- ✅ Table status: RESERVED → EMPTY
- ✅ Bàn sẵn sàng cho booking khác

**Kiểm tra DB**:
```sql
SELECT b.booking_code, b.status, t.table_name, t.status
FROM bookings b
LEFT JOIN tables t ON b.table_id = t.table_id
WHERE b.booking_code = 'BK12345678';

-- Kết quả: b.status=NO_SHOW, t.status=EMPTY
```

---

### Test 8: Hủy Booking - Giải Phóng Bàn ✅

**Mục đích**: Kiểm tra hủy booking và giải phóng bàn

**Các bước**:
1. Tạo booking và gán bàn
2. Click "Hủy booking"
3. Nhập lý do: "Khách có việc đột xuất"
4. Xác nhận

**Kết quả mong đợi**:
- ✅ Booking status: → CANCELLED
- ✅ Booking.cancel_reason = "Khách có việc đột xuất"
- ✅ Table status: RESERVED → EMPTY
- ✅ Bàn sẵn sàng cho booking khác

---

### Test 9: Hoàn Thành Booking ✅

**Mục đích**: Kiểm tra kết thúc booking sau khi khách ăn xong

**Điều kiện**: Booking SEATED, khách đã thanh toán

**Các bước**:
1. Booking đang ở trạng thái SEATED
2. Khách ăn xong và thanh toán
3. Click "Hoàn thành"

**Kết quả mong đợi**:
- ✅ Booking status: SEATED → COMPLETED
- ✅ Table status: OCCUPIED → DIRTY (staff cần dọn)
- ⚠️ Sau khi dọn → staff chuyển DIRTY → EMPTY thủ công

---

### Test 10: Scheduler Tự Động ⏰

**Mục đích**: Kiểm tra tự động cập nhật status bàn

**Điều kiện**: 
- Có booking lúc 18:00
- Hiện tại là 17:35 (25 phút trước giờ booking)
- Booking đã CONFIRMED và gán bàn
- Bàn đang EMPTY

**Cách test**:

**Option 1: Đợi scheduler chạy (mỗi 5 phút)**
- Đợi scheduler tự động chạy
- Kiểm tra DB sau 5 phút

**Option 2: Test thủ công**
```java
BookingService service = new BookingService();
service.updateTableStatusForUpcomingBookings(30);
```

**Kết quả mong đợi**:
- ✅ Bàn chuyển từ EMPTY → RESERVED
- ✅ Booking vẫn CONFIRMED
- ✅ Log: "BookingScheduler started - checking every 5 minutes"

**Kiểm tra DB**:
```sql
-- Tìm booking sắp tới trong 30 phút
SELECT b.booking_code, b.booking_time, b.status, t.table_name, t.status
FROM bookings b
JOIN tables t ON b.table_id = t.table_id
WHERE b.booking_date = CURDATE()
  AND b.booking_time BETWEEN CURTIME() AND ADDTIME(CURTIME(), '00:30:00')
  AND b.status = 'CONFIRMED';
```

---

## Workflow Test Hoàn Chỉnh

### Scenario: Booking Thành Công

```
1. [Customer] Tạo booking
   → Status: PENDING, table_id: NULL

2. [Staff] Xác nhận booking
   → Status: CONFIRMED

3. [Staff] Gán bàn tự động
   → table_id: 5, Table status: RESERVED

4. [Scheduler] 17:45 - Tự động check (15 phút trước)
   → Table vẫn RESERVED (đã đúng)

5. [Staff] 18:00 - Khách đến, click "Seat"
   → Booking: SEATED, Table: OCCUPIED

6. [Staff] 19:30 - Khách ăn xong, click "Complete"
   → Booking: COMPLETED, Table: DIRTY

7. [Staff] Dọn bàn
   → Table: EMPTY (sẵn sàng cho booking tiếp theo)
```

### Scenario: No-Show

```
1-3. Giống scenario trên

4. [Scheduler] 17:45 - Tự động check
   → Table: RESERVED

5. [Staff] 18:30 - Khách không đến, click "No-Show"
   → Booking: NO_SHOW, Table: EMPTY

6. Bàn sẵn sàng cho booking khác
```

---

## Kiểm Tra Bằng SQL

### 1. Xem tất cả booking hôm nay
```sql
SELECT 
    b.booking_code,
    b.customer_name,
    b.booking_time,
    b.party_size,
    b.status,
    t.table_name,
    t.capacity,
    t.status as table_status
FROM bookings b
LEFT JOIN tables t ON b.table_id = t.table_id
WHERE b.booking_date = CURDATE()
ORDER BY b.booking_time;
```

### 2. Tìm bàn trống
```sql
SELECT table_name, capacity, status
FROM tables
WHERE status = 'EMPTY'
ORDER BY capacity;
```

### 3. Tìm booking chưa gán bàn
```sql
SELECT booking_code, customer_name, party_size, status
FROM bookings
WHERE status = 'CONFIRMED' AND table_id IS NULL;
```

### 4. Kiểm tra trùng thời gian
```sql
-- Tìm các booking trùng giờ trên cùng bàn
SELECT 
    t.table_name,
    b1.booking_code as booking1,
    b1.booking_time as time1,
    b2.booking_code as booking2,
    b2.booking_time as time2
FROM bookings b1
JOIN bookings b2 ON b1.table_id = b2.table_id 
    AND b1.booking_id < b2.booking_id
    AND b1.booking_date = b2.booking_date
JOIN tables t ON b1.table_id = t.table_id
WHERE b1.status NOT IN ('CANCELLED', 'NO_SHOW', 'COMPLETED')
  AND b2.status NOT IN ('CANCELLED', 'NO_SHOW', 'COMPLETED')
  AND (
    -- Check overlap: b2 starts before b1 ends
    ADDTIME(b1.booking_time, '02:00:00') > b2.booking_time
    AND b1.booking_time < ADDTIME(b2.booking_time, '02:00:00')
  );
```

### 5. Thống kê booking theo status
```sql
SELECT status, COUNT(*) as count
FROM bookings
WHERE booking_date = CURDATE()
GROUP BY status;
```

---

## Checklist Kiểm Tra

### Tạo Booking
- [ ] Tạo booking thành công với status PENDING
- [ ] Mã booking được tạo tự động
- [ ] Thông tin khách được lưu đúng

### Gán Bàn
- [ ] Auto-assign chọn bàn có capacity gần nhất
- [ ] Không gán bàn nhỏ hơn số khách
- [ ] Kiểm tra trùng thời gian trước khi gán
- [ ] Bàn chuyển sang RESERVED sau khi gán
- [ ] Hiển thị lỗi khi không có bàn phù hợp

### Trạng Thái
- [ ] PENDING → CONFIRMED khi xác nhận
- [ ] CONFIRMED → SEATED khi khách đến
- [ ] SEATED → COMPLETED khi hoàn thành
- [ ] → NO_SHOW khi khách không đến
- [ ] → CANCELLED khi hủy booking

### Bàn
- [ ] EMPTY → RESERVED khi gán booking
- [ ] RESERVED → OCCUPIED khi khách ngồi
- [ ] OCCUPIED → DIRTY sau khi khách đi
- [ ] DIRTY → EMPTY sau khi dọn
- [ ] RESERVED → EMPTY khi hủy/no-show

### Scheduler
- [ ] Chạy tự động mỗi 5 phút
- [ ] Cập nhật bàn sang RESERVED cho booking sắp tới
- [ ] Log hiển thị đúng

### Edge Cases
- [ ] Booking 10 khách nhưng bàn max 8 chỗ
- [ ] 2 booking cùng giờ, cùng bàn
- [ ] Hủy booking đã gán bàn
- [ ] No-show giải phóng bàn
- [ ] Gán bàn cho booking chưa confirm

---

## Lỗi Thường Gặp

### 1. "Không tìm thấy bàn phù hợp"
**Nguyên nhân**: 
- Tất cả bàn đủ capacity đã bị trùng thời gian
- Không có bàn đủ lớn cho số khách

**Giải pháp**: 
- Kiểm tra các bàn trống: `SELECT * FROM tables WHERE status='EMPTY'`
- Kiểm tra booking trùng giờ
- Tăng số lượng bàn hoặc đề xuất giờ khác

### 2. "Bàn đã có booking trùng thời gian"
**Nguyên nhân**: Đã có booking khác trong khoảng ±2 giờ

**Giải pháp**: Chọn bàn khác hoặc giờ khác

### 3. Scheduler không chạy
**Nguyên nhân**: 
- Server chưa khởi động đủ lâu
- Lỗi trong code scheduler

**Kiểm tra**: 
- Xem log console: "BookingScheduler started"
- Test thủ công: `service.updateTableStatusForUpcomingBookings(30)`

---

## Tools Hỗ Trợ Test

### Postman/cURL
```bash
# Gán bàn tự động
curl -X POST http://localhost:8080/staff/bookings/auto-assign \
  -d "bookingId=1"

# Seat customer
curl -X POST http://localhost:8080/staff/bookings/seat \
  -d "bookingId=1"

# No-show
curl -X POST http://localhost:8080/staff/bookings/no-show \
  -d "bookingId=1"
```

### Browser DevTools
- Network tab: Kiểm tra request/response
- Console: Xem lỗi JavaScript
- Application: Kiểm tra session/cookies
