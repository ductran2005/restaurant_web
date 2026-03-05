<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="checkout" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thanh toán — Thu ngân</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
            </head>

            <body>
                <div class="shell">
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="main">
                            <header class="topbar">
                                <button class="burger" onclick="openSidebar()"><i class="fa-solid fa-bars"></i></button>
                                <h1 class="topbar-title"><i class="fa-solid fa-cash-register"></i> Thanh toán —
                                    ${order.table.tableName}</h1>
                                <div class="topbar-right">
                                    <a href="${ctx}/cashier" class="btn btn-ghost btn-sm"><i
                                            class="fa-solid fa-arrow-left"></i> Quay lại</a>
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;max-width:960px">
                                    <!-- Order items -->
                                    <div class="table-card">
                                        <div class="table-card-header">
                                            <span style="font-weight:700"><i class="fa-solid fa-utensils"></i> Danh sách
                                                món — Order #${order.id}</span>
                                        </div>
                                        <table class="admin-table">
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
                                                            <td style="font-weight:600">
                                                                <c:out value="${d.product.productName}" />
                                                            </td>
                                                            <td style="text-align:right">${d.quantity}</td>
                                                            <td style="text-align:right;color:var(--text-muted)">
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

                                    <!-- Payment summary -->
                                    <div class="table-card" style="padding:24px">
                                        <h3
                                            style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                            <i class="fa-solid fa-file-invoice-dollar" style="color:var(--primary)"></i>
                                            Thanh toán
                                        </h3>

                                        <div class="money-breakdown">
                                            <div class="breakdown-row">
                                                <span>Tạm tính:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.subtotal}" pattern="#,###" /> đ
                                                </span>
                                            </div>
                                            <div class="breakdown-row">
                                                <span>Giảm giá:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.discountAmount}" pattern="#,###" />
                                                    đ
                                                </span>
                                            </div>
                                            <div class="breakdown-row total">
                                                <span>Tổng cộng:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.totalAmount}" pattern="#,###" /> đ
                                                </span>
                                            </div>
                                        </div>

                                        <c:if test="${order.status != 'PAID'}">
                                            <form method="post" style="margin-top:20px">
                                                <input type="hidden" name="action" value="pay">
                                                <input type="hidden" name="orderId" value="${order.id}">
                                                <div class="form-group">
                                                    <label class="form-label">Phương thức thanh toán <span
                                                            style="color:var(--destructive)">*</span></label>
                                                    <select name="paymentMethod" class="form-control" required>
                                                        <option value="">Chọn...</option>
                                                        <option value="CASH">Tiền mặt</option>
                                                        <option value="CARD">Thẻ</option>
                                                        <option value="TRANSFER">Chuyển khoản</option>
                                                    </select>
                                                </div>
                                                <button type="submit" class="btn btn-primary"
                                                    style="width:100%;padding:12px;font-size:14px;justify-content:center">
                                                    <i class="fa-solid fa-check-circle"></i> Xác nhận thanh toán
                                                </button>
                                            </form>
                                        </c:if>

                                        <c:if test="${order.status == 'PAID'}">
                                            <div
                                                style="margin-top:20px;text-align:center;color:var(--success);padding:20px">
                                                <i class="fa-solid fa-circle-check" style="font-size:2.5rem"></i>
                                                <p style="margin-top:8px;font-weight:700;font-size:16px">Đã thanh toán
                                                </p>
                                                <c:if test="${not empty payment}">
                                                    <p style="color:var(--text-muted);font-size:13px;margin-top:4px">
                                                        PTTT: ${payment.method} | Mã TT: #${payment.id}</p>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                </div>
                <script>
                    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }
                </script>
            </body>

            </html>