<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="orders" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Order — Staff</title>
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
                                <h1 class="topbar-title"><i class="fa-solid fa-clipboard-list"></i> Quản lý Order</h1>
                                <div class="topbar-right">
                                    <button class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Tạo
                                        Order</button>
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <div class="table-card">
                                    <table class="admin-table">
                                        <thead>
                                            <tr>
                                                <th>Order ID</th>
                                                <th>Bàn</th>
                                                <th>Số món</th>
                                                <th style="text-align:right">Tổng</th>
                                                <th>Trạng thái</th>
                                                <th>Thời gian</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="o" items="${activeOrders}">
                                                <tr>
                                                    <td style="font-weight:600">#${o.id}</td>
                                                    <td>${o.table.tableName}</td>
                                                    <td>${o.orderDetails.size()}</td>
                                                    <td style="text-align:right;font-weight:600">
                                                        <fmt:formatNumber value="${o.totalAmount}" pattern="#,###" /> đ
                                                    </td>
                                                    <td>
                                                        <span
                                                            class="badge ${o.status=='OPEN'?'b-info':o.status=='SERVED'?'b-success':o.status=='PAID'?'b-primary':'b-muted'}">${o.status}</span>
                                                    </td>
                                                    <td style="color:var(--text-muted)">${o.openedAt}</td>
                                                    <td>
                                                        <button class="btn btn-ghost btn-sm"><i
                                                                class="fa-solid fa-pen"></i> Sửa</button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty activeOrders}">
                                                <tr>
                                                    <td colspan="7" class="empty-state"><i
                                                            class="fa-solid fa-clipboard"></i>
                                                        <h3>Chưa có order nào</h3>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
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