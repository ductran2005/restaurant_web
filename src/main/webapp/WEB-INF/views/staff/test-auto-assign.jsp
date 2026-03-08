<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Auto-Assign Tables</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .btn { padding: 10px 20px; margin: 10px; cursor: pointer; }
        .info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #c8e6c9; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .error { background: #ffcdd2; padding: 15px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Test Auto-Assign Tables</h1>
    
    <div class="info">
        <h3>Hướng dẫn:</h3>
        <ol>
            <li>Đảm bảo có booking CONFIRMED chưa có bàn</li>
            <li>Đảm bảo có bàn trống phù hợp</li>
            <li>Click nút bên dưới để trigger auto-assign</li>
            <li>Xem log trong console server</li>
        </ol>
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/staff/bookings/trigger-auto-assign">
        <button type="submit" class="btn">🔄 Chạy Auto-Assign Ngay</button>
    </form>
    
    <% if (session.getAttribute("flash_msg") != null) { %>
        <div class="<%= session.getAttribute("flash_type") %>">
            <%= session.getAttribute("flash_msg") %>
        </div>
        <% session.removeAttribute("flash_msg"); %>
        <% session.removeAttribute("flash_type"); %>
    <% } %>
    
    <hr>
    
    <h3>Thông tin debug:</h3>
    <ul>
        <li>Thời gian hiện tại: <%= java.time.LocalDateTime.now() %></li>
        <li>Scheduler chạy mỗi: 5 phút</li>
        <li>Tìm booking trong vòng: 60 phút tới</li>
        <li>Điều kiện: status = CONFIRMED, table = NULL</li>
    </ul>
    
    <a href="${pageContext.request.contextPath}/staff/bookings">← Quay lại danh sách booking</a>
</body>
</html>
