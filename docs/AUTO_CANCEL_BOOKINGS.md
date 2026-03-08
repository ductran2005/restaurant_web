# Tự Động Hủy Booking Trễ

## Tổng Quan

Hệ thống tự động hủy các booking khi khách không đến sau một khoảng thời gian nhất định. Điều này giúp:
- Giải phóng bàn cho khách khác
- Tránh lãng phí tài nguyên
- Tự động hóa quy trình quản lý
- Xử lý công bằng với cả booking thường và booking có pre-order

## Thời Gian Chờ

- **Booking thường**: 20 phút
- **Booking có pre-order**: 40 phút (nhiều thời gian hơn vì khách đã đặt cọc)

## Cách Hoạt Động

### Điều Kiện Hủy

Booking sẽ bị tự động hủy khi:
1. Status = `CONFIRMED` (chưa check-in)
2. **Booking thường**: Thời gian hiện tại > Giờ đặt bàn + 20 phút
3. **Booking có pre-order**: Thời gian hiện tại > Giờ đặt bàn + 40 phút

### Quy Trình

```
Booking time: 18:00
18:00 - Giờ đặt bàn, khách chưa đến
18:05 - Scheduler chạy → Chưa đủ 20 phút, bỏ qua
18:10 - Scheduler chạy → Chưa đủ 20 phút, bỏ qua
18:15 - Scheduler chạy → Chưa đủ 20 phút, bỏ qua
18:20 - Scheduler chạy → Đủ 20 phút → TỰ ĐỘNG HỦY
```

### Hành Động Khi Hủy

1. **Xử lý deposit** (nếu có pre-order):
   - Deposit status → `FORFEITED` (bị tịch thu)
   - Khách mất tiền cọc vì không đến

2. **Giải phóng bàn** (nếu đã gán):
   - Chuyển status bàn về `EMPTY`
   - Bàn sẵn sàng cho booking khác

3. **Cập nhật booking**:
   - Status → `CANCELLED`
   - Cancel reason:
     - Booking thường: "Tự động hủy: Khách không đến sau X phút"
     - Booking có pre-order: "Tự động hủy: Khách có pre-order không đến sau X phút (cọc bị tịch thu)"
   - Updated_at → Thời gian hiện tại

4. **Log kết quả**:
   ```
   ✓ Auto-cancelled booking BK12345678 (late by 23 minutes)
   Freed table Bàn 5 from booking BK12345678
   ```
   
   Hoặc với pre-order:
   ```
   Deposit forfeited for pre-order booking BK12345678 (amount: 50000)
   Freed table Bàn 5 from booking BK12345678
   ✓ Auto-cancelled booking BK12345678 (late by 42 minutes, has pre-order)
   ```

## Timeline Chi Tiết

### Ví Dụ 1: Booking Thường 18:00

```
17:00 - Khách đặt bàn cho 18:00 (không có pre-order)
17:05 - Staff xác nhận → CONFIRMED
17:00 - Scheduler gán bàn tự động → Bàn 5 RESERVED

18:00 - Giờ đặt bàn
        Khách chưa đến
        
18:05 - Scheduler chạy
        Kiểm tra: 18:05 - 18:00 = 5 phút
        → Chưa đủ 20 phút, bỏ qua
        
18:10 - Scheduler chạy
        Kiểm tra: 18:10 - 18:00 = 10 phút
        → Chưa đủ 20 phút, bỏ qua
        
18:15 - Scheduler chạy
        Kiểm tra: 18:15 - 18:00 = 15 phút
        → Chưa đủ 20 phút, bỏ qua
        
18:20 - Scheduler chạy
        Kiểm tra: 18:20 - 18:00 = 20 phút
        → ✅ Đủ 20 phút → TỰ ĐỘNG HỦY
        → Giải phóng Bàn 5 → EMPTY
        → Status: CANCELLED
        → Lý do: "Tự động hủy: Khách không đến sau 20 phút"
```

### Ví Dụ 1B: Booking Có Pre-Order 18:00

```
17:00 - Khách đặt bàn cho 18:00 + pre-order 5 món
        Đặt cọc 50,000đ → PAID
17:05 - Staff xác nhận → CONFIRMED
17:00 - Scheduler gán bàn tự động → Bàn 5 RESERVED

18:00 - Giờ đặt bàn
        Khách chưa đến
        
18:05 - Scheduler chạy
        Has pre-order → Grace time = 40 phút
        Kiểm tra: 18:05 - 18:00 = 5 phút
        → Chưa đủ 40 phút, bỏ qua
        
18:20 - Scheduler chạy
        Kiểm tra: 18:20 - 18:00 = 20 phút
        → Chưa đủ 40 phút, bỏ qua (booking thường đã bị hủy ở đây)
        
18:35 - Scheduler chạy
        Kiểm tra: 18:35 - 18:00 = 35 phút
        → Chưa đủ 40 phút, bỏ qua
        
18:40 - Scheduler chạy
        Kiểm tra: 18:40 - 18:00 = 40 phút
        → ✅ Đủ 40 phút → TỰ ĐỘNG HỦY
        → Deposit: PAID → FORFEITED (tịch thu 50,000đ)
        → Giải phóng Bàn 5 → EMPTY
        → Status: CANCELLED
        → Lý do: "Tự động hủy: Khách có pre-order không đến sau 40 phút (cọc bị tịch thu)"
```

