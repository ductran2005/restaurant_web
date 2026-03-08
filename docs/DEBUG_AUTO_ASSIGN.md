# Debug Auto-Assign Tables

## Vấn Đề: Booking Không Tự Động Gán Bàn

### Các Bước Kiểm Tra

#### 1. Kiểm Tra Scheduler Đã Chạy Chưa

Xem log server khi khởi động, phải có dòng:
```
BookingScheduler started - checking every 5 minutes
```

Nếu không có → Scheduler chưa được khởi động.

#### 2. Kiểm Tra Điều Kiện Booking

Booking phải thỏa mãn TẤT CẢ các điều kiện sau:
- ✅ Status = `CONFIRMED`
- ✅ Table = `NULL` (chưa có bàn)
- ✅ Booking date = hôm nay hoặc ngày mai
- ✅ Booking time trong vòng 60 phút tới

Ví dụ:
```
Thời gian hiện tại: 15:15 (3:15 PM)
Booking time: 16:14 (4:14 PM)
→ Còn 59 phút → ✅ Đủ điều kiện

Thời gian hiện tại: 15:15 (3:15 PM)
Booking time: 16:20 (4:20 PM)
→ Còn 65 phút → ❌ Chưa đủ điều kiện (phải đợi thêm 5 phút)
```

#### 3. Kiểm Tra Có Bàn Phù Hợp Không

Bàn phải thỏa mãn:
- ✅ Capacity >= số khách
- ✅ Không trùng thời gian với booking khác (2 giờ overlap)
- ✅ Status = EMPTY hoặc có thể gán

Ví dụ:
```
Booking: 2 người, 16:14
Bàn A: capacity 2, EMPTY, không có booking nào → ✅ Phù hợp
Bàn B: capacity 2, OCCUPIED → ❌ Đang bận
Bàn C: capacity 2, đã có booking 15:00-17:00 → ❌ Trùng giờ
Bàn D: capacity 4, EMPTY → ✅ Phù hợp (nhưng ưu tiên bàn A)
```

#### 4. Xem Log Chi Tiết

Khi scheduler chạy, sẽ có log như sau:

**Trường hợp thành công:**
```
=== Auto-assign tables check ===
Current time: 2026-03-08T15:15:00
Target time: 2026-03-08T16:15:00
Found 1 bookings to auto-assign
Processing booking: BK97260380 (Party: 2, Date: 2026-03-08, Time: 16:14)
✓ Auto-assigned table Bàn 1 to booking BK97260380 for 2 guests
```

**Trường hợp không tìm thấy bàn:**
```
=== Auto-assign tables check ===
Current time: 2026-03-08T15:15:00
Target time: 2026-03-08T16:15:00
Found 1 bookings to auto-assign
Processing booking: BK97260380 (Party: 2, Date: 2026-03-08, Time: 16:14)
✗ No suitable table found for booking BK97260380 (party size: 2)
```

**Trường hợp không có booking nào:**
```
=== Auto-assign tables check ===
Current time: 2026-03-08T15:15:00
Target time: 2026-03-08T16:15:00
Found 0 bookings to auto-assign
```

### Test Thủ Công

#### Cách 1: Dùng Test Page

1. Truy cập: `http://localhost:8080/restaurant_web/staff/test-auto-assign`
2. Click nút "Chạy Auto-Assign Ngay"
3. Xem kết quả và log

#### Cách 2: Dùng Auto-Assign Cho 1 Booking

1. Vào trang quản lý booking: `/staff/bookings`
2. Tìm booking cần gán bàn
3. Click nút "Auto Assign"
4. Xem kết quả

#### Cách 3: Đợi Scheduler Chạy

Scheduler chạy mỗi 5 phút:
- 15:00, 15:05, 15:10, 15:15, 15:20, ...
- Đợi đến lượt tiếp theo và xem log

### Các Lỗi Thường Gặp

#### Lỗi 1: Scheduler Không Chạy

**Nguyên nhân:**
- Server chưa khởi động đầy đủ
- Lỗi trong code khởi tạo scheduler

**Giải pháp:**
1. Restart server
2. Kiểm tra log có lỗi không
3. Kiểm tra `@WebListener` annotation có đúng không

#### Lỗi 2: Không Tìm Thấy Booking

**Nguyên nhân:**
- Booking không đủ điều kiện (status, time, table)
- Query có vấn đề

**Giải pháp:**
1. Kiểm tra status booking = CONFIRMED
2. Kiểm tra booking chưa có bàn (table = NULL)
3. Kiểm tra thời gian booking trong vòng 60 phút
4. Xem log để biết query tìm được bao nhiêu booking

#### Lỗi 3: Không Tìm Thấy Bàn

**Nguyên nhân:**
- Tất cả bàn đều bận
- Không có bàn đủ capacity
- Bàn bị trùng thời gian với booking khác

**Giải pháp:**
1. Kiểm tra danh sách bàn: `/staff/tables`
2. Kiểm tra capacity các bàn
3. Kiểm tra các booking khác cùng thời gian
4. Xem xét merge bàn hoặc thay đổi thời gian booking

#### Lỗi 4: Lỗi Khi Gán Bàn

**Nguyên nhân:**
- Lỗi database
- Lỗi transaction
- Lỗi validation

**Giải pháp:**
1. Xem stack trace trong log
2. Kiểm tra database connection
3. Kiểm tra constraint trong database

### Checklist Debug

- [ ] Scheduler đã khởi động (có log "BookingScheduler started")
- [ ] Booking có status = CONFIRMED
- [ ] Booking chưa có bàn (table = NULL)
- [ ] Booking trong vòng 60 phút tới
- [ ] Có bàn đủ capacity
- [ ] Bàn không trùng thời gian với booking khác
- [ ] Không có lỗi trong log server
- [ ] Database connection hoạt động bình thường

### Query Debug

Để kiểm tra booking nào đủ điều kiện, chạy SQL:

```sql
SELECT 
    booking_id,
    booking_code,
    customer_name,
    booking_date,
    booking_time,
    party_size,
    status,
    table_id
FROM bookings
WHERE status = 'CONFIRMED'
  AND table_id IS NULL
  AND booking_date = CURDATE()
  AND booking_time > CURTIME()
  AND booking_time <= ADDTIME(CURTIME(), '01:00:00');
```

Để kiểm tra bàn nào trống:

```sql
SELECT 
    t.table_id,
    t.table_name,
    t.capacity,
    t.status
FROM dining_tables t
WHERE t.capacity >= 2  -- thay 2 bằng số khách
  AND t.status = 'EMPTY'
ORDER BY t.capacity ASC;
```

### Liên Hệ

Nếu vẫn không giải quyết được, cung cấp thông tin sau:
1. Log server (từ lúc khởi động đến khi scheduler chạy)
2. Thông tin booking (code, date, time, party size, status, table)
3. Danh sách bàn (capacity, status)
4. Thời gian hiện tại khi test
