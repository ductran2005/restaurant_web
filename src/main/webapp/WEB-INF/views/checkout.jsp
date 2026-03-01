<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Restaurant POS - Thanh Toán</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background: #f5f5f5;
                    color: #333;
                }

                .container {
                    max-width: 1000px;
                    margin: 0 auto;
                    padding: 20px;
                }

                h1 {
                    text-align: center;
                    color: #2c3e50;
                    margin-bottom: 30px;
                }

                .alert {
                    padding: 12px 20px;
                    border-radius: 8px;
                    margin-bottom: 20px;
                }

                .alert-error {
                    background: #ffe0e0;
                    color: #c0392b;
                    border: 1px solid #e74c3c;
                }

                .alert-success {
                    background: #e0ffe0;
                    color: #27ae60;
                    border: 1px solid #2ecc71;
                }

                .card {
                    background: #fff;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                    margin-bottom: 20px;
                }

                .order-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 12px;
                }

                .order-id {
                    font-size: 18px;
                    font-weight: 700;
                    color: #2c3e50;
                }

                .order-total {
                    font-size: 20px;
                    font-weight: 700;
                    color: #e74c3c;
                }

                .order-info {
                    color: #777;
                    margin-bottom: 12px;
                }

                .btn {
                    padding: 8px 20px;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                    font-size: 14px;
                    font-weight: 600;
                    transition: all 0.3s;
                    text-decoration: none;
                }

                .btn-success {
                    background: #27ae60;
                    color: #fff;
                }

                .btn-success:hover {
                    background: #219a52;
                }

                .btn-danger {
                    background: #e74c3c;
                    color: #fff;
                }

                .btn-danger:hover {
                    background: #c0392b;
                }

                .btn-info {
                    background: #3498db;
                    color: #fff;
                }

                .btn-info:hover {
                    background: #2980b9;
                }

                .actions {
                    display: flex;
                    gap: 8px;
                }

                select {
                    padding: 8px 14px;
                    border: 1px solid #ddd;
                    border-radius: 8px;
                    font-size: 14px;
                }
            </style>
        </head>

        <body>
            <div class="container">
                <h1>💰 Thanh Toán Đơn Hàng</h1>

                <c:if test="${not empty error}">
                    <div class="alert alert-error">${error}</div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>

                <c:forEach var="order" items="${orders}">
                    <div class="card">
                        <div class="order-header">
                            <span class="order-id">📋 Đơn #${order.orderId}</span>
                            <span class="order-total">${order.totalAmount} ₫</span>
                        </div>
                        <div class="order-info">
                            🪑 Bàn: ${order.table.tableName} |
                            📝 Loại: ${order.orderType.typeName} |
                            🕐 ${order.orderDate}
                        </div>
                        <div class="actions">
                            <a href="${pageContext.request.contextPath}/checkout?action=detail&orderId=${order.orderId}"
                                class="btn btn-info">Chi tiết</a>
                            <form action="${pageContext.request.contextPath}/checkout" method="post"
                                style="display:flex; gap:8px;">
                                <input type="hidden" name="action" value="pay">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <select name="paymentMethod">
                                    <option value="CASH">💵 Tiền mặt</option>
                                    <option value="CARD">💳 Thẻ</option>
                                    <option value="E_WALLET">📱 Ví điện tử</option>
                                </select>
                                <button type="submit" class="btn btn-success">Thanh toán</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/checkout" method="post">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <button type="submit" class="btn btn-danger"
                                    onclick="return confirm('Hủy đơn hàng này?')">Hủy</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty orders}">
                    <div class="card" style="text-align:center; color:#999; padding:40px;">
                        Không có đơn hàng nào đang chờ thanh toán.
                    </div>
                </c:if>
            </div>
        </body>

        </html>