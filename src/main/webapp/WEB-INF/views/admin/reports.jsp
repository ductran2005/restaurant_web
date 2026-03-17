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
                    /* Report Layout Styles */
                    .filter-bar {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                        background: var(--surface2);
                        padding: 12px 20px;
                        border-radius: 12px;
                        margin-bottom: 24px;
                        flex-wrap: wrap;
                        border: 1px solid var(--border);
                    }

                    .tab-bar {
                        display: flex;
                        gap: 6px;
                        background: rgba(255, 255, 255, 0.05);
                        padding: 4px;
                        border-radius: 8px;
                    }

                    .tab-btn {
                        padding: 8px 20px;
                        border-radius: 6px;
                        border: none;
                        background: none;
                        color: var(--text-muted);
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all .2s;
                        font-family: inherit;
                    }

                    .tab-btn.active {
                        background: var(--primary);
                        color: #000;
                    }

                    .filter-group {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    .chart-container {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 24px;
                        margin-bottom: 24px;
                    }

                    .report-table-container {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        overflow: hidden;
                    }

                    .tab-content {
                        display: none;
                    }

                    .tab-content.active {
                        display: block;
                    }

                    .admin-table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    .admin-table th {
                        text-align: left;
                        padding: 16px 24px;
                        background: var(--surface2);
                        color: var(--text-muted);
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        font-weight: 700;
                    }

                    .admin-table td {
                        padding: 16px 24px;
                        border-top: 1px solid var(--border);
                        font-size: 14px;
                        color: var(--text);
                    }

                    .admin-table tr:hover td {
                        background: rgba(255, 255, 255, 0.02);
                    }

                    .total-row td {
                        background: var(--surface2);
                        font-weight: 700;
                        color: var(--primary) !important;
                        border-top: 2px solid var(--border);
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
                                <div class="filter-bar">
                                    <div class="tab-bar">
                                        <button class="tab-btn active" onclick="switchTab('revenue',this)">Doanh
                                            thu</button>
                                        <button class="tab-btn" onclick="switchTab('topitems',this)">Top món bán
                                            chạy</button>
                                    </div>

                                    <div style="width:1px; height:24px; background:var(--border); margin:0 10px"></div>

                                    <form method="get" action="${ctx}/admin/reports"
                                        style="display:flex; align-items:center; gap:15px; flex:1">
                                        <div class="filter-group">
                                            <span>Theo</span>
                                            <select name="period" class="form-control"
                                                style="width:110px; background:rgba(255,255,255,0.05); border-color:transparent">
                                                <option value="day" ${param.period !='month' ? 'selected' : '' }>ngày
                                                </option>
                                                <option value="month" ${param.period=='month' ? 'selected' : '' }>tháng
                                                </option>
                                            </select>
                                        </div>

                                        <div class="filter-group">
                                            <input type="date" name="from" class="form-control"
                                                style="width:130px; background:rgba(255,255,255,0.05); border-color:transparent"
                                                value="${param.from}">
                                            <span>đến</span>
                                            <input type="date" name="to" class="form-control"
                                                style="width:130px; background:rgba(255,255,255,0.05); border-color:transparent"
                                                value="${param.to}">
                                        </div>

                                        <button type="submit" class="btn btn-primary" style="padding:8px 15px">
                                            <i class="fa-solid fa-filter" style="margin-right:5px"></i> Lọc
                                        </button>
                                    </form>
                                </div>

                                <div class="tab-content active" id="tab-revenue">
                                    <div class="chart-container">
                                        <div
                                            style="display:flex; justify-content:space-between; margin-bottom:20px; align-items:center">
                                            <h3 style="font-size:15px; font-weight:600; color:var(--text-muted)">BIỂU ĐỒ
                                                DOANH THU</h3>
                                            <div id="chartLegend" style="display:flex; gap:15px; font-size:12px">
                                                <span style="display:flex; align-items:center; gap:5px"><i
                                                        class="fa-solid fa-square" style="color:var(--primary)"></i>
                                                    Doanh thu</span>
                                                <span style="display:flex; align-items:center; gap:5px"><i
                                                        class="fa-solid fa-square" style="color:#3b82f6"></i> Số
                                                    đơn</span>
                                            </div>
                                        </div>
                                        <canvas id="revenueCombinedChart" height="100"></canvas>
                                    </div>

                                    <div class="report-table-container">
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
                                                    <tr class="total-row">
                                                        <td>TỔNG CỘNG</td>
                                                        <td style="text-align:right">${totalOrders}</td>
                                                        <td style="text-align:right">
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
                                    <div class="report-table-container">
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
                    const cl = JSON.parse('${not empty chartLabels ? chartLabels : "[]"}'),
                        cr = JSON.parse('${not empty chartRevenue ? chartRevenue : "[]"}'),
                        co = JSON.parse('${not empty chartOrders ? chartOrders : "[]"}');

                    if (cl.length) {
                        new Chart(document.getElementById('revenueCombinedChart'), {
                            type: 'bar',
                            data: {
                                labels: cl,
                                datasets: [
                                    {
                                        label: 'Doanh thu (vnđ)',
                                        data: cr,
                                        backgroundColor: 'rgba(232,160,32,0.8)',
                                        borderRadius: 4,
                                        yAxisID: 'y'
                                    },
                                    {
                                        label: 'Số đơn',
                                        data: co,
                                        type: 'line',
                                        borderColor: '#3b82f6',
                                        backgroundColor: '#3b82f6',
                                        borderWidth: 2,
                                        fill: false,
                                        tension: 0.3,
                                        pointRadius: 3,
                                        yAxisID: 'y1'
                                    }
                                ]
                            },
                            options: {
                                responsive: true,
                                plugins: { legend: { display: false } },
                                scales: {
                                    x: {
                                        grid: { display: false },
                                        ticks: { color: '#9e9488', font: { size: 10 } }
                                    },
                                    y: {
                                        position: 'left',
                                        grid: { color: 'rgba(255,255,255,0.05)' },
                                        ticks: { color: '#9e9488', font: { size: 10 } }
                                    },
                                    y1: {
                                        position: 'right',
                                        grid: { display: false },
                                        ticks: { color: '#3b82f6', font: { size: 10 } }
                                    }
                                }
                            }
                        });
                    }
                </script>
            </body>

            </html>