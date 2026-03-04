<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Dashboard — Admin Hương Việt</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
            <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
        </head>

        <body>
            <div class="shell">

                <%-- Sidebar --%>
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                    <aside class="sidebar" id="sidebar">
                        <div class="sidebar-logo">
                            <div class="sidebar-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                            <div>
                                <div class="sidebar-logo-name">Hương Việt</div>
                                <div class="sidebar-logo-role">${sessionScope.user.role.name}</div>
                            </div>
                        </div>

                        <nav class="sidebar-nav">
                            <c:if test="${sessionScope.user.role.name == 'ADMIN'}">
                                <div class="nav-group-label">Quản trị</div>
                                <a href="${ctx}/admin"
                                    class="nav-item ${pageContext.request.servletPath.contains('/admin') && !pageContext.request.servletPath.contains('/admin/') ? 'active' : ''}">
                                    <i class="fa-solid fa-chart-line"></i> Dashboard
                                </a>
                                <a href="${ctx}/admin/categories" class="nav-item">
                                    <i class="fa-solid fa-tags"></i> Danh mục
                                </a>
                                <a href="${ctx}/admin/menu" class="nav-item">
                                    <i class="fa-solid fa-book-open"></i> Thực đơn
                                </a>
                                <a href="${ctx}/admin/tables" class="nav-item">
                                    <i class="fa-solid fa-chair"></i> Bàn & Khu vực
                                </a>
                                <a href="${ctx}/admin/users" class="nav-item">
                                    <i class="fa-solid fa-users"></i> Người dùng
                                </a>
                                <%-- Phân quyền & Cấu hình: đã xóa controller (không có table permissions/system_configs
                                    trong DB) --%>
                            </c:if>

                            <c:if test="${sessionScope.user.role.name == 'STAFF'}">
                                <div class="nav-group-label">Nhân viên</div>
                                <a href="${ctx}/staff" class="nav-item active">
                                    <i class="fa-solid fa-map"></i> Sơ đồ bàn
                                </a>
                                <%-- Booking: đã xóa controller (không có bảng bookings trong DB) --%>
                                    <a href="${ctx}/staff/orders" class="nav-item">
                                        <i class="fa-solid fa-clipboard-list"></i> Quản lý Order
                                    </a>
                            </c:if>

                            <c:if test="${sessionScope.user.role.name == 'CASHIER'}">
                                <div class="nav-group-label">Thu ngân</div>
                                <a href="${ctx}/cashier" class="nav-item active">
                                    <i class="fa-solid fa-file-invoice-dollar"></i> Hóa đơn
                                </a>
                                <a href="${ctx}/cashier/checkout" class="nav-item">
                                    <i class="fa-solid fa-cash-register"></i> Thanh toán
                                </a>
                            </c:if>
                        </nav>

                        <div class="sidebar-user">
                            <div class="sidebar-avatar">${sessionScope.user.fullName.substring(0,1)}</div>
                            <div>
                                <div class="sidebar-user-name">${sessionScope.user.fullName}</div>
                                <div class="sidebar-user-role">${sessionScope.user.role.name}</div>
                            </div>
                            <a href="${ctx}/logout" title="Đăng xuất" style="margin-left:auto;color:#9e9488"><i
                                    class="fa-solid fa-right-from-bracket"></i></a>
                        </div>
                    </aside>

                    <%-- Main --%>
                        <div class="main">
                            <header class="topbar">
                                <button class="burger" onclick="openSidebar()"><i class="fa-solid fa-bars"></i></button>
                                <h1 class="topbar-title">Dashboard</h1>
                                <div class="topbar-right">
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>

                            <div class="content">
                                <%-- KPI Cards --%>
                                    <div class="kpi-grid">
                                        <div class="kpi-card">
                                            <div class="kpi-icon"
                                                style="background:rgba(59,130,246,0.12);color:#3b82f6"><i
                                                    class="fa-solid fa-receipt"></i></div>
                                            <div class="kpi-body">
                                                <div class="kpi-label">Order hôm nay</div>
                                                <div class="kpi-value">${totalOrders}</div>
                                            </div>
                                        </div>
                                        <div class="kpi-card">
                                            <div class="kpi-icon" style="background:rgba(22,163,74,0.12);color:#16a34a">
                                                <i class="fa-solid fa-sack-dollar"></i>
                                            </div>
                                            <div class="kpi-body">
                                                <div class="kpi-label">Doanh thu hôm nay</div>
                                                <div class="kpi-value">
                                                    <fmt:formatNumber value="${totalRevenue}" pattern="#,###"
                                                        xmlns:fmt="jakarta.tags.fmt" /> đ
                                                </div>
                                            </div>
                                        </div>
                                        <div class="kpi-card">
                                            <div class="kpi-icon"
                                                style="background:rgba(232,160,32,0.12);color:#e8a020"><i
                                                    class="fa-solid fa-calendar-check"></i></div>
                                            <div class="kpi-body">
                                                <div class="kpi-label">Booking hôm nay</div>
                                                <div class="kpi-value">${totalBookings} <span
                                                        style="font-size:.6em;color:#9e9488">(chưa hỗ trợ)</span></div>
                                            </div>
                                        </div>
                                        <div class="kpi-card">
                                            <div class="kpi-icon"
                                                style="background:rgba(168,85,247,0.12);color:#a855f7"><i
                                                    class="fa-solid fa-utensils"></i></div>
                                            <div class="kpi-body">
                                                <div class="kpi-label">Sản phẩm đang bán</div>
                                                <div class="kpi-value">${activeProducts}</div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Charts --%>
                                        <div class="charts-grid">
                                            <div class="chart-card">
                                                <div class="chart-title"><i class="fa-solid fa-chart-bar"></i> Doanh thu
                                                    7 ngày qua</div>
                                                <canvas id="revenueChart" height="220"></canvas>
                                            </div>
                                            <div class="chart-card">
                                                <div class="chart-title"><i class="fa-solid fa-chart-line"></i> Số order
                                                    7 ngày qua</div>
                                                <canvas id="ordersChart" height="220"></canvas>
                                            </div>
                                        </div>
                            </div>
                        </div>
            </div>

            <script>
                const chartLabels = ${ chartLabels };
                const chartRevenue = ${ chartRevenue };
                const chartOrders = ${ chartOrders };
                const gridColor = 'rgba(255,255,255,0.06)';
                const textColor = '#9e9488';

                new Chart(document.getElementById('revenueChart'), {
                    type: 'bar',
                    data: { labels: chartLabels, datasets: [{ label: 'Doanh thu (đ)', data: chartRevenue, backgroundColor: 'rgba(232,160,32,0.7)', borderRadius: 6 }] },
                    options: { plugins: { legend: { display: false } }, scales: { x: { grid: { color: gridColor }, ticks: { color: textColor } }, y: { grid: { color: gridColor }, ticks: { color: textColor } } } }
                });
                new Chart(document.getElementById('ordersChart'), {
                    type: 'line',
                    data: { labels: chartLabels, datasets: [{ label: 'Orders', data: chartOrders, borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,0.1)', fill: true, tension: 0.4, pointRadius: 4 }] },
                    options: { plugins: { legend: { display: false } }, scales: { x: { grid: { color: gridColor }, ticks: { color: textColor } }, y: { grid: { color: gridColor }, ticks: { color: textColor } } } }
                });

                function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }
            </script>
        </body>

        </html>