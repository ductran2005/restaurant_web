<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Restaurant POS - Lỗi</title>
        <style>
            body {
                font-family: 'Segoe UI', sans-serif;
                background: #f5f5f5;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
            }

            .error-card {
                background: #fff;
                border-radius: 12px;
                padding: 40px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                text-align: center;
                max-width: 500px;
            }

            .error-card h1 {
                font-size: 48px;
                margin-bottom: 10px;
            }

            .error-card p {
                color: #e74c3c;
                margin-bottom: 20px;
            }

            .btn {
                padding: 10px 24px;
                background: #3498db;
                color: #fff;
                border: none;
                border-radius: 8px;
                text-decoration: none;
                font-weight: 600;
            }
        </style>
    </head>

    <body>
        <div class="error-card">
            <h1>⚠️</h1>
            <h2>Đã xảy ra lỗi</h2>
            <p>${error}</p>
            <a href="${pageContext.request.contextPath}/" class="btn">Quay về trang chủ</a>
        </div>
    </body>

    </html>