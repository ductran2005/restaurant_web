<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>500 — Lỗi máy chủ</title>
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
                color: rgba(239, 68, 68, 0.2);
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

            .detail {
                background: rgba(239, 68, 68, 0.08);
                border: 1px solid rgba(239, 68, 68, 0.2);
                border-radius: 10px;
                padding: 12px 20px;
                font-size: 12px;
                color: #fca5a5;
                font-family: monospace;
                max-width: 600px;
                margin: 0 auto 32px;
                text-align: left
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
        </style>
    </head>

    <body>
        <div>
            <div class="err-code">500</div>
            <h1 class="err-title">Lỗi máy chủ nội bộ</h1>
            <p class="err-sub">Đã có lỗi xảy ra trên máy chủ. Vui lòng thử lại sau.</p>
            <% if (exception !=null) { %>
                <div class="detail">
                    <%=exception.getMessage()%>
                </div>
                <% } %>
                    <a href="${pageContext.request.contextPath}/" class="btn-home"><i class="fa-solid fa-house"></i> Về
                        trang chủ</a>
        </div>
    </body>

    </html>