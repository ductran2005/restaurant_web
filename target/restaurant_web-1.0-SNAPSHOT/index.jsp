<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Restaurant POS</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .welcome-card {
                background: rgba(255, 255, 255, 0.95);
                border-radius: 20px;
                padding: 50px;
                text-align: center;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-width: 500px;
            }

            .welcome-card h1 {
                font-size: 36px;
                color: #2c3e50;
                margin-bottom: 10px;
            }

            .welcome-card p {
                color: #777;
                font-size: 16px;
                margin-bottom: 30px;
            }

            .nav-links {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .nav-link {
                display: block;
                padding: 16px 24px;
                background: #3498db;
                color: #fff;
                text-decoration: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                transition: all 0.3s;
            }

            .nav-link:hover {
                background: #2980b9;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(52, 152, 219, 0.4);
            }

            .nav-link.checkout {
                background: #27ae60;
            }

            .nav-link.checkout:hover {
                background: #219a52;
                box-shadow: 0 4px 12px rgba(39, 174, 96, 0.4);
            }
        </style>
    </head>

    <body>
        <div class="welcome-card">
            <h1>🍽️ Restaurant POS</h1>
            <p>Hệ thống quản lý nhà hàng</p>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/tables" class="nav-link">🪑 Quản Lý Bàn</a>
                <a href="${pageContext.request.contextPath}/orders" class="nav-link">📋 Đơn Hàng</a>
                <a href="${pageContext.request.contextPath}/admin/product" class="nav-link">📦 Quản Lý Sản Phẩm</a>
                <a href="${pageContext.request.contextPath}/auth/login" class="nav-link checkout">🔑 Đăng Nhập</a>
            </div>
        </div>
    </body>

    </html>