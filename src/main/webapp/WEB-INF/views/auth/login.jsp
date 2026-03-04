<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Đăng nhập — Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/theme.css">
                <style>
                    body {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-height: 100vh;
                        background: linear-gradient(135deg, #0f0e0c 0%, #1a1814 100%);
                        font-family: 'Be Vietnam Pro', sans-serif
                    }

                    .auth-card {
                        background: #1a1814;
                        border: 1px solid rgba(255, 255, 255, 0.08);
                        border-radius: 20px;
                        padding: 2.5rem;
                        width: 100%;
                        max-width: 440px;
                        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.5)
                    }

                    .auth-logo {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        margin-bottom: 2rem;
                        justify-content: center
                    }

                    .auth-logo-icon {
                        width: 40px;
                        height: 40px;
                        background: #e8a020;
                        border-radius: 10px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #000;
                        font-size: 16px
                    }

                    .auth-logo-text {
                        font-size: 18px;
                        font-weight: 700;
                        color: #f0ebe3
                    }

                    .auth-title {
                        font-size: 22px;
                        font-weight: 700;
                        color: #f0ebe3;
                        text-align: center;
                        margin-bottom: 0.25rem
                    }

                    .auth-subtitle {
                        font-size: 13px;
                        color: #9e9488;
                        text-align: center;
                        margin-bottom: 2rem
                    }

                    .form-group {
                        margin-bottom: 1.25rem
                    }

                    .form-label {
                        display: block;
                        font-size: 13px;
                        font-weight: 500;
                        color: #f0ebe3;
                        margin-bottom: 6px
                    }

                    .form-control {
                        width: 100%;
                        padding: 12px 16px;
                        background: rgba(255, 255, 255, 0.05);
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        border-radius: 10px;
                        color: #f0ebe3;
                        font-size: 14px;
                        font-family: inherit;
                        outline: none;
                        transition: all .2s
                    }

                    .form-control:focus {
                        border-color: #e8a020;
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, 0.12)
                    }

                    .input-wrap {
                        position: relative
                    }

                    .input-wrap .form-control {
                        padding-right: 44px
                    }

                    .pw-toggle {
                        position: absolute;
                        right: 14px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: #9e9488;
                        cursor: pointer;
                        font-size: 15px
                    }

                    .btn-login-submit {
                        width: 100%;
                        background: #e8a020;
                        color: #000;
                        font-weight: 700;
                        font-size: 15px;
                        padding: 14px;
                        border-radius: 10px;
                        border: none;
                        cursor: pointer;
                        transition: all .2s;
                        margin-top: 0.5rem
                    }

                    .btn-login-submit:hover {
                        background: #c07c0a;
                        transform: translateY(-1px)
                    }

                    .divider {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        margin: 1.25rem 0;
                        color: #9e9488;
                        font-size: 12px
                    }

                    .divider::before,
                    .divider::after {
                        content: '';
                        flex: 1;
                        height: 1px;
                        background: rgba(255, 255, 255, 0.08)
                    }

                    .btn-google {
                        width: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                        background: rgba(255, 255, 255, 0.05);
                        border: 1px solid rgba(255, 255, 255, 0.1);
                        color: #f0ebe3;
                        padding: 12px;
                        border-radius: 10px;
                        font-size: 14px;
                        font-weight: 500;
                        cursor: pointer;
                        transition: all .2s
                    }

                    .btn-google:hover {
                        background: rgba(255, 255, 255, 0.1);
                        border-color: rgba(255, 255, 255, 0.2)
                    }

                    .auth-links {
                        display: flex;
                        justify-content: space-between;
                        margin-top: 1.5rem;
                        font-size: 13px
                    }

                    .auth-links a {
                        color: #e8a020
                    }

                    .demo-section {
                        margin-top: 1.75rem;
                        padding-top: 1.5rem;
                        border-top: 1px solid rgba(255, 255, 255, 0.08)
                    }

                    .demo-title {
                        font-size: 11px;
                        font-weight: 600;
                        letter-spacing: .08em;
                        text-transform: uppercase;
                        color: #9e9488;
                        margin-bottom: 12px;
                        text-align: center
                    }

                    .demo-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 8px
                    }

                    .demo-btn {
                        padding: 10px 12px;
                        border-radius: 8px;
                        border: 1px solid rgba(232, 160, 32, 0.2);
                        background: rgba(232, 160, 32, 0.06);
                        cursor: pointer;
                        transition: all .2s;
                        text-align: left
                    }

                    .demo-btn:hover {
                        border-color: #e8a020;
                        background: rgba(232, 160, 32, 0.12)
                    }

                    .demo-btn-role {
                        font-size: 10px;
                        font-weight: 700;
                        letter-spacing: .06em;
                        text-transform: uppercase;
                        color: #e8a020;
                        margin-bottom: 2px
                    }

                    .demo-btn-cred {
                        font-size: 11px;
                        color: #9e9488
                    }

                    .alert-error {
                        background: rgba(212, 24, 61, 0.12);
                        border: 1px solid rgba(212, 24, 61, 0.3);
                        color: #f87171;
                        padding: 12px 16px;
                        border-radius: 10px;
                        font-size: 13px;
                        margin-bottom: 1.25rem;
                        display: flex;
                        align-items: center;
                        gap: 8px
                    }
                </style>
            </head>

            <body>
                <div class="auth-card">
                    <div class="auth-logo">
                        <div class="auth-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <span class="auth-logo-text">Hương Việt</span>
                    </div>
                    <h1 class="auth-title">Chào mừng trở lại</h1>
                    <p class="auth-subtitle">Đăng nhập để tiếp tục vào hệ thống</p>

                    <c:if test="${not empty error}">
                        <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i>${error}</div>
                    </c:if>
                    <c:if test="${param.error == 'disabled'}">
                        <div class="alert-error"><i class="fa-solid fa-lock"></i> Tài khoản đã bị khóa. Liên hệ Admin.
                        </div>
                    </c:if>
                    <c:if test="${param.registered == 'true'}">
                        <div
                            style="background:rgba(22,163,74,0.12);border:1px solid rgba(22,163,74,0.3);color:#4ade80;padding:12px 16px;border-radius:10px;font-size:13px;margin-bottom:1.25rem;display:flex;align-items:center;gap:8px">
                            <i class="fa-solid fa-circle-check"></i> Đăng ký thành công! Vui lòng đăng nhập.
                        </div>
                    </c:if>

                    <form method="POST" action="${ctx}/login">
                        <div class="form-group">
                            <label class="form-label" for="username">Tên đăng nhập</label>
                            <input id="username" class="form-control" type="text" name="username" value="${username}"
                                placeholder="Nhập tên đăng nhập..." required autocomplete="username">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="password">Mật khẩu</label>
                            <div class="input-wrap">
                                <input id="password" class="form-control" type="password" name="password"
                                    placeholder="Nhập mật khẩu..." required autocomplete="current-password">
                                <span class="pw-toggle" onclick="togglePw()"><i class="fa-regular fa-eye"
                                        id="pwIcon"></i></span>
                            </div>
                        </div>
                        <button type="submit" class="btn-login-submit"><i class="fa-solid fa-right-to-bracket"></i> Đăng
                            nhập</button>
                    </form>

                    <div class="divider">hoặc</div>
                    <button class="btn-google" onclick="alert('Google OAuth chưa được cấu hình')">
                        <img src="https://www.google.com/favicon.ico" width="16" height="16" alt="Google"> Tiếp tục với
                        Google
                    </button>

                    <div class="auth-links">
                        <a href="${ctx}/forgot-password">Quên mật khẩu?</a>
                        <a href="${ctx}/register">Đăng ký tài khoản mới</a>
                    </div>

                    <div class="demo-section">
                        <div class="demo-title"><i class="fa-solid fa-flask"></i> Tài khoản demo (click để điền)</div>
                        <div class="demo-grid">
                            <button class="demo-btn" onclick="fill('admin','admin123')">
                                <div class="demo-btn-role">🟣 Admin</div>
                                <div class="demo-btn-cred">admin / admin123</div>
                            </button>
                            <button class="demo-btn" onclick="fill('staff1','staff123')">
                                <div class="demo-btn-role">🔵 Staff</div>
                                <div class="demo-btn-cred">staff1 / staff123</div>
                            </button>
                            <button class="demo-btn" onclick="fill('cashier1','cashier123')">
                                <div class="demo-btn-role">🟢 Cashier</div>
                                <div class="demo-btn-cred">cashier1 / cashier123</div>
                            </button>
                            <button class="demo-btn" onclick="fill('customer1','customer123')">
                                <div class="demo-btn-role">🟡 Khách hàng</div>
                                <div class="demo-btn-cred">customer1 / customer123</div>
                            </button>
                        </div>
                    </div>
                </div>
                <script>
                    function fill(u, p) { document.getElementById('username').value = u; document.getElementById('password').value = p }
                    function togglePw() { const i = document.getElementById('password'), ic = document.getElementById('pwIcon'); i.type = i.type === 'password' ? 'text' : 'password'; ic.className = i.type === 'password' ? 'fa-regular fa-eye' : 'fa-regular fa-eye-slash' }
                </script>
            </body>

            </html>