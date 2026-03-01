<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Kết quả VNPay - Restaurant POS</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: 'Segoe UI', sans-serif;
                    background: #0f172a;
                    color: #e2e8f0;
                    min-height: 100vh;
                    display: flex;
                    flex-direction: column;
                }

                .header {
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                    padding: 20px 30px;
                }

                .header h1 {
                    font-size: 24px;
                }

                .container {
                    flex: 1;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 20px;
                }

                .card {
                    background: #1e293b;
                    border-radius: 16px;
                    padding: 40px;
                    border: 1px solid #334155;
                    max-width: 480px;
                    width: 100%;
                    text-align: center;
                }

                .icon {
                    font-size: 64px;
                    margin-bottom: 16px;
                }

                .title-success {
                    color: #4ade80;
                    font-size: 22px;
                    margin-bottom: 8px;
                }

                .title-error {
                    color: #f87171;
                    font-size: 22px;
                    margin-bottom: 8px;
                }

                .subtitle {
                    color: #94a3b8;
                    font-size: 14px;
                    margin-bottom: 24px;
                }

                .btn {
                    padding: 12px 24px;
                    border: none;
                    border-radius: 10px;
                    cursor: pointer;
                    font-size: 14px;
                    font-weight: 600;
                    text-decoration: none;
                    display: inline-block;
                    margin: 6px;
                }

                .btn--primary {
                    background: linear-gradient(135deg, #667eea, #764ba2);
                    color: white;
                }

                .btn--outline {
                    background: transparent;
                    border: 2px solid #334155;
                    color: #94a3b8;
                }

                .btn--outline:hover {
                    border-color: #667eea;
                    color: #667eea;
                }
            </style>
        </head>

        <body>
            <div class="header">
                <h1>🍽️ Restaurant POS</h1>
            </div>

            <div class="container">
                <div class="card">
                    <c:choose>
                        <c:when test="${not empty error}">
                            <div class="icon">❌</div>
                            <h2 class="title-error">Thanh toán thất bại</h2>
                            <p class="subtitle">${error}</p>
                            <c:if test="${not empty orderId}">
                                <a href="${pageContext.request.contextPath}/checkout?orderId=${orderId}"
                                    class="btn btn--primary">🔄 Thử lại</a>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <div class="icon">✅</div>
                            <h2 class="title-success">Thanh toán thành công!</h2>
                            <p class="subtitle">Cảm ơn quý khách đã sử dụng dịch vụ.</p>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/tables" class="btn btn--outline"
                        style="margin-top:16px;">← Về trang bàn</a>
                </div>
            </div>
        </body>

        </html>