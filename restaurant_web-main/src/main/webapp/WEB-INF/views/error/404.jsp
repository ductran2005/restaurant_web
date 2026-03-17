<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>404 — Trang không tìm thấy</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            body {
                font-family: 'Be Vietnam Pro', system-ui, sans-serif;
                background: #0f0e0c;
                color: #f0ebe3;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                text-align: center
            }

            .err-code {
                font-size: 100px;
                font-weight: 900;
                color: rgba(232, 160, 32, 0.2);
                letter-spacing: -4px;
                line-height: 1
            }

            .err-title {
                font-size: 24px;
                font-weight: 700;
                margin: 16px 0 8px
            }

            .err-sub {
                font-size: 15px;
                color: #9e9488;
                margin-bottom: 32px
            }

            .btn-home {
                background: #e8a020;
                color: #000;
                font-weight: 700;
                font-size: 14px;
                padding: 12px 28px;
                border-radius: 10px;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px
            }

            .btn-back {
                color: #9e9488;
                font-size: 14px;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                margin-left: 16px
            }

            .btn-back:hover {
                color: #f0ebe3
            }
        </style>
    </head>

    <body>
        <div>
            <div class="err-code">404</div>
            <h1 class="err-title">Trang không tồn tại</h1>
            <p class="err-sub">Rất tiếc, trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển.</p>
            <a href="${pageContext.request.contextPath}/" class="btn-home"><i class="fa-solid fa-house"></i> Về trang
                chủ</a>
            <a href="javascript:history.back()" class="btn-back"><i class="fa-solid fa-arrow-left"></i> Quay lại</a>
        </div>
    </body>

    </html>