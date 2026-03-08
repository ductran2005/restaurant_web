# Testing Auto-Cancel Bookings

## Tổng Quan

Hướng dẫn chi tiết cách test tính năng tự động hủy booking khi khách trễ quá 20 phút.

## Phương Pháp Test

### Phương Pháp 1: Test Thủ Công (Khuyến Nghị)

Tạo booking với thời gian trong quá khứ để test ngay lập tức.

#### Bước 1: Tạo Booking Test

Chạy SQL để tạo booking đã trễ:

```sql
-- Tạo booking trễ 25 phút (đã quá 20 phút)
DECLARE @STAFF_ID INT = (SELECT user_id FROM users WHERE username='staff1');
DECLARE @TABLE_ID INT = (SELECT table_id FROM tables WHERE table_name='T01');

INSERT INTO bookings (
    booking_code, 
    customer_name, 
    customer_phone,
    booking_date, 
    booking_time, 
    party_size, 
    status,
    table_id,
    user_id,
    created_at
) VALUES (
    'TEST-LATE-001',
    N'Test Late Customer',
    '0999999999',
    CAST(GETDATE() AS DATE),                    -- Hôm nay
    CAST(DATEADD(MINUTE, -25, GETDATE()) AS TIME), -- 25 phút trước
    2,
    'CONFIRMED',
    @TABLE_ID,
    @STAFF_ID,
    DATEADD(MINUTE, -30, SYSDATETIME())
);

-- Kiểm tra booking vừa tạo
SELECT 
    booking_code,
    customer_name,
    booking_date,
    booking_time,
    status,
    table_id,
    DATEDIFF(MINUTE, 
        CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2),
        GETDATE()
    ) AS minutes_late
FROM bookings 
WHERE booking_code = 'TEST-LATE-001';
```

#### Bước 2: Trigger Auto-Cancel

**Cách 1: Qua Web UI**
1. Truy cập: `http://localhost:8080/restaurant_web/staff/test-auto-cancel`
2. Click nút "Chạy Auto-Cancel Ngay"
3. Xem kết quả

**Cách 2: Đợi Scheduler**
- Đợi tối đa 5 phút (scheduler chạy mỗi 5 phút)
- Xem log trong console

#### Bước 3: Kiểm Tra Kết Quả

```sql
-- Kiểm tra booking đã bị hủy chưa
SELECT 
    booking_code,
    status,
    cancel_reason,
    table_id,
    updated_at
FROM bookings 
WHERE booking_code = 'TEST-LATE-001';

-- Kết quả mong đợi:
-- status = 'CANCELLED'
-- cancel_reason = 'Tự động hủy: Khách không đến sau 25 phút'
-- table_id = NULL hoặc bàn đã được giải phóng

-- Kiểm tra bàn đã được giải phóng
SELECT table_name, status 
FROM tables 
WHERE table_name = 'T01';

-- Kết quả mong đợi:
-- status = 'EMPTY'
```

### Phương Pháp 2: Test Với Thời Gian Thực

Test với booking thực tế và đợi 20 phút.

#### Bước 1: Tạo Booking

1. Vào trang booking: `/customer/booking`
2. Đặt bàn cho thời gian hiện tại (ví dụ: 15:30 nếu giờ hiện tại là 15:28)
3. Lưu booking code (ví dụ: BK12345678)

#### Bước 2: Xác Nhận Booking

1. Staff vào: `/staff/bookings`
2. Tìm booking vừa tạo
3. Click "Confirm"
4. Gán bàn (hoặc để auto-assign)

#### Bước 3: Đợi 20 Phút

```
15:30 - Giờ đặt bàn
15:35 - Chờ... (5 phút)
15:40 - Chờ... (10 phút)
15:45 - Chờ... (15 phút)
15:50 - Scheduler chạy → Hủy booking (20 phút)
```

#### Bước 4: Kiểm Tra

