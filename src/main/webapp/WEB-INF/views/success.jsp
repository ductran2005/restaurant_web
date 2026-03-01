<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Thanh toán thành công - Restaurant POS</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: 'Segoe UI', sans-serif;
                    background: #f0f2f5;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    min-height: 100vh;
                }

                .card {
                    background: white;
                    border-radius: 16px;
                    padding: 40px 50px;
                    text-align: center;
                    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
                    max-width: 450px;
                }

                .icon {
                    font-size: 64px;
                    margin-bottom: 15px;
                }

                h1 {
                    color: #2E7D32;
                    font-size: 24px;
                    margin-bottom: 10px;
                }

                p {
                    color: #666;
                    font-size: 15px;
                    margin-bottom: 20px;
                }

                .btn {
                    display: inline-block;
                    padding: 12px 30px;
                    border-radius: 8px;
                    text-decoration: none;
                    font-size: 15px;
                    font-weight: 500;
                    margin: 5px;
                }

                .btn-primary {
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                }

                .btn-secondary {
                    background: #f5f5f5;
                    color: #333;
                    border: 1px solid #ddd;
                }

                .btn:hover {
                    opacity: 0.9;
                }
            </style>
        </head>

        <body>
            <div class="card">
                <div class="icon">✅</div>
                <h1>Thanh toán thành công!</h1>
                <p>Cảm ơn quý khách. Đơn hàng đã được thanh toán.</p>
                <a href="${pageContext.request.contextPath}/tables" class="btn btn-primary">Về trang bàn</a>
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-secondary">Xem đơn hàng</a>
            </div>
        </body>

        </html>