# Logic Gán Bàn Cho Booking

## Tổng Quan

Hệ thống quản lý booking và gán bàn tự động dựa trên capacity, thời gian và trạng thái bàn để tối ưu hóa việc sử dụng bàn trong nhà hàng.

## Quy Trình Booking

### 1. Tạo Booking
- Khách tạo booking với thông tin: tên, số điện thoại, ngày giờ, số khách
- Booking được tạo với status = `PENDING`
- Hệ thống tự động tạo mã booking (VD: BK12345678)

### 2. Xác Nhận Booking
- Staff xác nhận booking → status = `CONFIRMED`
- Có thể gán bàn ngay hoặc để tự động gán sau

### 3. Gán Bàn

#### Gán Bàn Thủ Công
```java
bookingService.assignTable(bookingId, tableId);
```
- Staff chọn bàn cụ thể
- Hệ thống kiểm tra:
  - Capacity bàn >= số khách
  - Không có booking khác trùng thời gian

#### Gán Bàn Tự Động (Khuyến Nghị)
```java
bookingService.autoAssignTable(bookingId);
```
- Hệ thống tự động tìm bàn phù hợp nhất:
  - Capacity >= số khách
  - Capacity gần nhất với số khách (tránh lãng phí)
  - Không trùng thời gian với booking khác
- Ví dụ: 4 khách → ưu tiên bàn 4 chỗ thay vì bàn 8 chỗ

### 4. Kiểm Tra Trùng Thời Gian

Mỗi booking mặc định kéo dài 2 giờ. Hệ thống kiểm tra overlap:

```
Booking A: 18:00 - 20:00
Booking B: 19:00 - 21:00  ❌ TRÙNG (overlap)
Booking C: 20:00 - 22:00  ✅ OK (không overlap)
```

Logic kiểm tra:
- Không cho phép gán bàn nếu có booking khác trong khoảng thời gian giao nhau
- Bỏ qua các booking đã CANCELLED, NO_SHOW, COMPLETED

## Quản Lý Trạng Thái

### Timeline Trạng Thái Bàn

```
EMPTY → RESERVED → OCCUPIED → DIRTY → EMPTY
```

#### EMPTY
- Bàn trống, sẵn sàng sử dụng
- Có thể gán cho booking mới

#### RESERVED
- Bàn đã được giữ cho booking
- Tự động chuyển từ EMPTY khi:
  - Booking được gán bàn và xác nhận
  - Hoặc 15-30 phút trước giờ booking (tự động bởi scheduler)

#### OCCUPIED
- Khách đang ngồi ăn
- Chuyển từ RESERVED khi staff "seat customer"

#### DIRTY
- Khách đã rời đi, bàn cần dọn dẹp
- Chuyển từ OCCUPIED sau khi thanh toán

#### EMPTY (lại)
- Bàn đã được dọn sạch, sẵn sàng cho khách tiếp theo

### Timeline Trạng Thái Booking

```
PENDING → CONFIRMED → SEATED → COMPLETED
                   ↓
              NO_SHOW / CANCELLED
```

#### PENDING
- Booking mới tạo, chờ xác nhận

#### CONFIRMED
- Staff đã xác nhận booking
- Có thể đã gán bàn hoặc chưa

#### SEATED
- Khách đã đến và ngồi vào bàn
- Tạo Order để phục vụ

#### COMPLETED
- Khách đã ăn xong và thanh toán
- Booking kết thúc

#### NO_SHOW
- Khách không đến sau 15-30 phút
- Bàn được giải phóng về EMPTY
- Có thể tự động hoặc staff đánh dấu thủ công

#### CANCELLED
- Booking bị hủy (bởi khách hoặc staff)
- Bàn được giải phóng nếu đã gán

## API Endpoints

### Staff Booking Management

```
POST /staff/bookings/confirm
- Xác nhận booking
- Params: bookingId

POST /staff/bookings/assign-table
- Gán bàn thủ công
- Params: bookingId, tableId

POST /staff/bookings/auto-assign
- Gán bàn tự động (khuyến nghị)
- Params: bookingId

POST /staff/bookings/seat
- Khách ngồi vào bàn
- Params: bookingId
- Chuyển booking → SEATED, table → OCCUPIED

POST /staff/bookings/no-show
- Đánh dấu khách không đến
- Params: bookingId
- Giải phóng bàn

POST /staff/bookings/complete
- Hoàn thành booking
- Params: bookingId

POST /staff/bookings/cancel
- Hủy booking
- Params: bookingId, reason (optional)
```