Sau 20 phút, kiểm tra:
1. Booking status = CANCELLED
2. Bàn status = EMPTY
3. Log có thông báo auto-cancel

### Phương Pháp 3: Test Tự Động (Unit Test)

Tạo unit test để test logic.

```java
// File: src/test/java/market/restaurant_web/service/BookingServiceTest.java
package market.restaurant_web.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.DiningTable;
import java.time.LocalDate;
import java.time.LocalTime;

public class BookingServiceTest {
    
    private BookingService bookingService;
    
    @BeforeEach
    public void setUp() {
        bookingService = new BookingService();
    }
    
    @Test
    public void testAutoCancelLateBooking() {
        // Tạo booking trễ 25 phút
        Booking booking = new Booking();
        booking.setBookingCode("TEST-001");
        booking.setCustomerName("Test Customer");
        booking.setCustomerPhone("0999999999");
        booking.setBookingDate(LocalDate.now());
        booking.setBookingTime(LocalTime.now().minusMinutes(25));
        booking.setPartySize(2);
        booking.setStatus("CONFIRMED");
        
        // Lưu booking vào database
        // bookingService.create(booking);
        
        // Chạy auto-cancel
        bookingService.autoCancelLateBookings(20);
        
        // Kiểm tra kết quả
        // Booking updatedBooking = bookingService.findByCode("TEST-001");
        // assertEquals("CANCELLED", updatedBooking.getStatus());
        // assertTrue(updatedBooking.getCancelReason().contains("Tự động hủy"));
    }
    
    @Test
    public void testNotCancelIfNotLate() {
        // Tạo booking trễ 15 phút (chưa đủ 20)
        Booking booking = new Booking();
        booking.setBookingCode("TEST-002");
        booking.setBookingTime(LocalTime.now().minusMinutes(15));
        booking.setStatus("CONFIRMED");
        
        // Chạy auto-cancel
        bookingService.autoCancelLateBookings(20);
        
        // Kiểm tra: Booking KHÔNG bị hủy
        // assertEquals("CONFIRMED", booking.getStatus());
    }
    
    @Test
    public void testNotCancelIfCheckedIn() {
        // Tạo booking đã check-in
        Booking booking = new Booking();
        booking.setBookingCode("TEST-003");
        booking.setBookingTime(LocalTime.now().minusMinutes(25));
        booking.setStatus("CHECKED_IN");
        
        // Chạy auto-cancel
        bookingService.autoCancelLateBookings(20);
        
        // Kiểm tra: Booking KHÔNG bị hủy
        // assertEquals("CHECKED_IN", booking.getStatus());
    }
}
```

## Test Cases Chi Tiết

### Test Case 1: Hủy Booking Trễ 20 Phút

**Điều kiện:**
- Booking status = CONFIRMED
- Booking time = 25 phút trước
- Có bàn được gán

**Kết quả mong đợi:**
- ✅ Booking status = CANCELLED
- ✅ Cancel reason = "Tự động hủy: Khách không đến sau 25 phút"
- ✅ Bàn status = EMPTY
- ✅ Log: "Auto-cancelled booking..."

**SQL Test:**
```sql
-- Setup
INSERT INTO bookings (...) VALUES (...); -- Tạo booking trễ 25p

-- Execute
EXEC sp_auto_cancel_late_bookings; -- Hoặc trigger qua web

-- Verify
SELECT status, cancel_reason FROM bookings WHERE booking_code = 'TEST-001';
-- Expected: status='CANCELLED', cancel_reason contains 'Tự động hủy'
```

### Test Case 2: KHÔNG Hủy Booking Trễ 15 Phút

**Điều kiện:**
- Booking status = CONFIRMED
- Booking time = 15 phút trước (chưa đủ 20)

**Kết quả mong đợi:**
- ✅ Booking status vẫn = CONFIRMED
- ✅ Không có cancel reason
- ✅ Bàn vẫn RESERVED

