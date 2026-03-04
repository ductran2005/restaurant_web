<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="reports" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Báo cáo — Admin</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
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

                    .tab-btn {
                        padding: 8px 18px;
                        border-radius: 8px;
                        border: none;
                        background: none;
                        color: var(--text-muted);
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        font-family: inherit;
                        transition: all .2s
                    }

                    .tab-btn.active {
                        background: var(--primary);
                        color: #000
                    }

                    .tab-content {
                        display: none
                    }

                    .tab-content.active {
                        display: block
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
                                <h1 class="topbar-title"><i class="fa-solid fa-chart-bar"></i> Báo cáo</h1>
                                <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <div class="page-header">
                                    <div class="page-header-left">
                                        <h2>Thống kê & Báo cáo</h2>
                                        <p>Tổng hợp doanh thu và hoạt động</p>
                                    </div>
                                    <div style="display:flex;gap:8px">
                                        <a href="${ctx}/admin/reports/export?format=csv" class="btn btn-ghost"><i
                                                class="fa-solid fa-download"></i> CSV</a>
                                        <a href="${ctx}/admin/reports/export?format=xlsx" class="btn btn-ghost"><i
                                                class="fa-solid fa-download"></i> XLSX</a>
                                    </div>
                                </div>
                                <form method="get" action="${ctx}/admin/reports"
                                    style="display:flex;align-items:center;gap:12px;margin-bottom:20px;flex-wrap:wrap">
                                    <select name="period" class="form-control" style="width:150px">
                                        <option value="day" ${param.period !='month' ? 'selected' : '' }>Theo ngày
                                        </option>
                                        <option value="month" ${param.period=='month' ? 'selected' : '' }>Theo tháng
                                        </option>
                                    </select>
                                    <input type="date" name="from" class="form-control" style="width:150px"
                                        value="${param.from}">
                                    <span style="color:var(--text-muted)">đến</span>
                                    <input type="date" name="to" class="form-control" style="width:150px"
                                        value="${param.to}">
                                    <button type="submit" class="btn btn-ghost"><i class="fa-solid fa-filter"></i>
                                        Lọc</button>
                                </form>
                                <div class="tab-bar">
                                    <button class="tab-btn active" onclick="switchTab('revenue',this)">Doanh
                                        thu</button>
                                    <button class="tab-btn" onclick="switchTab('topitems',this)">Top món bán
                                        chạy</button>
                                </div>
                                <div class="tab-content active" id="tab-revenue">
                                    <div class="charts-grid" style="margin-bottom:24px">
                                        <div class="chart-card">
                                            <div class="chart-title"><i class="fa-solid fa-chart-bar"></i> Doanh thu
                                            </div><canvas id="revenueChart" height="220"></canvas>
                                        </div>
                                        <div class="chart-card">
                                            <div class="chart-title"><i class="fa-solid fa-chart-line"></i> Số đơn</div>
                                            <canvas id="ordersChart" height="220"></canvas>
                                        </div>
                                    </div>
                                    <div class="table-card">
                                        <table class="admin-table">
                                            <thead>
                                                <tr>
                                                    <th>Ngày</th>
                                                    <th style="text-align:right">Số đơn</th>
                                                    <th style="text-align:right">Doanh thu</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="d" items="${revenueData}">
                                                    <tr>
                                                        <td>${d.date}</td>
                                                        <td style="text-align:right">${d.orders}</td>
                                                        <td style="text-align:right">
                                                            <fmt:formatNumber value="${d.revenue}" pattern="#,###" />đ
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${not empty revenueData}">
                                                    <tr style="background:var(--surface2)">
                                                        <td style="font-weight:700">Tổng</td>
                                                        <td style="text-align:right;font-weight:700">${totalOrders}</td>
                                                        <td style="text-align:right;font-weight:700">
                                                            <fmt:formatNumber value="${totalRevenue}" pattern="#,###" />
                                                            đ
                                                        </td>
                                                    </tr>
                                                </c:if>
                                                <c:if test="${empty revenueData}">
                                                    <tr>
                                                        <td colspan="3" class="empty-state">Chưa có dữ liệu</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="tab-content" id="tab-topitems">
                                    <div class="table-card">
                                        <table class="admin-table">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tên món</th>
                                                    <th style="text-align:right">SL bán</th>
                                                    <th style="text-align:right">Doanh thu</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${topItems}" varStatus="i">
                                                    <tr>
                                                        <td><span
                                                                style="display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:6px;font-size:11px;font-weight:700;${i.index<3?'background:var(--primary);color:#000':'background:var(--surface2);color:var(--text-muted)'}">${i.index+1}</span>
                                                        </td>
                                                        <td style="font-weight:600">${item.name}</td>
                                                        <td style="text-align:right">${item.quantity}</td>
                                                        <td style="text-align:right">
                                                            <fmt:formatNumber value="${item.revenue}" pattern="#,###" />
                                                            đ
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty topItems}">
                                                    <tr>
                                                        <td colspan="4" class="empty-state">Chưa có dữ liệu</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                </div>
                <script>
                    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }
                    function switchTab(n, b) { document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active')); document.querySelectorAll('.tab-btn').forEach(t => t.classList.remove('active')); document.getElementById('tab-' + n).classList.add('active'); b.classList.add('active') }
                    const cl = ${ not empty chartLabels?chartLabels:'[]'}, cr = ${ not empty chartRevenue?chartRevenue:'[]'}, co = ${ not empty chartOrders?chartOrders:'[]'};
                    if (cl.length) { new Chart(document.getElementById('revenueChart'), { type: 'bar', data: { labels: cl, datasets: [{ label: 'Doanh thu', data: cr, backgroundColor: 'rgba(232,160,32,.7)', borderRadius: 6 }] }, options: { plugins: { legend: { display: false } }, scales: { x: { grid: { color: 'rgba(255,255,255,.06)' }, ticks: { color: '#9e9488' } }, y: { grid: { color: 'rgba(255,255,255,.06)' }, ticks: { color: '#9e9488' } } } } }); new Chart(document.getElementById('ordersChart'), { type: 'line', data: { labels: cl, datasets: [{ label: 'Orders', data: co, borderColor: '#3b82f6', backgroundColor: 'rgba(59,130,246,.1)', fill: true, tension: .4, pointRadius: 4 }] }, options: { plugins: { legend: { display: false } }, scales: { x: { grid: { color: 'rgba(255,255,255,.06)' }, ticks: { color: '#9e9488' } }, y: { grid: { color: 'rgba(255,255,255,.06)' }, ticks: { color: '#9e9488' } } } } }) }
                </script>
            </body>

            </html>