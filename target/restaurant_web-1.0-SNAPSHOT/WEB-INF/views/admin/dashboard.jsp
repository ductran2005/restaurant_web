<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="dashboard" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Dashboard — Admin Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
            </head>

            <body>
                <div class="shell">
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>

                        <%-- Main --%>
                            <div class="main">
                                <header class="topbar">
                                    <button class="burger" onclick="openSidebar()"><i
                                            class="fa-solid fa-bars"></i></button>
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
                                                <div class="kpi-icon"
                                                    style="background:rgba(22,163,74,0.12);color:#16a34a">
                                                    <i class="fa-solid fa-sack-dollar"></i>
                                                </div>
                                                <div class="kpi-body">
                                                    <div class="kpi-label">Doanh thu hôm nay</div>
                                                    <div class="kpi-value">
                                                        <fmt:formatNumber value="${totalRevenue}" pattern="#,###" /> đ
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="kpi-card">
                                                <div class="kpi-icon"
                                                    style="background:rgba(232,160,32,0.12);color:#e8a020"><i
                                                        class="fa-solid fa-calendar-check"></i></div>
                                                <div class="kpi-body">
                                                    <div class="kpi-label">Booking hôm nay</div>
                                                    <div class="kpi-value">${totalBookings}</div>
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
                                                    <div class="chart-title"><i class="fa-solid fa-chart-bar"></i> Doanh
                                                        thu
                                                        7 ngày qua</div>
                                                    <canvas id="revenueChart" height="220"></canvas>
                                                </div>
                                                <div class="chart-card">
                                                    <div class="chart-title"><i class="fa-solid fa-chart-line"></i> Số
                                                        order
                                                        7 ngày qua</div>
                                                    <canvas id="ordersChart" height="220"></canvas>
                                                </div>
                                            </div>
                                </div>
                            </div>
                </div>

                <script>
                    const chartLabels = JSON.parse('${chartLabels}');
                    const chartRevenue = JSON.parse('${chartRevenue}');
                    const chartOrders = JSON.parse('${chartOrders}');
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