### Test Case 3: KHÔNG Hủy Booking Đã Check-in

**Điều kiện:**
- Booking status = CHECKED_IN
- Booking time = 30 phút trước

**Kết quả mong đợi:**
- ✅ Booking status vẫn = CHECKED_IN
- ✅ Không bị hủy

### Test Case 4: Hủy Nhiều Booking Cùng Lúc

**Điều kiện:**
- 3 bookings CONFIRMED, tất cả trễ > 20 phút

**Kết quả mong đợi:**
- ✅ Cả 3 bookings đều bị hủy
- ✅ Tất cả bàn đều được giải phóng
- ✅ Log hiển thị "Found 3 late bookings"

### Test Case 5: Booking Không Có Bàn

**Điều kiện:**
- Booking status = CONFIRMED
- Booking time = 25 phút trước
- table_id = NULL (chưa gán bàn)

**Kết quả mong đợi:**
- ✅ Booking status = CANCELLED
- ✅ Không có lỗi khi giải phóng bàn
- ✅ Log không có "Freed table"

## Checklist Test

- [ ] Test Case 1: Hủy booking trễ 20+ phút
- [ ] Test Case 2: Không hủy booking trễ < 20 phút
- [ ] Test Case 3: Không hủy booking đã check-in
- [ ] Test Case 4: Hủy nhiều booking cùng lúc
- [ ] Test Case 5: Hủy booking không có bàn
- [ ] Kiểm tra log có đầy đủ thông tin
- [ ] Kiểm tra bàn được giải phóng đúng
- [ ] Kiểm tra cancel reason được ghi đúng
- [ ] Kiểm tra updated_at được cập nhật
- [ ] Test với timezone khác nhau

## Công Cụ Test

### Tool 1: Test Page

Tạo trang web để test nhanh:

```jsp
<!-- File: src/main/webapp/WEB-INF/views/staff/test-auto-cancel.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Auto-Cancel</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .btn { padding: 10px 20px; margin: 10px; cursor: pointer; }
        .info { background: #e3f2fd; padding: 15px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Test Auto-Cancel Bookings</h1>
    
    <div class="info">
        <h3>Hướng dẫn:</h3>
        <ol>
            <li>Tạo booking test bằng SQL (xem docs)</li>
            <li>Click nút bên dưới để chạy auto-cancel</li>
            <li>Kiểm tra kết quả trong database</li>
        </ol>
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/staff/bookings/trigger-auto-cancel">
        <input type="hidden" name="action" value="autoCancelLate">
        <button type="submit" class="btn">🔄 Chạy Auto-Cancel Ngay</button>
    </form>
    
    <% if (session.getAttribute("flash_msg") != null) { %>
        <div style="background: #c8e6c9; padding: 15px; margin: 10px 0;">
            <%= session.getAttribute("flash_msg") %>
        </div>
        <% session.removeAttribute("flash_msg"); %>
    <% } %>
    
    <hr>
    
    <h3>SQL Tạo Booking Test:</h3>
    <pre style="background: #f5f5f5; padding: 15px;">
-- Booking trễ 25 phút
DECLARE @STAFF_ID INT = (SELECT user_id FROM users WHERE username='staff1');
DECLARE @TABLE_ID INT = (SELECT table_id FROM tables WHERE table_name='T01');

INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-001',
    N'Test Late Customer',
    '0999999999',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -25, GETDATE()) AS TIME),
    2, 'CONFIRMED', @TABLE_ID, @STAFF_ID,
    DATEADD(MINUTE, -30, SYSDATETIME())
);
    </pre>
    
    <a href="${pageContext.request.contextPath}/staff/bookings">← Quay lại Bookings</a>
</body>
</html>
```

### Tool 2: Controller Endpoint

