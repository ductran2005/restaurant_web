<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="sidebarActive" value="invoices" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thanh toán — Thu ngân</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
            </head>

            <body>
                <div class="admin-layout">
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="admin-main">
                            <div class="admin-topbar">
                                <h2 style="font-size:1.125rem"><i class="fa-solid fa-cash-register"></i> Thanh toán —
                                    ${order.table.tableName}</h2>
                                <a href="${pageContext.request.contextPath}/cashier" class="btn btn-outline btn-sm"><i
                                        class="fa-solid fa-arrow-left"></i> Quay lại</a>
                            </div>
                            <div class="admin-content">
                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.5rem;max-width:64rem">
                                    <!-- Order items -->
                                    <div class="form-card" style="padding:0;overflow:hidden">
                                        <div style="padding:1rem 1.25rem;border-bottom:1px solid var(--border)">
                                            <span class="font-bold"><i class="fa-solid fa-utensils"></i> Danh sách món —
                                                Order #${order.id}</span>
                                        </div>
                                        <table class="data-table">
                                            <thead>
                                                <tr>
                                                    <th>Món</th>
                                                    <th style="text-align:right">SL</th>
                                                    <th style="text-align:right">Giá</th>
                                                    <th style="text-align:right">T.Tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="d" items="${order.orderDetails}">
                                                    <c:if test="${d.itemStatus == 'ORDERED'}">
                                                        <tr>
                                                            <td>
                                                                <c:out value="${d.product.productName}" />
                                                            </td>
                                                            <td style="text-align:right">${d.quantity}</td>
                                                            <td style="text-align:right">
                                                                <fmt:formatNumber value="${d.unitPrice}"
                                                                    pattern="#,###" />
                                                            </td>
                                                            <td style="text-align:right;font-weight:700">
                                                                <fmt:formatNumber value="${d.lineTotal}"
                                                                    pattern="#,###" />
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Payment summary (replaces Invoice) -->
                                    <div class="form-card">
                                        <h3 style="margin-bottom:1.25rem"><i
                                                class="fa-solid fa-file-invoice-dollar"></i> Thanh toán</h3>
                                        <div style="display:flex;flex-direction:column;gap:.75rem">
                                            <div style="display:flex;justify-content:space-between"><span
                                                    class="text-muted">Tạm tính:</span><span>
                                                    <fmt:formatNumber value="${order.subtotal}" pattern="#,###" /> đ
                                                </span></div>
                                            <%-- VAT/Service fee: không có trong DB mới (no invoices table) --%>
                                                <div style="display:flex;justify-content:space-between"><span
                                                        class="text-muted">Giảm giá:</span><span>
                                                        <fmt:formatNumber value="${order.discountAmount}"
                                                            pattern="#,###" /> đ
                                                    </span></div>
                                                <hr style="border:1px solid var(--border)">
                                                <div
                                                    style="display:flex;justify-content:space-between;font-size:1.25rem;font-weight:700">
                                                    <span>Tổng cộng:</span><span style="color:#16a34a">
                                                        <fmt:formatNumber value="${order.totalAmount}"
                                                            pattern="#,###" />
                                                        đ
                                                    </span>
                                                </div>
                                        </div>
                                        <c:if test="${order.status != 'PAID'}">
                                            <form method="post" style="margin-top:1.5rem">
                                                <input type="hidden" name="action" value="pay">
                                                <input type="hidden" name="orderId" value="${order.id}">
                                                <div class="form-group">
                                                    <label>Phương thức thanh toán</label>
                                                    <select name="paymentMethod" required>
                                                        <option value="">Chọn...</option>
                                                        <option value="CASH">Tiền mặt</option>
                                                        <option value="CARD">Thẻ</option>
                                                        <option value="TRANSFER">Chuyển khoản</option>
                                                    </select>
                                                </div>
                                                <button type="submit" class="btn btn-primary btn-block"
                                                    style="padding:.875rem;font-size:1rem">
                                                    <i class="fa-solid fa-check-circle"></i> Xác nhận thanh toán
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${order.status == 'PAID'}">
                                            <div style="margin-top:1.5rem;text-align:center;color:#16a34a">
                                                <i class="fa-solid fa-circle-check" style="font-size:2rem"></i>
                                                <p style="margin-top:.5rem;font-weight:600">Đã thanh toán</p>
                                                <c:if test="${not empty payment}">
                                                    <p class="text-muted text-sm">PTTT: ${payment.method} | Mã TT:
                                                        #${payment.id}</p>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                </div>
            </body>

            </html>