### Ví Dụ 2: Khách Đến Đúng Giờ

```
18:00 - Giờ đặt bàn
18:02 - Khách đến, staff check-in
        Status: CHECKED_IN
        
18:05 - Scheduler chạy
        Status = CHECKED_IN (không phải CONFIRMED)
        → Bỏ qua, không hủy
```

### Ví Dụ 3: Khách Đến Trễ 15 Phút

```
18:00 - Giờ đặt bàn
18:15 - Khách đến trễ, staff check-in
        Status: CHECKED_IN
        
18:20 - Scheduler chạy
        Status = CHECKED_IN (không phải CONFIRMED)
        → Bỏ qua, không hủy
        → Khách vẫn được phục vụ
```

## So Sánh Với NO_SHOW

| Tính năng | Auto-Cancel (Thường) | Auto-Cancel (Pre-order) | NO_SHOW |
|-----------|---------------------|------------------------|---------|
| Thời gian | 20 phút sau giờ đặt | 40 phút sau giờ đặt | 30+ phút sau giờ đặt |
| Tự động | ✅ Có | ✅ Có | ❌ Thủ công (hoặc tùy chọn) |
| Status | CANCELLED | CANCELLED | NO_SHOW |
| Áp dụng cho | CONFIRMED | CONFIRMED | CONFIRMED, CHECKED_IN |
| Xử lý deposit | N/A | FORFEITED | N/A |
| Mục đích | Giải phóng bàn nhanh | Giải phóng bàn + tịch thu cọc | Ghi nhận khách không đến |

## Cấu Hình

### Thay Đổi Thời Gian Chờ

Mặc định: 20 phút

Để thay đổi, sửa trong `BookingScheduler.java`:

```java
// Hủy sau 30 phút thay vì 20 phút
bookingService.autoCancelLateBookings(30);
```

### Tắt Tính Năng

Comment dòng trong scheduler:

```java
// Auto-cancel bookings if customer is 20+ mins late
// bookingService.autoCancelLateBookings(20);
```

## Log & Monitoring

### Log Thành Công

```
=== Auto-cancel late bookings check ===
Current time: 2026-03-08T18:20:00
Found 1 late bookings to cancel
Freed table Bàn 5 from booking BK12345678
✓ Auto-cancelled booking BK12345678 (late by 20 minutes)
```

### Log Không Có Booking Trễ

```
=== Auto-cancel late bookings check ===
Current time: 2026-03-08T18:20:00
Found 0 late bookings to cancel
```

### Log Lỗi

```
Failed to auto-cancel booking BK12345678: [error message]
```

## Xử Lý Trường Hợp Đặc Biệt

### Khách Gọi Báo Trễ

Nếu khách gọi báo trễ:
1. Staff có thể check-in sớm (trước 20 phút)
2. Hoặc tạo booking mới với giờ mới
3. Hủy booking cũ thủ công

### Khách VIP

Có thể:
1. Tăng thời gian chờ lên 30-40 phút
2. Hoặc staff check-in sớm để tránh auto-cancel
3. Hoặc thêm logic đặc biệt cho khách VIP

### Booking Có Pre-Order

Booking có pre-order được xử lý đặc biệt:
- **Thời gian chờ lâu hơn**: 40 phút thay vì 20 phút
- **Lý do**: Khách đã đặt cọc và đặt món, nên được nhiều thời gian hơn
- **Deposit bị tịch thu**: Khi auto-cancel, deposit status → FORFEITED
- **Pre-order items**: Vẫn được giữ trong database để tracking
- **Không refund**: Khách mất tiền cọc vì không đến

## Testing

### Test Case 1: Hủy Booking Thường

```
1. Tạo booking CONFIRMED cho 18:00 (không có pre-order)
2. Gán bàn
3. Đợi đến 18:20
4. Chạy scheduler (hoặc trigger thủ công)
5. Kiểm tra:
   - Booking status = CANCELLED
   - Cancel reason = "Tự động hủy: Khách không đến sau 20 phút"
   - Bàn status = EMPTY
```

### Test Case 1B: Hủy Booking Có Pre-Order

