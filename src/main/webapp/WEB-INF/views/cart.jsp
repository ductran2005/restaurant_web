<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Đơn hàng - Restaurant POS</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: 'Segoe UI', sans-serif;
                        background: #f0f2f5;
                    }

                    .header {
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                        padding: 20px 30px;
                    }

                    .header h1 {
                        font-size: 24px;
                    }

                    .nav {
                        margin-top: 10px;
                    }

                    .nav a {
                        color: rgba(255, 255, 255, 0.8);
                        text-decoration: none;
                        margin-right: 20px;
                        font-size: 14px;
                    }

                    .nav a:hover,
                    .nav a.active {
                        color: white;
                        border-bottom: 2px solid white;
                        padding-bottom: 4px;
                    }

                    .container {
                        max-width: 1200px;
                        margin: 20px auto;
                        padding: 0 20px;
                    }

                    .tabs {
                        display: flex;
                        gap: 0;
                        margin-bottom: 20px;
                    }

                    .tab {
                        padding: 10px 25px;
                        background: white;
                        border: 1px solid #ddd;
                        cursor: pointer;
                        text-decoration: none;
                        color: #555;
                        font-weight: 500;
                    }

                    .tab:first-child {
                        border-radius: 8px 0 0 8px;
                    }

                    .tab:last-child {
                        border-radius: 0 8px 8px 0;
                    }

                    .tab.active {
                        background: #667eea;
                        color: white;
                        border-color: #667eea;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                        background: white;
                        border-radius: 10px;
                        overflow: hidden;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                    }

                    th {
                        background: #f8f9fa;
                        padding: 12px 15px;
                        text-align: left;
                        color: #555;
                        font-size: 13px;
                    }

                    td {
                        padding: 12px 15px;
                        border-top: 1px solid #f0f0f0;
                        font-size: 14px;
                    }

                    .status-badge {
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: bold;
                    }

                    .status-open {
                        background: #E3F2FD;
                        color: #1565C0;
                    }

                    .status-paid {
                        background: #E8F5E9;
                        color: #2E7D32;
                    }

                    .status-cancelled {
                        background: #FFEBEE;
                        color: #C62828;
                    }

                    .btn-view {
                        background: #667eea;
                        color: white;
                        border: none;
                        padding: 6px 14px;
                        border-radius: 6px;
                        cursor: pointer;
                        text-decoration: none;
                        font-size: 13px;
                    }

                    .btn-view:hover {
                        opacity: 0.9;
                    }

                    .empty {
                        text-align: center;
                        padding: 40px;
                        color: #888;
                        font-size: 16px;
                    }
                </style>
            </head>

            <body>
                <div class="header">
                    <h1>🍽️ Restaurant POS - Đơn hàng</h1>
                    <div class="nav">
                        <a href="${pageContext.request.contextPath}/tables">Bàn</a>
                        <a href="${pageContext.request.contextPath}/orders" class="active">Đơn hàng</a>
                        <a href="${pageContext.request.contextPath}/admin/product">Sản phẩm</a>
                    </div>
                </div>

                <div class="container">
                    <div class="tabs">
                        <a href="${pageContext.request.contextPath}/orders?tab=open"
                            class="tab ${tab == 'open' ? 'active' : ''}">🟢 Đang mở</a>
                        <a href="${pageContext.request.contextPath}/orders?tab=paid"
                            class="tab ${tab == 'paid' ? 'active' : ''}">✅ Đã thanh toán</a>
                    </div>

                    <c:choose>
                        <c:when test="${empty orders}">
                            <div class="empty">Không có đơn hàng nào.</div>
                        </c:when>
                        <c:otherwise>
                            <table>
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Bàn</th>
                                        <th>Loại</th>
                                        <th>Tổng tiền</th>
                                        <th>Trạng thái</th>
                                        <th>Thời gian mở</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${orders}">
                                        <tr>
                                            <td>${order.orderId}</td>
                                            <td>${order.table.tableName}</td>
                                            <td>${order.orderType}</td>
                                            <td>
                                                <fmt:formatNumber value="${order.totalAmount}" type="number"
                                                    groupingUsed="true" /> đ
                                            </td>
                                            <td>
                                                <span class="status-badge
                                        ${order.status == 'OPEN' ? 'status-open' : ''}
                                        ${order.status == 'PAID' ? 'status-paid' : ''}
                                        ${order.status == 'CANCELLED' ? 'status-cancelled' : ''}">
                                                    ${order.status}
                                                </span>
                                            </td>
                                            <td>${order.openedAt}</td>
                                            <td>
                                                <c:if test="${order.status == 'OPEN'}">
                                                    <a href="${pageContext.request.contextPath}/menu?orderId=${order.orderId}"
                                                        class="btn-view">
                                                        📋 Xem
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/checkout?orderId=${order.orderId}"
                                                        class="btn-view" style="background:#10b981; margin-left:4px;">
                                                        💳 Thanh toán
                                                    </a>
                                                </c:if>
                                                <c:if test="${order.status == 'PAID'}">
                                                    <a href="${pageContext.request.contextPath}/checkout?view=receipt&orderId=${order.orderId}"
                                                        class="btn-view" style="background:#f59e0b;">
                                                        🧾 Hoá đơn
                                                    </a>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </body>

            </html>