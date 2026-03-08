# Tự Động Hủy Booking Trễ

## Tổng Quan

Hệ thống tự động hủy các booking khi khách không đến sau 20 phút kể từ giờ đặt bàn. Điều này giúp:
- Giải phóng bàn cho khách khác
- Tránh lãng phí tài nguyên
- Tự động hóa quy trình quản lý

## Cách Hoạt Động

### Điều Kiện Hủy

Booking sẽ bị tự động hủy khi:
1. Status = `CONFIRMED` (chưa check-in)
2. Thời gian hiện tại > Giờ đặt bàn + 20 phút

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

1. **Giải phóng bàn** (nếu đã gán):
   - Chuyển status bàn về `EMPTY`
   - Bàn sẵn sàng cho booking khác

2. **Cập nhật booking**:
   - Status → `CANCELLED`
   - Cancel reason → "Tự động hủy: Khách không đến sau X phút"
   - Updated_at → Thời gian hiện tại

3. **Log kết quả**:
   ```
   ✓ Auto-cancelled booking BK12345678 (late by 23 minutes)
   Freed table Bàn 5 from booking BK12345678
   ```

## Timeline Chi Tiết

### Ví Dụ 1: Booking 18:00

```
17:00 - Khách đặt bàn cho 18:00
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

| Tính năng | Auto-Cancel | NO_SHOW |
|-----------|-------------|---------|
| Thời gian | 20 phút sau giờ đặt | 30+ phút sau giờ đặt |
| Tự động | ✅ Có | ❌ Thủ công (hoặc tùy chọn) |
| Status | CANCELLED | NO_SHOW |
| Áp dụng cho | CONFIRMED | CONFIRMED, CHECKED_IN |
| Mục đích | Giải phóng bàn nhanh | Ghi nhận khách không đến |

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

Booking có pre-order vẫn bị hủy nếu trễ:
- Pre-order items vẫn được giữ trong database
- Có thể refund deposit nếu cần
- Staff cần xử lý thủ công cho pre-order

## Testing

### Test Case 1: Hủy Thành Công

```
1. Tạo booking CONFIRMED cho 18:00
2. Gán bàn
3. Đợi đến 18:20
4. Chạy scheduler (hoặc trigger thủ công)
5. Kiểm tra:
   - Booking status = CANCELLED
   - Cancel reason có "Tự động hủy"
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
3. **Công bằng**: Áp dụng đồng đều cho tất cả booking
4. **Minh bạch**: Log chi tiết mọi hành động
5. **Linh hoạt**: Có thể điều chỉnh thời gian chờ

## Khuyến Nghị

- **Thông báo khách**: Ghi rõ trong email/SMS xác nhận về chính sách hủy tự động
- **Thời gian hợp lý**: 20 phút là cân bằng giữa chờ khách và giải phóng bàn
- **Theo dõi log**: Kiểm tra log định kỳ để đảm bảo hoạt động đúng
- **Xử lý khiếu nại**: Có quy trình xử lý nếu khách phàn nàn về việc bị hủy

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
