<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Auto-Cancel Bookings</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .btn { padding: 10px 20px; margin: 10px; cursor: pointer; background: #4CAF50; color: white; border: none; border-radius: 4px; }
        .btn:hover { background: #45a049; }
        .info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #2196F3; }
        .success { background: #c8e6c9; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .warning { background: #fff3cd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        pre { background: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; }
        h1 { color: #333; }
        h3 { color: #555; margin-top: 20px; }
        ol { line-height: 1.8; }
        code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>🧪 Test Auto-Cancel Bookings</h1>
    
    <div class="info">
        <h3>📋 Hướng dẫn Test:</h3>
        <ol>
            <li>Chạy SQL bên dưới để tạo booking test (trễ 25 phút)</li>
            <li>Click nút "Chạy Auto-Cancel" để trigger</li>
            <li>Kiểm tra kết quả bằng SQL verify</li>
            <li>Xem log trong console server</li>
        </ol>
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/staff/bookings/trigger-auto-cancel">
        <input type="hidden" name="action" value="autoCancelLate">
        <button type="submit" class="btn">🔄 Chạy Auto-Cancel Ngay (20 phút)</button>
    </form>
    
    <% if (session.getAttribute("flash_msg") != null) { %>
        <div class="<%= session.getAttribute("flash_type") %>">
            <%= session.getAttribute("flash_msg") %>
        </div>
        <% session.removeAttribute("flash_msg"); %>
        <% session.removeAttribute("flash_type"); %>
    <% } %>
    
    <hr>
    
    <h3>1️⃣ SQL Tạo Booking Test (Trễ 25 Phút)</h3>
    <pre>-- Tạo booking test trễ 25 phút (sẽ bị hủy)
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
    booking_time,
    status,
    table_id,
    DATEDIFF(MINUTE, 
        CAST(CONCAT(CAST(booking_date AS VARCHAR), ' ', CAST(booking_time AS VARCHAR)) AS DATETIME2),
        GETDATE()
    ) AS minutes_late
FROM bookings 
WHERE booking_code = 'TEST-LATE-001';</pre>

    <h3>2️⃣ SQL Verify Kết Quả (Sau Khi Chạy)</h3>
    <pre>-- Kiểm tra booking đã bị hủy chưa
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
-- status = 'EMPTY'</pre>

    <h3>3️⃣ SQL Cleanup (Xóa Booking Test)</h3>
    <pre>-- Xóa booking test sau khi hoàn thành
DELETE FROM bookings WHERE booking_code = 'TEST-LATE-001';</pre>

    <hr>
    
    <h3>📊 Test Cases Khác</h3>
    
    <div class="warning">
        <strong>Test Case 2:</strong> Booking trễ 15 phút (KHÔNG bị hủy)
        <pre style="margin-top: 10px;">-- Thay -25 thành -15 trong SQL trên
booking_time = CAST(DATEADD(MINUTE, -15, GETDATE()) AS TIME)</pre>
    </div>
    
    <div class="warning">
        <strong>Test Case 3:</strong> Booking đã check-in (KHÔNG bị hủy)
        <pre style="margin-top: 10px;">-- Thay status thành 'CHECKED_IN'
status = 'CHECKED_IN'</pre>
    </div>
    
    <hr>
    
    <h3>📝 Thông Tin Debug:</h3>
    <ul>
        <li>Thời gian hiện tại: <%= java.time.LocalDateTime.now() %></li>
        <li>Scheduler chạy mỗi: 5 phút</li>
        <li>Thời gian chờ để hủy: 20 phút</li>
        <li>Điều kiện: status = CONFIRMED, trễ > 20 phút</li>
    </ul>
    
    <p>
        <a href="${pageContext.request.contextPath}/staff/bookings">← Quay lại Bookings</a> |
        <a href="${pageContext.request.contextPath}/staff/debug-bookings">🔍 Debug Bookings</a> |
        <a href="${pageContext.request.contextPath}/staff/test-auto-assign">🔄 Test Auto-Assign</a>
    </p>
</body>
</html>
