# Tự Động Gán Bàn Cho Booking

## Tổng Quan

Hệ thống tự động gán bàn cho các booking đã được xác nhận (CONFIRMED) trước 1 tiếng (60 phút), giúp giảm công việc thủ công cho nhân viên và đảm bảo mọi booking đều có bàn sẵn sàng khi khách đến.

## Cách Hoạt Động

### Scheduler Tự Động
`BookingScheduler` chạy mỗi 5 phút và thực hiện:

```java
bookingService.autoAssignTablesForUpcomingBookings(60);
```

### Quy Trình Gán Bàn

1. **Tìm Booking Cần Gán Bàn**
   - Status = `CONFIRMED`
   - Chưa có bàn (table = NULL)
   - Thời gian booking trong vòng 60 phút tới

2. **Tìm Bàn Phù Hợp**
   - Capacity >= số khách
   - Không trùng thời gian với booking khác (2 giờ overlap)
   - Ưu tiên bàn có capacity gần nhất với số khách

3. **Gán Bàn**
   - Cập nhật booking.table = bàn được chọn
   - Chuyển trạng thái bàn sang `RESERVED`
   - Log kết quả

## Ví Dụ

### Trường Hợp 1: Gán Bàn Thành Công

```
Thời gian hiện tại: 17:00
Booking: BK12345678
- Khách: Nguyễn Văn A
- Số khách: 4 người
- Thời gian: 18:00
- Status: CONFIRMED
- Bàn: NULL (chưa gán)

Scheduler chạy lúc 17:00:
→ Tìm thấy booking trong vòng 60 phút
→ Tìm bàn phù hợp: Bàn 5 (capacity: 4)
→ Gán bàn 5 cho booking
→ Chuyển bàn 5 sang RESERVED
→ Log: "Auto-assigned table Bàn 5 to booking BK12345678 for 4 guests"
```

### Trường Hợp 2: Không Tìm Thấy Bàn

```
Thời gian hiện tại: 19:00
Booking: BK87654321
- Khách: Trần Thị B
- Số khách: 8 người
- Thời gian: 20:00
- Status: CONFIRMED
- Bàn: NULL

Scheduler chạy lúc 19:00:
→ Tìm thấy booking trong vòng 60 phút
→ Không có bàn nào đủ capacity hoặc tất cả đều bận
→ Log: "No suitable table found for booking BK87654321 (party size: 8)"
→ Staff cần xử lý thủ công (merge bàn hoặc liên hệ khách)
```

### Trường Hợp 3: Booking Đã Có Bàn

```
Booking: BK11111111
- Status: CONFIRMED
- Bàn: Bàn 3 (đã gán thủ công)

Scheduler chạy:
→ Bỏ qua booking này (đã có bàn)
```

## Timeline Hoạt Động

```
16:30 - Khách đặt bàn cho 18:00
16:35 - Staff xác nhận → CONFIRMED (chưa gán bàn)
17:00 - Scheduler chạy → Tự động gán bàn → RESERVED
17:05 - Scheduler chạy → Bỏ qua (đã có bàn)
17:10 - Scheduler chạy → Bỏ qua (đã có bàn)
17:45 - Scheduler chạy → Bỏ qua (đã có bàn)
18:00 - Khách đến → Staff seat → SEATED, bàn OCCUPIED
```

## Lợi Ích

1. **Giảm Công Việc Thủ Công**
   - Staff không cần gán bàn cho mỗi booking
   - Chỉ cần xác nhận booking, hệ thống lo phần còn lại

2. **Đảm Bảo Có Bàn**
   - Mọi booking đều được gán bàn trước 1 tiếng
   - Tránh tình trạng khách đến mà không có bàn

3. **Tối Ưu Sử Dụng Bàn**
   - Thuật toán chọn bàn phù hợp nhất
   - Tránh lãng phí bàn lớn cho nhóm nhỏ

4. **Phát Hiện Vấn Đề Sớm**
   - Log cảnh báo khi không tìm thấy bàn
   - Staff có thời gian xử lý (1 tiếng trước)

