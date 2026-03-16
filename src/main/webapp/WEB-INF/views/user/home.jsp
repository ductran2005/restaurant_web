<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ – Nhà hàng Hương Việt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer-common.css">
    <style>
        /* ─── USER HOME DASHBOARD ─── */
        .dashboard {
            max-width: 1100px;
            margin: 100px auto 60px;
            padding: 0 24px;
        }
        .welcome-section {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border-radius: 20px;
            padding: 48px 40px;
            color: #fff;
            margin-bottom: 40px;
            position: relative;
            overflow: hidden;
        }
        .welcome-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(255,165,0,0.15) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-label {
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: #f0a500;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .welcome-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .welcome-subtitle {
            font-size: 16px;
            color: rgba(255,255,255,0.7);
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .action-card {
            background: #fff;
            border-radius: 16px;
            padding: 32px 24px;
            text-decoration: none;
            color: #1a1a2e;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 16px;
            border: 1px solid #f0f0f0;
        }
        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.12);
            border-color: #f0a500;
        }
        .action-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #fff;
        }
        .action-icon.booking { background: linear-gradient(135deg, #667eea, #764ba2); }
        .action-icon.status  { background: linear-gradient(135deg, #f093fb, #f5576c); }
        .action-icon.menu    { background: linear-gradient(135deg, #4facfe, #00f2fe); }
        .action-icon.preorder{ background: linear-gradient(135deg, #43e97b, #38f9d7); }
        .action-title {
            font-size: 18px;
            font-weight: 600;
        }
        .action-desc {
            font-size: 14px;
            color: #666;
            line-height: 1.5;
        }
        .action-arrow {
            margin-top: auto;
            color: #f0a500;
            font-size: 14px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .action-arrow i { transition: transform 0.3s ease; }
        .action-card:hover .action-arrow i { transform: translateX(4px); }

        @media (max-width: 600px) {
            .dashboard { margin-top: 80px; }
            .welcome-section { padding: 32px 20px; }
            .welcome-title { font-size: 24px; }
            .quick-actions { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <%-- User Navbar --%>
    <jsp:include page="/WEB-INF/views/user/_navbar-user.jsp" />

    <div class="dashboard">
        <%-- Welcome Section --%>
        <div class="welcome-section">
            <div class="welcome-label">Xin chào</div>
            <h1 class="welcome-title">
                Chào mừng<c:if test="${not empty sessionScope.user}">, ${sessionScope.user.fullName}</c:if>! 👋
            </h1>
            <p class="welcome-subtitle">Bạn muốn làm gì hôm nay?</p>
        </div>

        <%-- Quick Action Cards --%>
        <div class="quick-actions">
            <a href="${pageContext.request.contextPath}/user/booking/create" class="action-card">
                <div class="action-icon booking"><i class="fa-solid fa-calendar-plus"></i></div>
                <div class="action-title">Đặt bàn</div>
                <div class="action-desc">Đặt bàn trước để nhận ưu đãi tốt nhất và không lo hết chỗ.</div>
                <div class="action-arrow">Đặt ngay <i class="fa-solid fa-arrow-right"></i></div>
            </a>
            <a href="${pageContext.request.contextPath}/user/booking/status" class="action-card">
                <div class="action-icon status"><i class="fa-solid fa-magnifying-glass"></i></div>
                <div class="action-title">Tra cứu booking</div>
                <div class="action-desc">Kiểm tra trạng thái đặt bàn bằng mã booking hoặc số điện thoại.</div>
                <div class="action-arrow">Tra cứu <i class="fa-solid fa-arrow-right"></i></div>
            </a>
            <a href="${pageContext.request.contextPath}/user/menu" class="action-card">
                <div class="action-icon menu"><i class="fa-solid fa-book-open"></i></div>
                <div class="action-title">Xem thực đơn</div>
                <div class="action-desc">Khám phá hơn 50 món ngon đặc sắc từ ba miền Việt Nam.</div>
                <div class="action-arrow">Xem ngay <i class="fa-solid fa-arrow-right"></i></div>
            </a>
            <a href="${pageContext.request.contextPath}/user/pre-order" class="action-card">
                <div class="action-icon preorder"><i class="fa-solid fa-cart-shopping"></i></div>
                <div class="action-title">Đặt món trước</div>
                <div class="action-desc">Đặt món trước khi đến nhà hàng để tiết kiệm thời gian.</div>
                <div class="action-arrow">Đặt món <i class="fa-solid fa-arrow-right"></i></div>
            </a>
        </div>
    </div>

    <%-- Shared Footer --%>
    <jsp:include page="/WEB-INF/views/common/_footer.jsp" />

    <%-- Chatbot widget --%>
    <jsp:include page="/chatbot.jsp" />
</body>
</html>