```
1. Tạo booking CONFIRMED cho 18:00
2. Thêm pre-order items
3. Đặt cọc → deposit_status = PAID, deposit_amount = 50000
4. Gán bàn
5. Đợi đến 18:20 → Chạy scheduler → Chưa bị hủy (cần 40 phút)
6. Đợi đến 18:40 → Chạy scheduler
7. Kiểm tra:
   - Booking status = CANCELLED
   - Cancel reason = "Tự động hủy: Khách có pre-order không đến sau 40 phút (cọc bị tịch thu)"
   - Deposit status = FORFEITED
   - Bàn status = EMPTY
```

### Test Case 2: Không Hủy (Đã Check-in)

```
1. Tạo booking CONFIRMED cho 18:00
2. Lúc 18:15, check-in booking
3. Đợi đến 18:20
4. Chạy scheduler
5. Kiểm tra:
   - Booking vẫn CHECKED_IN
   - Không bị hủy
```

### Test Case 3: Không Hủy (Chưa Đủ Thời Gian)

```
1. Tạo booking CONFIRMED cho 18:00
2. Lúc 18:15 (chỉ trễ 15 phút)
3. Chạy scheduler
4. Kiểm tra:
   - Booking vẫn CONFIRMED
   - Chưa bị hủy
```

## Lợi Ích

1. **Tự động hóa**: Không cần staff theo dõi và hủy thủ công
2. **Giải phóng tài nguyên**: Bàn được giải phóng nhanh cho khách khác
3. **Công bằng & Linh hoạt**: 
   - Booking thường: 20 phút (nhanh)
   - Booking pre-order: 40 phút (nhiều thời gian hơn vì đã đặt cọc)
4. **Xử lý deposit tự động**: Tịch thu cọc khi khách không đến
5. **Minh bạch**: Log chi tiết mọi hành động
6. **Có thể điều chỉnh**: Thời gian chờ có thể thay đổi theo nhu cầu

## Khuyến Nghị

- **Thông báo khách**: Ghi rõ trong email/SMS xác nhận về chính sách hủy tự động:
  - Booking thường: Hủy sau 20 phút
  - Booking pre-order: Hủy sau 40 phút, cọc bị tịch thu
- **Thời gian hợp lý**: 
  - 20 phút cho booking thường: Cân bằng giữa chờ khách và giải phóng bàn
  - 40 phút cho pre-order: Tôn trọng khách đã đặt cọc
- **Theo dõi log**: Kiểm tra log định kỳ để đảm bảo hoạt động đúng
- **Xử lý khiếu nại**: Có quy trình xử lý nếu khách phàn nàn về việc bị hủy
- **Chính sách deposit**: Giải thích rõ về việc tịch thu cọc khi không đến

## Troubleshooting

### Booking Không Bị Hủy

Kiểm tra:
1. Status có phải CONFIRMED không?
2. Đã đủ 20 phút chưa?
3. Scheduler có chạy không?
4. Có lỗi trong log không?

### Booking Bị Hủy Nhầm

Kiểm tra:
1. Thời gian server có đúng không?
2. Booking time có đúng không?
3. Logic tính thời gian có lỗi không?

### Bàn Không Được Giải Phóng

Kiểm tra:
1. Booking có được gán bàn không?
2. Transaction có commit thành công không?
3. Có lỗi khi update table không?


---

## BUG FIX: SQL Type Mismatch Error (2026-03-08)

### Vấn Đề

Scheduler gặp lỗi SQL khi chạy:
```
The data types time and datetime are incompatible in the less than or equal to operator
```

Lỗi xảy ra trong hai methods:
- `getBookingsToReserve()` - Cập nhật status bàn cho booking sắp tới
- `getBookingsToNoShow()` - Đánh dấu booking NO_SHOW

### Nguyên Nhân

- Cột `booking_time` trong database là kiểu `TIME`
- HQL query so sánh `bookingTime` với `LocalTime` parameters
- SQL Server không cho phép so sánh trực tiếp giữa `TIME` và `DATETIME`

### Giải Pháp

Đổi từ HQL sang native SQL với type casting:
```sql
CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2)
```

Cách này:
- Kết hợp `booking_date` và `booking_time` thành `DATETIME2` đầy đủ
- Cho phép so sánh với `LocalDateTime` parameters
- Tương tự cách dùng trong `test_auto_cancel.sql`

### Files Đã Sửa

- `src/main/java/market/restaurant_web/service/BookingService.java`
  - Fixed `getBookingsToReserve()` method
  - Fixed `getBookingsToNoShow()` method

### Kết Quả

✅ Auto-cancel vẫn hoạt động bình thường (không bị ảnh hưởng)
✅ SQL errors không còn xuất hiện
✅ Scheduler chạy đầy đủ 3 operations:
   - Auto-assign tables
   - Update table status for upcoming bookings (đã fix)
   - Auto-cancel late bookings

### Verification

Sau khi restart application:
1. Đợi scheduler chạy (mỗi 5 phút)
2. Kiểm tra logs - không còn SQL errors
3. Verify cả 3 operations đều chạy thành công
