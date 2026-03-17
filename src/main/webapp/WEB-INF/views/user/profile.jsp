<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cá nhân – Nhà hàng Hương Việt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <style>
        body { background: #0f0e0c; min-height: 100vh; }

        .profile-content {
            max-width: 640px;
            margin: 0 auto;
            padding: 120px 24px 60px;
        }

        /* Page Header */
        .profile-header {
            text-align: center;
            margin-bottom: 40px;
        }
        .profile-header .label {
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 3px;
            color: #e8a020;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .profile-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            color: #fff;
            font-weight: 700;
        }
        .profile-header p {
            color: rgba(255,255,255,0.45);
            font-size: 15px;
            margin-top: 8px;
        }

        /* Avatar */
        .profile-avatar {
            width: 80px; height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #e8a020, #d4911c);
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; color: #fff;
            margin: 0 auto 24px;
            box-shadow: 0 8px 32px rgba(232,160,32,0.25);
        }

        /* Form Card */
        .profile-card {
            background: #1a1710;
            border: 1px solid rgba(232,160,32,0.12);
            border-radius: 16px;
            padding: 36px 32px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: rgba(255,255,255,0.6);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }
        .form-group label .required { color: #e8a020; }
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 10px;
            color: #fff;
            font-size: 15px;
            font-family: inherit;
            outline: none;
            transition: all 0.3s;
        }
        .form-group input:focus {
            border-color: rgba(232,160,32,0.5);
            box-shadow: 0 0 0 3px rgba(232,160,32,0.08);
            background: rgba(255,255,255,0.08);
        }
        .form-group input::placeholder { color: rgba(255,255,255,0.25); }
        .form-group input[readonly] {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        /* Buttons */
        .btn-row {
            display: flex;
            gap: 12px;
            margin-top: 28px;
        }
        .btn-save {
            flex: 1;
            padding: 14px;
            background: linear-gradient(135deg, #e8a020, #d4911c);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: inherit;
        }
        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(232,160,32,0.3);
        }
        .btn-back {
            padding: 14px 24px;
            background: transparent;
            border: 1px solid rgba(255,255,255,0.15);
            color: rgba(255,255,255,0.6);
            border-radius: 10px;
            font-size: 15px;
            font-weight: 500;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
        }
        .btn-back:hover {
            border-color: rgba(255,255,255,0.3);
            color: #fff;
        }

        /* Alert */
        .alert {
            padding: 14px 18px;
            border-radius: 10px;
            font-size: 14px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success {
            background: rgba(16,185,129,0.1);
            border: 1px solid rgba(16,185,129,0.25);
            color: #10b981;
        }
        .alert-error {
            background: rgba(239,68,68,0.1);
            border: 1px solid rgba(239,68,68,0.25);
            color: #ef4444;
        }

        /* Footer */
        .profile-footer {
            background: #0a0908;
            border-top: 1px solid rgba(255,255,255,0.06);
            padding: 24px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            color: #9e9488;
        }
        .profile-footer strong { color: #e8a020; }

        @media (max-width: 600px) {
            .profile-content { padding-top: 90px; }
            .profile-card { padding: 24px 20px; }
            .form-row { grid-template-columns: 1fr; }
            .btn-row { flex-direction: column; }
        }
    </style>
</head>
<body>

    <!-- ══════════ NAVBAR ══════════ -->
    <nav class="navbar" id="navbar" style="background:rgba(15,14,12,0.95); backdrop-filter:blur(12px);">
        <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/user/booking/status">Tra cứu booking</a>
        </div>
        <div class="nav-actions">
            <a href="${pageContext.request.contextPath}/user/home" class="btn-book" style="background:transparent; border:1px solid rgba(232,160,32,0.3); color:#e8a020;">
                <i class="fa-solid fa-arrow-left"></i> Trang chủ
            </a>
        </div>
        <div class="nav-burger" id="navBurger">
            <span></span><span></span><span></span>
        </div>
    </nav>

    <!-- ══════════ MAIN CONTENT ══════════ -->
    <div class="profile-content">

        <div class="profile-header">
            <div class="profile-avatar"><i class="fa-solid fa-user"></i></div>
            <div class="label">—— Thông tin cá nhân</div>
            <h1>Chỉnh sửa hồ sơ</h1>
            <p>Cập nhật thông tin cá nhân của bạn</p>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty success}">
            <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> ${success}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}</div>
        </c:if>

        <div class="profile-card">
            <form method="post" action="${pageContext.request.contextPath}/user/profile">
                <input type="hidden" name="returnUrl" value="${returnUrl}">

                <div class="form-group">
                    <label>Tên đăng nhập</label>
                    <input type="text" value="${sessionScope.user.username}" readonly>
                </div>

                <div class="form-group">
                    <label>Họ và tên <span class="required">*</span></label>
                    <input type="text" name="fullName" value="${sessionScope.user.fullName}"
                           placeholder="Nhập họ và tên" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Email <span class="required">*</span></label>
                        <input type="email" name="email" value="${sessionScope.user.email}"
                               placeholder="email@example.com" required>
                    </div>
                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <input type="text" name="phone" value="${sessionScope.user.phone}"
                               placeholder="0901234567">
                    </div>
                </div>

                <div class="btn-row">
                    <a href="${not empty returnUrl ? returnUrl : pageContext.request.contextPath.concat('/user/home')}" class="btn-back">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                    <button type="submit" class="btn-save">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ══════════ FOOTER ══════════ -->
    <footer class="profile-footer">
        <p>© 2026 Nhà hàng Hương Việt. 123 Nguyễn Huệ, Q.1, TP.HCM</p>
        <p>Hotline: <strong>1900 1234</strong> (8:00 – 23:00)</p>
    </footer>

    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('scrolled', window.scrollY > 30);
        });
    </script>
</body>
</html>