## Xử Lý Trường Hợp Đặc Biệt

### Không Đủ Bàn
Nếu không tìm thấy bàn phù hợp:
1. Kiểm tra log để biết booking nào chưa có bàn
2. Xem xét merge bàn cho nhóm lớn
3. Liên hệ khách để đổi giờ hoặc hủy booking
4. Gán bàn thủ công nếu có giải pháp

### Nhóm Lớn (>8 người)
Hiện tại hệ thống chỉ gán 1 bàn:
1. Nếu không có bàn đủ lớn → không gán tự động
2. Staff cần merge bàn thủ công
3. Tương lai: implement auto-merge tables

### Thay Đổi Booking
Nếu khách thay đổi số người sau khi đã gán bàn:
1. Staff cần gán lại bàn phù hợp
2. Hoặc hủy gán bàn cũ, để scheduler gán lại

## Cấu Hình

### Thay Đổi Thời Gian Gán Bàn
Mặc định: 60 phút (1 tiếng) trước booking time

Để thay đổi, sửa trong `BookingScheduler.java`:
```java
// Gán bàn trước 90 phút thay vì 60 phút
bookingService.autoAssignTablesForUpcomingBookings(90);
```

### Thay Đổi Tần Suất Chạy
Mặc định: mỗi 5 phút

Để thay đổi, sửa trong `BookingScheduler.java`:
```java
// Chạy mỗi 3 phút thay vì 5 phút
scheduler.scheduleAtFixedRate(() -> {
    // ...
}, 1, 3, TimeUnit.MINUTES);
```

## Monitoring & Logs

### Log Thành Công
```
Auto-assigned table Bàn 5 to booking BK12345678 for 4 guests
```

### Log Không Tìm Thấy Bàn
```
No suitable table found for booking BK87654321 (party size: 8)
```

### Log Lỗi
```
Failed to auto-assign table for booking BK12345678: [error message]
```

## Testing

### Test Case 1: Gán Bàn Thành Công
```
1. Tạo booking CONFIRMED cho 4 người, 60 phút sau
2. Đảm bảo có bàn 4 chỗ trống
3. Đợi scheduler chạy (hoặc trigger thủ công)
4. Kiểm tra booking đã được gán bàn
5. Kiểm tra bàn đã chuyển sang RESERVED
```

### Test Case 2: Không Đủ Bàn
```
1. Tạo booking CONFIRMED cho 10 người
2. Đảm bảo không có bàn nào đủ capacity
3. Đợi scheduler chạy
4. Kiểm tra log cảnh báo
5. Kiểm tra booking vẫn chưa có bàn
```

### Test Case 3: Trùng Thời Gian
```
1. Tạo booking A: 18:00, đã gán bàn 5
2. Tạo booking B: 18:30, chưa gán bàn, cùng capacity
3. Đợi scheduler chạy
4. Kiểm tra booking B được gán bàn khác (không phải bàn 5)
```

## Tích Hợp Với Các Tính Năng Khác

### Pre-Order
- Tự động gán bàn hoạt động độc lập với pre-order
- Booking có pre-order cũng được gán bàn tự động

### Manual Assignment
- Staff vẫn có thể gán bàn thủ công bất cứ lúc nào
- Scheduler sẽ bỏ qua các booking đã có bàn

### Table Status Management
- Bàn được gán tự động sẽ chuyển sang RESERVED
- Tích hợp với flow quản lý trạng thái bàn hiện có

## Troubleshooting

### Scheduler Không Chạy
1. Kiểm tra log khởi động: "BookingScheduler started"
2. Kiểm tra server có restart không
3. Kiểm tra exception trong log

### Booking Không Được Gán Bàn
1. Kiểm tra status = CONFIRMED
2. Kiểm tra thời gian booking (phải trong 60 phút tới)
3. Kiểm tra có bàn phù hợp không
4. Xem log để biết lý do

### Gán Bàn Sai
1. Kiểm tra capacity bàn
2. Kiểm tra logic findBestAvailableTable
3. Kiểm tra time conflict logic