## Tự Động Hóa

### BookingScheduler
Chạy mỗi 5 phút để:
- **Tự động gán bàn** cho booking đã CONFIRMED trước 1 tiếng (nếu chưa có bàn)
- Cập nhật bàn sang RESERVED cho booking sắp tới (15-30 phút)
- Khóa pre-order trước 60 phút
- Dọn dẹp món không còn trong pre-order
- (Tùy chọn) Tự động đánh dấu NO_SHOW cho booking trễ 30+ phút

#### Tự Động Gán Bàn
Hệ thống tự động gán bàn cho các booking đã được xác nhận (CONFIRMED) nhưng chưa có bàn, khi còn 1 tiếng trước giờ booking:

```java
bookingService.autoAssignTablesForUpcomingBookings(60);
```

Quy trình:
1. Tìm tất cả booking CONFIRMED chưa có bàn, trong vòng 60 phút tới
2. Với mỗi booking, tìm bàn phù hợp nhất:
   - Capacity >= số khách
   - Không trùng thời gian với booking khác
   - Ưu tiên bàn có capacity gần nhất với số khách
3. Gán bàn và chuyển trạng thái bàn sang RESERVED
4. Log kết quả (thành công hoặc không tìm thấy bàn)

Lợi ích:
- Giảm công việc thủ công cho staff
- Đảm bảo mọi booking đều có bàn trước 1 tiếng khi khách đến
- Tối ưu hóa việc sử dụng bàn
- Có nhiều thời gian hơn để xử lý các trường hợp đặc biệt

Để bật auto NO_SHOW, uncomment dòng trong `BookingScheduler.java`:
```java
// autoMarkNoShow();
```

## Quy Tắc Quan Trọng

1. **Một booking - Một bàn**: Mỗi booking chỉ gán một bàn
2. **Capacity đủ**: Bàn phải có capacity >= số khách
3. **Không trùng thời gian**: Một bàn không được có 2 booking trùng giờ
4. **Tối ưu capacity**: Ưu tiên bàn có capacity gần nhất với số khách
5. **Merge bàn**: Với số khách lớn, có thể cần merge nhiều bàn (chưa implement)

## Ví Dụ Sử Dụng

### Scenario 1: Booking Thành Công (Tự Động Gán Bàn)
```
1. Khách đặt bàn 4 người lúc 18:00
2. Staff xác nhận → CONFIRMED (chưa gán bàn)
3. 17:00 - Scheduler tự động gán bàn 4 chỗ phù hợp → RESERVED
4. 17:45 - Scheduler đảm bảo bàn vẫn RESERVED
5. 18:00 - Khách đến, staff "seat" → SEATED, bàn OCCUPIED
6. 19:30 - Khách ăn xong, thanh toán → COMPLETED, bàn DIRTY
7. Staff dọn bàn → bàn EMPTY
```

### Scenario 1b: Booking Thành Công (Gán Bàn Thủ Công)
```
1. Khách đặt bàn 4 người lúc 18:00
2. Staff xác nhận và gán bàn ngay → CONFIRMED, bàn RESERVED
3. 17:45 - Scheduler đảm bảo bàn vẫn RESERVED
4. 18:00 - Khách đến, staff "seat" → SEATED, bàn OCCUPIED
5. 19:30 - Khách ăn xong, thanh toán → COMPLETED, bàn DIRTY
6. Staff dọn bàn → bàn EMPTY
```

### Scenario 2: No-Show
```
1. Khách đặt bàn 2 người lúc 19:00
2. Staff xác nhận và gán bàn → CONFIRMED, bàn RESERVED
3. 19:30 - Khách không đến
4. Staff đánh dấu NO_SHOW → bàn EMPTY
5. Bàn sẵn sàng cho booking khác
```

### Scenario 3: Trùng Thời Gian
```
1. Bàn A đã có booking 18:00-20:00
2. Khách mới đặt bàn lúc 19:00
3. Hệ thống kiểm tra → Bàn A trùng giờ ❌
4. Tự động tìm bàn B (không trùng) → Gán bàn B ✅
```

## Cải Tiến Tương Lai

1. **Merge Tables**: Cho phép gộp nhiều bàn cho nhóm lớn
2. **Dynamic Duration**: Cho phép booking với thời gian khác 2 giờ
3. **Priority Booking**: Ưu tiên khách VIP
4. **Waitlist**: Danh sách chờ khi hết bàn
5. **SMS Reminder**: Nhắc khách trước giờ booking
