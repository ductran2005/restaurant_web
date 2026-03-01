<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Hoá đơn - Restaurant POS</title>
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
                        max-width: 600px;
                        margin: 30px auto;
                        padding: 0 20px;
                    }

                    .receipt {
                        background: #1e293b;
                        border-radius: 16px;
                        padding: 32px;
                        border: 1px solid #334155;
                    }

                    .receipt__header {
                        text-align: center;
                        margin-bottom: 20px;
                    }

                    .receipt__header h2 {
                        font-size: 22px;
                        color: #667eea;
                    }

                    .receipt__header p {
                        color: #94a3b8;
                        font-size: 14px;
                        margin-top: 4px;
                    }

                    .receipt__divider {
                        border: none;
                        border-top: 1px dashed #334155;
                        margin: 16px 0;
                    }

                    .receipt__section {
                        margin-bottom: 12px;
                    }

                    .receipt__section-title {
                        font-size: 14px;
                        color: #667eea;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        margin-bottom: 10px;
                    }

                    .receipt__table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    .receipt__table td {
                        padding: 8px 4px;
                        font-size: 14px;
                    }

                    .receipt__label {
                        color: #94a3b8;
                    }

                    .receipt__value {
                        text-align: right;
                        color: #f1f5f9;
                        font-weight: 500;
                    }

                    .receipt__discount {
                        color: #f87171;
                    }

                    .receipt__total {
                        color: #667eea;
                        font-size: 20px;
                        font-weight: 800;
                    }

                    .receipt__total-row td {
                        border-top: 1px solid #334155;
                        padding-top: 12px;
                    }

                    .badge {
                        padding: 8px 20px;
                        border-radius: 8px;
                        font-weight: 700;
                        font-size: 15px;
                        display: inline-block;
                    }

                    .badge--success {
                        background: rgba(16, 185, 129, 0.15);
                        color: #10b981;
                        border: 1px solid rgba(16, 185, 129, 0.3);
                    }

                    .badge--error {
                        background: rgba(239, 68, 68, 0.15);
                        color: #f87171;
                    }

                    .badge--warning {
                        background: rgba(251, 191, 36, 0.15);
                        color: #fbbf24;
                    }

                    .receipt__status {
                        text-align: center;
                        margin: 20px 0;
                    }

                    .receipt__actions {
                        display: flex;
                        gap: 10px;
                        justify-content: center;
                        margin-top: 20px;
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

                    @media print {
                        body {
                            background: white;
                            color: #333;
                        }

                        .header,
                        .receipt__actions {
                            display: none;
                        }

                        .receipt {
                            border: none;
                            box-shadow: none;
                            background: white;
                        }

                        .receipt__label {
                            color: #666;
                        }

                        .receipt__value {
                            color: #333;
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
                    <c:choose>
                        <c:when test="${not empty payment}">
                            <div class="receipt">
                                <div class="receipt__header">
                                    <h2>Restaurant iPOS</h2>
                                    <p>Cảm ơn quý khách!</p>
                                </div>

                                <hr class="receipt__divider" />

                                <!-- Thông tin đơn hàng -->
                                <div class="receipt__section">
                                    <h3 class="receipt__section-title">Thông tin đơn hàng</h3>
                                    <table class="receipt__table">
                                        <tr>
                                            <td class="receipt__label">Mã thanh toán</td>
                                            <td class="receipt__value">#${payment.paymentId}</td>
                                        </tr>
                                        <tr>
                                            <td class="receipt__label">Mã đơn hàng</td>
                                            <td class="receipt__value">#${payment.orderId}</td>
                                        </tr>
                                        <tr>
                                            <td class="receipt__label">Thu ngân</td>
                                            <td class="receipt__value">ID: ${payment.cashierId}</td>
                                        </tr>
                                        <tr>
                                            <td class="receipt__label">Thời gian</td>
                                            <td class="receipt__value">${payment.paidAt}</td>
                                        </tr>
                                    </table>
                                </div>

                                <hr class="receipt__divider" />

                                <!-- Chi tiết thanh toán -->
                                <div class="receipt__section">
                                    <h3 class="receipt__section-title">Chi tiết thanh toán</h3>
                                    <table class="receipt__table">
                                        <tr>
                                            <td class="receipt__label">Phương thức</td>
                                            <td class="receipt__value">
                                                <c:choose>
                                                    <c:when test="${payment.method == 'CASH'}">💵 Tiền mặt</c:when>
                                                    <c:when test="${payment.method == 'CARD'}">💳 Thẻ</c:when>
                                                    <c:when test="${payment.method == 'TRANSFER'}">📱 Chuyển khoản
                                                    </c:when>
                                                    <c:when test="${payment.method == 'VNPAY'}">🏦 VNPay</c:when>
                                                    <c:otherwise>${payment.method}</c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="receipt__label">Tổng tiền hàng</td>
                                            <td class="receipt__value">
                                                <fmt:formatNumber value="${payment.amountPaid}" type="number"
                                                    groupingUsed="true" /> đ
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="receipt__label">Giảm giá</td>
                                            <td class="receipt__value receipt__discount">
                                                -
                                                <fmt:formatNumber value="${payment.discountAmount}" type="number"
                                                    groupingUsed="true" /> đ
                                            </td>
                                        </tr>
                                        <tr class="receipt__total-row">
                                            <td class="receipt__label"><strong>Thành tiền</strong></td>
                                            <td class="receipt__value receipt__total">
                                                <fmt:formatNumber value="${payment.finalAmount}" type="number"
                                                    groupingUsed="true" /> đ
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                                <c:if test="${not empty payment.transactionRef}">
                                    <hr class="receipt__divider" />
                                    <div class="receipt__section">
                                        <p class="receipt__label">Mã giao dịch: <strong
                                                style="color:#f1f5f9;">${payment.transactionRef}</strong></p>
                                    </div>
                                </c:if>

                                <hr class="receipt__divider" />

                                <!-- Trạng thái -->
                                <div class="receipt__status">
                                    <c:choose>
                                        <c:when test="${payment.paymentStatus == 'SUCCESS'}">
                                            <span class="badge badge--success">✅ Thanh toán thành công</span>
                                        </c:when>
                                        <c:when test="${payment.paymentStatus == 'FAILED'}">
                                            <span class="badge badge--error">❌ Thanh toán thất bại</span>
                                        </c:when>
                                        <c:when test="${payment.paymentStatus == 'REFUNDED'}">
                                            <span class="badge badge--warning">↩️ Đã hoàn tiền</span>
                                        </c:when>
                                    </c:choose>
                                </div>

                                <!-- Hành động -->
                                <div class="receipt__actions">
                                    <button class="btn btn--outline" onclick="window.print()">🖨️ In hoá đơn</button>
                                    <a href="${pageContext.request.contextPath}/tables" class="btn btn--primary">← Về
                                        trang bàn</a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="text-align:center; padding:40px;">
                                <p style="color:#f87171; font-size:18px;">Không tìm thấy thông tin thanh toán.</p>
                                <a href="${pageContext.request.contextPath}/tables" class="btn btn--primary"
                                    style="margin-top:16px;">← Quay lại</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </body>

            </html>