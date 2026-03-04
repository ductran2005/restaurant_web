<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="sidebarActive" value="invoices" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Quản lý Order — Thu ngân</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
            </head>

            <body>
                <div class="admin-layout">
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="admin-main">
                            <div class="admin-topbar">
                                <h2 style="font-size:1.125rem"><i class="fa-solid fa-file-invoice-dollar"></i> Quản lý
                                    Order</h2>
                                <div style="display:flex;gap:.5rem">
                                    <a href="${pageContext.request.contextPath}/cashier"
                                        class="btn ${activeTab != 'paid' ? 'btn-primary' : 'btn-outline'} btn-sm">
                                        <i class="fa-solid fa-clock"></i> Đang hoạt động
                                    </a>
                                    <a href="${pageContext.request.contextPath}/cashier?tab=paid"
                                        class="btn ${activeTab == 'paid' ? 'btn-primary' : 'btn-outline'} btn-sm">
                                        <i class="fa-solid fa-check-circle"></i> Đã thanh toán
                                    </a>
                                </div>
                            </div>
                            <div class="admin-content">
                                <%-- Active orders tab --%>
                                    <c:if test="${activeTab != 'paid'}">
                                        <div class="form-card" style="padding:0;overflow:hidden">
                                            <table class="data-table">
                                                <thead>
                                                    <tr>
                                                        <th>Order #</th>
                                                        <th>Bàn</th>
                                                        <th>Tổng tiền</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thời gian</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="o" items="${orders}">
                                                        <tr>
                                                            <td class="font-bold">#${o.id}</td>
                                                            <td>${o.table.tableName}</td>
                                                            <td class="font-bold">
                                                                <fmt:formatNumber value="${o.totalAmount}"
                                                                    pattern="#,###" /> đ
                                                            </td>
                                                            <td><span
                                                                    class="badge badge-${o.status.toLowerCase()}">${o.status}</span>
                                                            </td>
                                                            <td class="text-sm text-muted">${o.openedAt}</td>
                                                            <td>
                                                                <c:if
                                                                    test="${o.status == 'OPEN' || o.status == 'SERVED'}">
                                                                    <a href="${pageContext.request.contextPath}/cashier/checkout?orderId=${o.id}"
                                                                        class="btn btn-primary btn-sm"><i
                                                                            class="fa-solid fa-cash-register"></i> Thanh
                                                                        toán</a>
                                                                </c:if>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                    <c:if test="${empty orders}">
                                                        <tr>
                                                            <td colspan="6" class="empty-state"><i
                                                                    class="fa-solid fa-clipboard"></i> Không có order
                                                                đang hoạt động</td>
                                                        </tr>
                                                    </c:if>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:if>

                                    <%-- Paid orders tab --%>
                                        <c:if test="${activeTab == 'paid'}">
                                            <div class="form-card" style="padding:0;overflow:hidden">
                                                <table class="data-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Order #</th>
                                                            <th>Bàn</th>
                                                            <th>Tổng tiền</th>
                                                            <th>Trạng thái</th>
                                                            <th>Đóng lúc</th>
                                                            <th>Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="o" items="${paidOrders}">
                                                            <tr>
                                                                <td class="font-bold">#${o.id}</td>
                                                                <td>${o.table.tableName}</td>
                                                                <td class="font-bold">
                                                                    <fmt:formatNumber value="${o.totalAmount}"
                                                                        pattern="#,###" /> đ
                                                                </td>
                                                                <td><span class="badge badge-paid">PAID</span></td>
                                                                <td class="text-sm text-muted">${o.closedAt}</td>
                                                                <td>
                                                                    <button class="btn btn-ghost btn-sm"><i
                                                                            class="fa-solid fa-print"></i></button>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty paidOrders}">
                                                            <tr>
                                                                <td colspan="6" class="empty-state"><i
                                                                        class="fa-solid fa-file-invoice"></i> Chưa có
                                                                    order đã thanh toán</td>
                                                            </tr>
                                                        </c:if>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:if>
                                        <%-- NOTE: DB không có bảng invoices → không còn invoice list VAT, service fee:
                                            không có trong DB mới Payment method: xem bảng payments --%>
                            </div>
                        </div>
                </div>
            </body>

            </html>