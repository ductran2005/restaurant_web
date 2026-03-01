<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Thanh toán - Restaurant POS</title>
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

                    .nav a:hover {
                        color: white;
                    }

                    .container {
                        max-width: 1100px;
                        margin: 30px auto;
                        padding: 0 20px;
                    }

                    .alert {
                        padding: 12px 20px;
                        border-radius: 8px;
                        margin-bottom: 20px;
                    }

                    .alert--error {
                        background: rgba(239, 68, 68, 0.15);
                        color: #f87171;
                        border: 1px solid rgba(239, 68, 68, 0.3);
                    }

                    /* Tabs */
                    .tabs {
                        display: flex;
                        gap: 8px;
                        margin-bottom: 20px;
                    }

                    .tab {
                        padding: 12px 24px;
                        border: 2px solid #334155;
                        border-radius: 10px;
                        background: transparent;
                        color: #94a3b8;
                        cursor: pointer;
                        font-size: 15px;
                        font-weight: 600;
                        transition: all 0.3s;
                    }

                    .tab:hover {
                        border-color: #667eea;
                        color: #e2e8f0;
                    }

                    .tab--active {
                        background: rgba(102, 126, 234, 0.15);
                        border-color: #667eea;
                        color: #667eea;
                    }

                    .tab-panel {
                        display: none;
                    }

                    .tab-panel--active {
                        display: block;
                    }

                    /* Grid layout */
                    .checkout-grid {
                        display: grid;
                        grid-template-columns: 1.4fr 1fr;
                        gap: 24px;
                        align-items: start;
                    }

                    /* Cards */
                    .card {
                        background: #1e293b;
                        border-radius: 16px;
                        padding: 24px;
                        border: 1px solid #334155;
                    }

                    .section-title {
                        font-size: 18px;
                        font-weight: 700;
                        margin-bottom: 16px;
                        color: #f1f5f9;
                    }

                    /* Order details table */
                    .detail-table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    .detail-table th {
                        text-align: left;
                        padding: 10px 8px;
                        color: #94a3b8;
                        border-bottom: 1px solid #334155;
                        font-size: 13px;
                    }

                    .detail-table td {
                        padding: 10px 8px;
                        border-bottom: 1px solid #1e293b;
                        font-size: 14px;
                    }

                    .detail-table tr:hover {
                        background: rgba(102, 126, 234, 0.05);
                    }

                    .text-right {
                        text-align: right;
                    }

                    .text-center {
                        text-align: center;
                    }

                    /* Total box */
                    .total-box {
                        background: rgba(102, 126, 234, 0.1);
                        border: 1px solid rgba(102, 126, 234, 0.2);
                        border-radius: 12px;
                        padding: 20px;
                        margin-bottom: 20px;
                    }

                    .total-row {
                        display: flex;
                        justify-content: space-between;
                        margin-bottom: 8px;
                    }

                    .total-label {
                        color: #94a3b8;
                        font-size: 15px;
                    }

                    .total-value {
                        color: #f1f5f9;
                        font-size: 15px;
                        font-weight: 600;
                    }

                    .total-final {
                        font-size: 28px;
                        color: #667eea;
                        font-weight: 800;
                    }

                    /* Method indicator */
                    .method-badge {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 14px;
                        background: rgba(102, 126, 234, 0.1);
                        border: 1px solid rgba(102, 126, 234, 0.2);
                        border-radius: 10px;
                        margin-bottom: 16px;
                    }

                    .method-badge--vnpay {
                        background: rgba(0, 92, 185, 0.1);
                        border-color: rgba(0, 92, 185, 0.3);
                    }

                    .method-icon {
                        font-size: 24px;
                    }

                    .method-text {
                        font-size: 16px;
                        font-weight: 600;
                        color: #f1f5f9;
                    }

                    /* Buttons */
                    .btn {
                        padding: 14px 28px;
                        border: none;
                        border-radius: 10px;
                        cursor: pointer;
                        font-size: 16px;
                        font-weight: 700;
                        transition: all 0.3s;
                        text-decoration: none;
                        display: inline-block;
                        text-align: center;
                    }

                    .btn--success {
                        background: linear-gradient(135deg, #10b981, #059669);
                        color: white;
                        width: 100%;
                    }

                    .btn--success:hover {
                        opacity: 0.9;
                        transform: translateY(-1px);
                    }

                    .btn--vnpay {
                        background: linear-gradient(135deg, #005cb9, #0072e5);
                        color: white;
                        width: 100%;
                    }

                    .btn--vnpay:hover {
                        opacity: 0.9;
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

                    .actions {
                        display: flex;
                        flex-direction: column;
                        gap: 10px;
                        margin-top: 16px;
                    }

                    /* Sandbox info */
                    .sandbox-info {
                        margin-top: 16px;
                        font-size: 12px;
                        color: #64748b;
                        background: rgba(0, 92, 185, 0.06);
                        border: 1px dashed #334155;
                        border-radius: 8px;
                        padding: 10px;
                        line-height: 1.6;
                    }

                    @media(max-width: 768px) {
                        .checkout-grid {
                            grid-template-columns: 1fr;
                        }
                    }
                </style>
            </head>

            <body>
                <div class="header">
                    <h1>🍽️ Restaurant POS</h1>
                    <div class="nav">
                        <a href="${pageContext.request.contextPath}/tables">Bàn</a>
                        <a href="${pageContext.request.contextPath}/orders">Đơn hàng</a>
                        <a href="${pageContext.request.contextPath}/admin/product">Sản phẩm</a>
                    </div>
                </div>

                <div class="container">
                    <h1 style="font-size:22px; margin-bottom:20px;">💳 Thanh toán — Đơn #${orderId}</h1>

                    <c:if test="${not empty error}">
                        <div class="alert alert--error">⚠️ ${error}</div>
                    </c:if>

                    <!-- Tabs -->
                    <div class="tabs" id="paymentTabs">
                        <button class="tab tab--active" data-target="tab-cash">💵 Tiền mặt</button>
                        <button class="tab" data-target="tab-vnpay">🏦 VNPay</button>
                    </div>

                    <div class="checkout-grid">
                        <!-- CỘT TRÁI: CHI TIẾT ĐƠN -->
                        <div class="card">
                            <h2 class="section-title">🧾 Chi tiết đơn hàng</h2>
                            <c:choose>
                                <c:when test="${not empty orderDetails}">
                                    <table class="detail-table">
                                        <thead>
                                            <tr>
                                                <th>Món</th>
                                                <th class="text-right">Đơn giá</th>
                                                <th class="text-center">SL</th>
                                                <th class="text-right">Thành tiền</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${orderDetails}">
                                                <tr>
                                                    <td>${item.product.productName}</td>
                                                    <td class="text-right">
                                                        <fmt:formatNumber value="${item.unitPrice}" type="number"
                                                            groupingUsed="true" />đ
                                                    </td>
                                                    <td class="text-center">x${item.quantity}</td>
                                                    <td class="text-right" style="color:#667eea; font-weight:600;">
                                                        <fmt:formatNumber value="${item.lineTotal}" type="number"
                                                            groupingUsed="true" />đ
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <p style="color:#64748b;">Đơn hàng trống.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- CỘT PHẢI: THANH TOÁN -->
                        <div class="card">
                            <div class="total-box">
                                <div class="total-row">
                                    <span class="total-label">Tổng cộng</span>
                                    <span class="total-value">
                                        <fmt:formatNumber value="${totalAmount}" type="number" groupingUsed="true" />đ
                                    </span>
                                </div>
                                <div class="total-row"
                                    style="margin-top:12px; padding-top:12px; border-top:1px solid rgba(102,126,234,0.2);">
                                    <span class="total-label" style="font-size:16px;">Cần thanh toán</span>
                                    <span class="total-final">
                                        <fmt:formatNumber value="${totalAmount}" type="number" groupingUsed="true" />đ
                                    </span>
                                </div>
                            </div>

                            <%-- TAB TIỀN MẶT --%>
                                <div class="tab-panel tab-panel--active" id="tab-cash">
                                    <div class="method-badge">
                                        <span class="method-icon">💵</span>
                                        <span class="method-text">Tiền mặt</span>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/checkout" method="post">
                                        <input type="hidden" name="orderId" value="${orderId}" />
                                        <div class="actions">
                                            <button type="submit" class="btn btn--success">✅ Xác nhận thanh
                                                toán</button>
                                            <a href="${pageContext.request.contextPath}/menu?orderId=${orderId}"
                                                class="btn btn--outline">← Quay lại</a>
                                        </div>
                                    </form>
                                </div>

                                <%-- TAB VNPAY --%>
                                    <div class="tab-panel" id="tab-vnpay">
                                        <div class="method-badge method-badge--vnpay">
                                            <span class="method-icon">🏦</span>
                                            <span class="method-text">VNPay</span>
                                        </div>
                                        <p style="font-size:14px; color:#94a3b8; margin-bottom:16px;">
                                            Thanh toán qua cổng VNPay — hỗ trợ ATM, Visa, MasterCard, QR Pay
                                        </p>
                                        <form action="${pageContext.request.contextPath}/vnpay-pay" method="post">
                                            <input type="hidden" name="orderId" value="${orderId}" />
                                            <input type="hidden" name="amount" value="${totalAmount.longValue()}" />
                                            <div class="actions">
                                                <button type="submit" class="btn btn--vnpay">🏦 Thanh toán qua
                                                    VNPay</button>
                                                <a href="${pageContext.request.contextPath}/menu?orderId=${orderId}"
                                                    class="btn btn--outline">← Quay lại</a>
                                            </div>
                                        </form>
                                        <div class="sandbox-info">
                                            <strong>🧪 Test sandbox:</strong> NCB | 9704198526191432198 | NGUYEN VAN A |
                                            07/15 | OTP: 123456
                                        </div>
                                    </div>
                        </div>
                    </div>
                </div>

                <script>
                    (function () {
                        var tabs = document.querySelectorAll('.tab');
                        var panels = document.querySelectorAll('.tab-panel');
                        tabs.forEach(function (tab) {
                            tab.addEventListener('click', function () {
                                tabs.forEach(function (t) { t.classList.remove('tab--active'); });
                                panels.forEach(function (p) { p.classList.remove('tab-panel--active'); });
                                this.classList.add('tab--active');
                                document.getElementById(this.dataset.target).classList.add('tab-panel--active');
                            });
                        });
                    })();
                </script>
            </body>

            </html>