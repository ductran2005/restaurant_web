<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="invoices" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Quản lý Order — Thu ngân</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
                <style>
                    .tab-bar {
                        display: flex;
                        gap: 4px;
                        background: var(--surface2);
                        border-radius: 10px;
                        padding: 4px;
                        margin-bottom: 20px;
                        width: fit-content
                    }

                    .tab-link {
                        padding: 8px 18px;
                        border-radius: 8px;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                        transition: all .2s;
                        display: inline-flex;
                        align-items: center;
                        gap: 6px
                    }

                    .tab-link.active {
                        background: var(--primary);
                        color: #000
                    }

                    .tab-link:hover:not(.active) {
                        color: var(--text)
                    }
                </style>
            </head>

            <body>
                <div class="shell">
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="main">
                            <header class="topbar">
                                <button class="burger" onclick="openSidebar()"><i class="fa-solid fa-bars"></i></button>
                                <h1 class="topbar-title"><i class="fa-solid fa-file-invoice-dollar"></i> Quản lý Order
                                </h1>
                                <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <div class="page-header">
                                    <div class="page-header-left">
                                        <h2>Danh sách Order</h2>
                                        <p>Quản lý và thanh toán đơn hàng</p>
                                    </div>
                                </div>

                                <div class="tab-bar">
                                    <a href="${ctx}/cashier" class="tab-link ${activeTab != 'paid' ? 'active' : ''}">
                                        <i class="fa-solid fa-clock"></i> Đang hoạt động
                                    </a>
                                    <a href="${ctx}/cashier?tab=paid"
                                        class="tab-link ${activeTab == 'paid' ? 'active' : ''}">
                                        <i class="fa-solid fa-check-circle"></i> Đã thanh toán
                                    </a>
                                </div>

                                <%-- Active orders tab --%>
                                    <c:if test="${activeTab != 'paid'}">
                                        <div class="table-card">
                                            <table class="admin-table">
                                                <thead>
                                                    <tr>
                                                        <th>Order #</th>
                                                        <th>Bàn</th>
                                                        <th style="text-align:right">Tổng tiền</th>
                                                        <th>Trạng thái</th>
                                                        <th>Thời gian</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="o" items="${orders}">
                                                        <tr>
                                                            <td style="font-weight:600">#${o.id}</td>
                                                            <td>${o.table.tableName}</td>
                                                            <td style="text-align:right;font-weight:600">
                                                                <fmt:formatNumber value="${o.totalAmount}"
                                                                    pattern="#,###" /> đ
                                                            </td>
                                                            <td>
                                                                <span
                                                                    class="badge ${o.status=='OPEN'?'b-info':o.status=='SERVED'?'b-success':'b-muted'}">${o.status}</span>
                                                            </td>
                                                            <td style="color:var(--text-muted)">${o.openedAt}</td>
                                                            <td>
                                                                <c:if test="${o.status == 'SERVED'}">
                                                                    <a href="${ctx}/cashier/checkout?orderId=${o.id}"
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
                                                                    class="fa-solid fa-clipboard"></i>
                                                                <h3>Không có order đang hoạt động</h3>
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:if>

                                    <%-- Paid orders tab --%>
                                        <c:if test="${activeTab == 'paid'}">
                                            <div class="table-card">
                                                <table class="admin-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Order #</th>
                                                            <th>Bàn</th>
                                                            <th style="text-align:right">Tổng tiền</th>
                                                            <th>Trạng thái</th>
                                                            <th>Đóng lúc</th>
                                                            <th>Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="o" items="${paidOrders}">
                                                            <tr>
                                                                <td style="font-weight:600">#${o.id}</td>
                                                                <td>${o.table.tableName}</td>
                                                                <td style="text-align:right;font-weight:600">
                                                                    <fmt:formatNumber value="${o.totalAmount}"
                                                                        pattern="#,###" /> đ
                                                                </td>
                                                                <td><span class="badge b-success">PAID</span></td>
                                                                <td style="color:var(--text-muted)">${o.closedAt}</td>
                                                                <td>
                                                                    <button class="btn btn-ghost btn-sm"><i
                                                                            class="fa-solid fa-print"></i></button>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty paidOrders}">
                                                            <tr>
                                                                <td colspan="6" class="empty-state"><i
                                                                        class="fa-solid fa-file-invoice"></i>
                                                                    <h3>Chưa có order đã thanh toán</h3>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:if>
                            </div>
                        </div>
                </div>
                <script>
                    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }
                </script>
            </body>

            </html>