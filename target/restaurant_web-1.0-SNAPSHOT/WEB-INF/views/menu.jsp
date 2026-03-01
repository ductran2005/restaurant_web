<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Menu - Restaurant POS</title>
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
                        max-width: 1400px;
                        margin: 20px auto;
                        padding: 0 20px;
                        display: flex;
                        gap: 20px;
                    }

                    /* Menu panel */
                    .menu-panel {
                        flex: 2;
                    }

                    .menu-panel h2 {
                        font-size: 20px;
                        color: #333;
                        margin-bottom: 15px;
                    }

                    .products-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 12px;
                    }

                    .product-card {
                        background: white;
                        border-radius: 10px;
                        padding: 15px;
                        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
                    }

                    .product-name {
                        font-weight: bold;
                        color: #333;
                        font-size: 15px;
                    }

                    .product-price {
                        color: #667eea;
                        font-weight: bold;
                        font-size: 16px;
                        margin: 6px 0;
                    }

                    .product-form {
                        display: flex;
                        gap: 6px;
                        margin-top: 8px;
                    }

                    .product-form input {
                        width: 50px;
                        padding: 6px;
                        border: 1px solid #ddd;
                        border-radius: 6px;
                        text-align: center;
                    }

                    .btn-add {
                        background: #4CAF50;
                        color: white;
                        border: none;
                        padding: 6px 14px;
                        border-radius: 6px;
                        cursor: pointer;
                        font-size: 13px;
                    }

                    .btn-add:hover {
                        background: #43A047;
                    }

                    /* Cart panel */
                    .cart-panel {
                        flex: 1;
                        background: white;
                        border-radius: 12px;
                        padding: 20px;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                        height: fit-content;
                        position: sticky;
                        top: 20px;
                    }

                    .cart-panel h2 {
                        font-size: 18px;
                        color: #333;
                        margin-bottom: 10px;
                        border-bottom: 2px solid #667eea;
                        padding-bottom: 8px;
                    }

                    .cart-table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 14px;
                    }

                    .cart-table th {
                        text-align: left;
                        padding: 8px 4px;
                        color: #888;
                        border-bottom: 1px solid #eee;
                    }

                    .cart-table td {
                        padding: 8px 4px;
                        border-bottom: 1px solid #f5f5f5;
                    }

                    .cart-total {
                        font-size: 18px;
                        font-weight: bold;
                        color: #333;
                        margin: 15px 0;
                        text-align: right;
                    }

                    .btn-checkout {
                        display: block;
                        width: 100%;
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                        border: none;
                        padding: 12px;
                        border-radius: 8px;
                        font-size: 16px;
                        cursor: pointer;
                        text-align: center;
                        text-decoration: none;
                        margin-top: 10px;
                    }

                    .btn-checkout:hover {
                        opacity: 0.9;
                    }

                    .btn-cancel {
                        display: block;
                        width: 100%;
                        background: #ef5350;
                        color: white;
                        border: none;
                        padding: 10px;
                        border-radius: 8px;
                        cursor: pointer;
                        margin-top: 8px;
                        font-size: 14px;
                    }

                    .btn-cancel:hover {
                        background: #e53935;
                    }

                    .order-info {
                        background: #f8f9fa;
                        padding: 10px;
                        border-radius: 8px;
                        margin-bottom: 12px;
                        font-size: 13px;
                    }

                    .order-info span {
                        color: #667eea;
                        font-weight: bold;
                    }

                    .error {
                        background: #ffebee;
                        color: #c62828;
                        padding: 12px;
                        border-radius: 8px;
                        margin-bottom: 15px;
                    }
                </style>
            </head>

            <body>
                <div class="header">
                    <h1>🍽️ Restaurant POS - Menu</h1>
                    <div class="nav">
                        <a href="${pageContext.request.contextPath}/tables">Bàn</a>
                        <a href="${pageContext.request.contextPath}/menu?orderId=${order.orderId}"
                            class="active">Menu</a>
                        <a href="${pageContext.request.contextPath}/orders">Đơn hàng</a>
                        <a href="${pageContext.request.contextPath}/admin/product">Sản phẩm</a>
                    </div>
                </div>

                <div class="container">
                    <!-- Menu -->
                    <div class="menu-panel">
                        <c:if test="${not empty error}">
                            <div class="error">${error}</div>
                        </c:if>

                        <h2>🍕 Chọn món</h2>
                        <div class="products-grid">
                            <c:forEach var="product" items="${products}">
                                <div class="product-card">
                                    <div class="product-name">${product.productName}</div>
                                    <c:if test="${not empty product.description}">
                                        <div style="color: #888; font-size: 12px; margin: 4px 0;">${product.description}
                                        </div>
                                    </c:if>
                                    <div class="product-price">
                                        <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true" />
                                        đ
                                    </div>
                                    <c:if test="${not empty order}">
                                        <form method="post" action="${pageContext.request.contextPath}/menu"
                                            class="product-form">
                                            <input type="hidden" name="action" value="addItem">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <input type="hidden" name="productId" value="${product.productId}">
                                            <input type="number" name="quantity" value="1" min="1" max="99">
                                            <button type="submit" class="btn-add">+ Thêm</button>
                                        </form>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Cart -->
                    <c:if test="${not empty order}">
                        <div class="cart-panel">
                            <h2>🛒 Đơn #${order.orderId}</h2>
                            <div class="order-info">
                                Bàn: <span>${order.table.tableName}</span> |
                                Loại: <span>${order.orderType}</span> |
                                Trạng thái: <span>${order.status}</span>
                            </div>

                            <c:if test="${not empty orderDetails}">
                                <table class="cart-table">
                                    <thead>
                                        <tr>
                                            <th>Món</th>
                                            <th>SL</th>
                                            <th>Giá</th>
                                            <th>Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${orderDetails}">
                                            <tr>
                                                <td>${detail.product.productName}</td>
                                                <td>${detail.quantity}</td>
                                                <td>
                                                    <fmt:formatNumber value="${detail.unitPrice}" type="number"
                                                        groupingUsed="true" />đ
                                                </td>
                                                <td>
                                                    <fmt:formatNumber value="${detail.lineTotal}" type="number"
                                                        groupingUsed="true" />đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:if>

                            <div class="cart-total">
                                Tổng:
                                <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" /> đ
                            </div>

                            <c:if test="${order.status == 'OPEN'}">
                                <form method="post" action="${pageContext.request.contextPath}/menu"
                                    style="margin-bottom: 8px;">
                                    <input type="hidden" name="action" value="confirm">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit"
                                        style="display:block; width:100%; background:#FF9800; color:white; border:none; padding:10px; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold;">
                                        ✅ Xác nhận đơn (SERVED)
                                    </button>
                                </form>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/checkout?orderId=${order.orderId}"
                                class="btn-checkout">
                                💳 Thanh toán
                            </a>

                            <c:if test="${order.status == 'OPEN'}">
                                <form method="post" action="${pageContext.request.contextPath}/menu">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn-cancel"
                                        onclick="return confirm('Bạn có chắc muốn hủy đơn?')">
                                        ❌ Hủy đơn
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </c:if>
                </div>
            </body>

            </html>