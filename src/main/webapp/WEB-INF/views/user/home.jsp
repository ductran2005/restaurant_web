<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ – Nhà hàng Hương Việt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/mobile.css">
    <style>
        /* ─── USER HOME OVERRIDE ─── */
        body { background: #0f0e0c; min-height: 100vh; }

        .user-home-content {
            max-width: 1100px;
            margin: 0 auto;
            padding: 120px 24px 60px;
        }

        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, #1a1710 0%, #2a2318 50%, #1a1710 100%);
            border: 1px solid rgba(232,160,32,0.15);
            border-radius: 20px;
            padding: 48px 44px;
            position: relative;
            overflow: hidden;
            margin-bottom: 48px;
        }
        .welcome-banner::before {
            content: '';
            position: absolute;
            top: -60%;
            right: -15%;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(232,160,32,0.12) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-banner::after {
            content: '';
            position: absolute;
            bottom: -40%;
            left: -10%;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(232,160,32,0.06) 0%, transparent 70%);
            border-radius: 50%;
        }
        .welcome-label {
            font-family: 'Playfair Display', serif;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 3px;
            color: #e8a020;
            margin-bottom: 10px;
            font-weight: 600;
            position: relative;
            z-index: 1;
        }
        .welcome-title {
            font-family: 'Playfair Display', serif;
            font-size: 36px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 10px;
            line-height: 1.3;
            position: relative;
            z-index: 1;
        }
        .welcome-subtitle {
            font-size: 15px;
            color: rgba(255,255,255,0.5);
            position: relative;
            z-index: 1;
        }

        /* Quick Action Cards */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 24px;
            margin-bottom: 48px;
        }
        .action-card {
            background: #1a1710;
            border: 1px solid rgba(232,160,32,0.1);
            border-radius: 16px;
            padding: 36px 28px;
            text-decoration: none;
            color: #fff;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 18px;
            position: relative;
            overflow: hidden;
        }
        .action-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, transparent, #e8a020, transparent);
            opacity: 0;
            transition: opacity 0.4s;
        }
        .action-card:hover {
            transform: translateY(-6px);
            border-color: rgba(232,160,32,0.35);
            box-shadow: 0 12px 40px rgba(232,160,32,0.08);
        }
        .action-card:hover::before { opacity: 1; }

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
        .action-icon.booking {
            background: linear-gradient(135deg, #e8a020, #d4911c);
        }
        .action-icon.status {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
        }
        .action-icon.menu {
            background: linear-gradient(135deg, #10b981, #059669);
        }
        .action-icon.preorder {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }
        .action-title {
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 600;
            color: #fff;
        }
        .action-desc {
            font-size: 14px;
            color: rgba(255,255,255,0.45);
            line-height: 1.6;
        }
        .action-arrow {
            margin-top: auto;
            color: #e8a020;
            font-size: 14px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            padding-top: 8px;
        }
        .action-arrow i {
            transition: transform 0.3s ease;
        }
        .action-card:hover .action-arrow i {
            transform: translateX(6px);
        }

        /* Footer Override */
        .user-footer {
            background: #0a0908;
            border-top: 1px solid rgba(255,255,255,0.06);
            padding: 24px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            color: #9e9488;
        }
        .user-footer strong { color: #e8a020; }

        /* ─── User Dropdown ─── */
        .user-dropdown { position: relative; }
        .user-dropdown-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(232,160,32,0.1);
            border: 1px solid rgba(232,160,32,0.25);
            border-radius: 50px;
            padding: 8px 16px 8px 10px;
            color: #e8a020;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            font-family: inherit;
        }
        .user-dropdown-btn:hover {
            background: rgba(232,160,32,0.18);
            border-color: rgba(232,160,32,0.4);
        }
        .user-avatar {
            width: 32px; height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #e8a020, #d4911c);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 14px;
        }
        .dd-arrow {
            font-size: 10px;
            transition: transform 0.3s;
            color: rgba(232,160,32,0.6);
        }
        .user-dropdown.open .dd-arrow { transform: rotate(180deg); }

        .user-dropdown-menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            min-width: 220px;
            background: #1a1710;
            border: 1px solid rgba(232,160,32,0.2);
            border-radius: 12px;
            padding: 6px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.5);
            opacity: 0;
            visibility: hidden;
            transform: translateY(-8px);
            transition: all 0.25s ease;
            z-index: 100;
        }
        .user-dropdown.open .user-dropdown-menu {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        .dd-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 14px;
            color: rgba(255,255,255,0.75);
            text-decoration: none;
            transition: all 0.2s;
        }
        .dd-item:hover {
            background: rgba(232,160,32,0.1);
            color: #e8a020;
        }
        .dd-item i { width: 18px; text-align: center; font-size: 13px; }
        .dd-divider {
            height: 1px;
            background: rgba(255,255,255,0.08);
            margin: 4px 8px;
        }
        .dd-logout:hover { color: #f87171; background: rgba(248,113,113,0.08); }

        @media (max-width: 768px) {
            .user-home-content { padding-top: 90px; }
            .welcome-banner { padding: 32px 24px; }
            .welcome-title { font-size: 26px; }
            .quick-actions { grid-template-columns: 1fr 1fr; }
            .user-dropdown-btn span { display: none; }
        }
    </style>
</head>
<body>

    <!-- ══════════ NAVBAR (same as landing) ══════════ -->
    <nav class="navbar" id="navbar" style="background:rgba(15,14,12,0.95); backdrop-filter:blur(12px);">
        <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/user/booking/status">Lịch sử booking</a>
            <a href="${pageContext.request.contextPath}/user/pre-order">Đặt món trước</a>
        </div>
        <div class="nav-actions">
            <div class="user-dropdown" id="userDropdown">
                <button class="user-dropdown-btn" onclick="document.getElementById('userDropdown').classList.toggle('open')">
                    <div class="user-avatar"><i class="fa-solid fa-user"></i></div>
                    <span>${sessionScope.user.fullName}</span>
                    <i class="fa-solid fa-chevron-down dd-arrow"></i>
                </button>
                <div class="user-dropdown-menu">
                    <a href="${pageContext.request.contextPath}/user/profile" class="dd-item">
                        <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa thông tin
                    </a>
                    <div class="dd-divider"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="dd-item dd-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>        </div>
        <div class="nav-burger" id="navBurger">
            <span></span><span></span><span></span>
        </div>
    </nav>

    <!-- ══════════ MAIN CONTENT ══════════ -->
    <div class="user-home-content">

        <!-- Welcome Banner -->
        <div class="welcome-banner">
            <div class="welcome-label">—— Xin chào</div>
            <h1 class="welcome-title">
                Chào mừng<c:if test="${not empty sessionScope.user}">, ${sessionScope.user.fullName}</c:if>! 👋
            </h1>
            <p class="welcome-subtitle">Bạn muốn làm gì hôm nay?</p>
        </div>

        <!-- Quick Action Cards -->
        <div class="quick-actions">
            <a href="${pageContext.request.contextPath}/user/booking/create" class="action-card">
                <div class="action-icon booking"><i class="fa-solid fa-calendar-plus"></i></div>
                <div class="action-title">Đặt bàn</div>
                <div class="action-desc">Đặt bàn trước để nhận ưu đãi tốt nhất và không lo hết chỗ.</div>
                <div class="action-arrow">Đặt ngay <i class="fa-solid fa-arrow-right"></i></div>
            </a>
            <a href="${pageContext.request.contextPath}/user/booking/status" class="action-card">
                <div class="action-icon status"><i class="fa-solid fa-magnifying-glass"></i></div>
                <div class="action-title">Lịch sử booking</div>
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
                <div class="action-desc">Chọn sẵn món ăn trước khi đến nhà hàng, tiết kiệm thời gian chờ đợi.</div>
                <div class="action-arrow">Đặt món <i class="fa-solid fa-arrow-right"></i></div>
            </a>
        </div>
    </div>

    <!-- ══════════ FOOTER ══════════ -->
    <footer class="user-footer">
        <p>© 2026 Nhà hàng Hương Việt. 123 Nguyễn Huệ, Q.1, TP.HCM</p>
        <p>Hotline: <strong>1900 1234</strong> (8:00 – 23:00)</p>
    </footer>

    <!-- Chatbot widget -->
    <jsp:include page="/chatbot.jsp" />

    <script>
        // Navbar scroll effect
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('scrolled', window.scrollY > 30);
        });

        // Mobile burger toggle
        const burger = document.getElementById('navBurger');
        if (burger) {
            burger.addEventListener('click', () => {
                navbar.classList.toggle('open');
            });
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            const dd = document.getElementById('userDropdown');
            if (dd && !dd.contains(e.target)) {
                dd.classList.remove('open');
            }
        });
    </script>
</body>
</html>
