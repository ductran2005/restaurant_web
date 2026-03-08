# Ví Dụ Sử Dụng Booking Service

## 1. Tạo Booking Mới

```java
BookingService bookingService = new BookingService();

Booking booking = new Booking();
booking.setCustomerName("Nguyễn Văn A");
booking.setCustomerPhone("0901234567");
booking.setBookingDate(LocalDate.of(2026, 3, 15));
booking.setBookingTime(LocalTime.of(18, 0));
booking.setPartySize(4);
booking.setNote("Gần cửa sổ");

Booking created = bookingService.create(booking);
// Status: PENDING, BookingCode: BK12345678
```

## 2. Xác Nhận và Gán Bàn Tự Động

```java
// Xác nhận booking
bookingService.confirm(created.getId());
// Status: CONFIRMED

// Tự động tìm và gán bàn phù hợp nhất
bookingService.autoAssignTable(created.getId());
// Hệ thống tìm bàn có capacity >= 4, gần nhất với 4
// Kiểm tra không trùng thời gian
// Gán bàn và set status = RESERVED
```

## 3. Gán Bàn Thủ Công

```java
// Staff chọn bàn cụ thể
int tableId = 5; // Bàn số 5
bookingService.assignTable(created.getId(), tableId);
// Kiểm tra capacity và thời gian
// Nếu OK → gán bàn, set RESERVED
```

## 4. Khách Đến - Seat Customer

```java
// Khi khách đến nhà hàng
bookingService.seatCustomer(created.getId());
// Booking: CONFIRMED → SEATED
// Table: RESERVED → OCCUPIED
// Có thể tạo Order để phục vụ
```

## 5. Khách Không Đến - No Show

```java
// Sau 30 phút khách không đến
bookingService.markNoShow(created.getId());
// Booking: CONFIRMED → NO_SHOW
// Table: RESERVED → EMPTY
// Bàn sẵn sàng cho booking khác
```

## 6. Hoàn Thành Booking

```java
// Sau khi khách ăn xong và thanh toán
bookingService.complete(created.getId());
// Booking: SEATED → COMPLETED
// Table: OCCUPIED → DIRTY (staff cần dọn)
// Sau khi dọn → EMPTY
```

## 7. Hủy Booking

```java
// Khách hoặc staff hủy booking
bookingService.cancel(created.getId(), "Khách có việc đột xuất");
// Booking: → CANCELLED
// Table: → EMPTY (nếu đã gán)
```

## 8. Tìm Kiếm Booking

```java
// Tìm theo mã booking
Booking b = bookingService.findByCode("BK12345678");

// Tìm theo số điện thoại
List<Booking> bookings = bookingService.findByPhone("0901234567");

// Tìm theo ngày và status
List<Booking> todayConfirmed = bookingService.findByDateAndStatus(
    LocalDate.now(), 
    "CONFIRMED"
);

// Tìm kiếm với keyword
List<Booking> results = bookingService.search(
    "Nguyễn",           // keyword (tên, sdt, mã)
    "CONFIRMED",        // status
    LocalDate.now()     // date
);
```

## 9. Kiểm Tra Trùng Thời Gian

Logic tự động trong `assignTable()` và `autoAssignTable()`:

```java
// Booking A: 18:00 (kéo dài đến 20:00)
// Booking B: 19:00 (kéo dài đến 21:00)
// → TRÙNG, không cho phép gán cùng bàn

// Booking A: 18:00 (kéo dài đến 20:00)
// Booking C: 20:00 (kéo dài đến 22:00)
// → OK, không trùng
```

## 10. Scheduler Tự Động

Chạy tự động mỗi 5 phút:

```java
// Cập nhật bàn sang RESERVED cho booking sắp tới
bookingService.updateTableStatusForUpcomingBookings(30);
// Tìm booking trong 30 phút tới
// Nếu bàn đang EMPTY → chuyển sang RESERVED

// Lấy danh sách booking cần đánh dấu NO_SHOW
List<Booking> lateBookings = bookingService.getBookingsToNoShow(30);
// Tìm booking trễ hơn 30 phút
```

## Workflow Hoàn Chỉnh

```java
// 1. Khách đặt bàn
Booking booking = new Booking();
booking.setCustomerName("Trần Thị B");
booking.setCustomerPhone("0912345678");
booking.setBookingDate(LocalDate.now());
booking.setBookingTime(LocalTime.of(19, 0));
booking.setPartySize(6);
Booking created = bookingService.create(booking);

// 2. Staff xác nhận
bookingService.confirm(created.getId());

// 3. Tự động gán bàn
bookingService.autoAssignTable(created.getId());
// Hệ thống tìm bàn 6 chỗ hoặc 8 chỗ (gần nhất)

// 4. Scheduler tự động (18:30)
// Đảm bảo bàn đã RESERVED

// 5. Khách đến (19:00)
bookingService.seatCustomer(created.getId());
// Tạo Order để phục vụ

// 6. Khách ăn xong (20:30)
bookingService.complete(created.getId());
// Staff dọn bàn → EMPTY

// Hoặc nếu khách không đến (19:30)
bookingService.markNoShow(created.getId());
// Bàn trở lại EMPTY
```

## Xử Lý Lỗi

```java
try {
    bookingService.autoAssignTable(bookingId);
} catch (RuntimeException e) {
    // "Không tìm thấy bàn phù hợp cho X khách"
    // "Bàn không đủ chỗ cho số khách"
    // "Bàn đã có booking trùng thời gian"
    System.err.println("Lỗi: " + e.getMessage());
}
```

## Best Practices

1. **Ưu tiên Auto-Assign**: Sử dụng `autoAssignTable()` thay vì gán thủ công
2. **Xác nhận trước khi gán**: Confirm booking trước khi assign table
3. **Kiểm tra capacity**: Đảm bảo bàn đủ chỗ cho số khách
4. **Theo dõi NO_SHOW**: Đánh dấu kịp thời để giải phóng bàn
5. **Dọn bàn nhanh**: Chuyển DIRTY → EMPTY sớm để tăng hiệu suất