```java
// Thêm vào BookingController.java
else if ("autoCancelLate".equals(action)) {
    // Trigger auto-cancel for testing
    bookingService.autoCancelLateBookings(20);
    flash(req, "Đã chạy auto-cancel! Kiểm tra log và database.", "info");
}
```

### Tool 3: SQL Script

```sql
-- File: database/test_auto_cancel.sql

-- 1. Tạo booking test
DECLARE @STAFF_ID INT = (SELECT user_id FROM users WHERE username='staff1');
DECLARE @TABLE_ID INT = (SELECT table_id FROM tables WHERE table_name='T01');

-- Booking trễ 25 phút (sẽ bị hủy)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-001', N'Test Late 25min', '0999999991',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -25, GETDATE()) AS TIME),
    2, 'CONFIRMED', @TABLE_ID, @STAFF_ID, SYSDATETIME()
);

-- Booking trễ 15 phút (KHÔNG bị hủy)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-002', N'Test Late 15min', '0999999992',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -15, GETDATE()) AS TIME),
    2, 'CONFIRMED', @TABLE_ID, @STAFF_ID, SYSDATETIME()
);

-- Booking đã check-in (KHÔNG bị hủy)
INSERT INTO bookings (
    booking_code, customer_name, customer_phone,
    booking_date, booking_time, party_size, status,
    table_id, user_id, created_at
) VALUES (
    'TEST-LATE-003', N'Test Checked In', '0999999993',
    CAST(GETDATE() AS DATE),
    CAST(DATEADD(MINUTE, -30, GETDATE()) AS TIME),
    2, 'CHECKED_IN', @TABLE_ID, @STAFF_ID, SYSDATETIME()
);

-- 2. Kiểm tra trước khi chạy
SELECT 
    booking_code,
    status,
    booking_time,
    DATEDIFF(MINUTE, 
        CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2),
        GETDATE()
    ) AS minutes_late
FROM bookings 
WHERE booking_code LIKE 'TEST-LATE-%'
ORDER BY booking_code;

-- 3. Sau khi chạy auto-cancel, kiểm tra kết quả
SELECT 
    booking_code,
    status,
    cancel_reason,
    table_id
FROM bookings 
WHERE booking_code LIKE 'TEST-LATE-%'
ORDER BY booking_code;

-- Kết quả mong đợi:
-- TEST-LATE-001: CANCELLED (trễ 25 phút)
-- TEST-LATE-002: CONFIRMED (chỉ trễ 15 phút)
-- TEST-LATE-003: CHECKED_IN (đã check-in)

-- 4. Cleanup
DELETE FROM bookings WHERE booking_code LIKE 'TEST-LATE-%';
```

## Tips & Tricks

### Tip 1: Test Nhanh Với SQL

Thay vì đợi 20 phút, tạo booking với thời gian trong quá khứ:

```sql
-- Tạo booking "giả lập" đã trễ
booking_time = CAST(DATEADD(MINUTE, -25, GETDATE()) AS TIME)
```

### Tip 2: Xem Log Real-time

Mở console/terminal nơi chạy server để xem log ngay lập tức.

### Tip 3: Test Với Nhiều Timezone

Đảm bảo logic hoạt động đúng với múi giờ khác nhau.

### Tip 4: Test Performance

Tạo 100+ bookings test để kiểm tra performance:

```sql
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO bookings (...) VALUES (...);
    SET @i = @i + 1;
END
```

## Troubleshooting

### Booking Không Bị Hủy

1. Kiểm tra status = CONFIRMED?
2. Kiểm tra thời gian đã đủ 20 phút?
3. Kiểm tra scheduler có chạy?
4. Xem log có lỗi không?

### Lỗi Khi Chạy Test

1. Kiểm tra database connection
2. Kiểm tra transaction có commit không
3. Xem stack trace trong log

### Kết Quả Không Như Mong Đợi

1. Xem lại logic trong code
2. Debug từng bước
3. Kiểm tra dữ liệu test có đúng không
