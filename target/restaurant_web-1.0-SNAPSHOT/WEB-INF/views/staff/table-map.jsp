<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="tablemap" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Sơ đồ bàn — Staff Hương Việt</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
            <style>
                /* Override t-in_use to blue (CSS had t-serving) */
                .t-in_use {
                    border-color: #3b82f6;
                    background: rgba(59, 130, 246, 0.09);
                    color: #3b82f6;
                }

                .table-tile {
                    cursor: pointer;
                    position: relative;
                    transition: transform .18s, box-shadow .18s;
                }

                .table-tile:hover {
                    transform: translateY(-3px);
                    box-shadow: 0 6px 20px rgba(0, 0, 0, .35);
                }

                /* Clickable label */
                .table-tile .tile-action-hint {
                    font-size: 10px;
                    margin-top: 6px;
                    opacity: .7;
                    font-weight: 400;
                }

                .legend-dot {
                    display: inline-block;
                    width: 9px;
                    height: 9px;
                    border-radius: 50%;
                    margin-right: 5px;
                }

                .flash-bar {
                    padding: 12px 16px;
                    border-radius: 10px;
                    font-size: 13px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: 16px;
                    background: rgba(239, 68, 68, 0.1);
                    border: 1px solid rgba(239, 68, 68, 0.25);
                    color: #f87171;
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
                            <h1 class="topbar-title"><i class="fa-solid fa-map"></i> Sơ đồ bàn</h1>
                            <div class="topbar-right">
                                <div style="display:flex;gap:18px;font-size:12px;color:#9e9488;align-items:center">
                                    <span><span class="legend-dot" style="background:#22c55e"></span>Trống</span>
                                    <span><span class="legend-dot" style="background:#3b82f6"></span>Đang dùng</span>
                                </div>
                                <span class="badge-role">${sessionScope.user.role.name}</span>
                            </div>
                        </header>

                        <div class="content">

                            <%-- Flash error (e.g. table already has order) --%>
                                <c:if test="${not empty sessionScope.flash_msg}">
                                    <div class="flash-bar">
                                        <i class="fa-solid fa-circle-exclamation"></i>
                                        ${sessionScope.flash_msg}
                                    </div>
                                    <c:remove var="flash_msg" scope="session" />
                                    <c:remove var="flash_type" scope="session" />
                                </c:if>

                                <c:choose>
                                    <c:when test="${empty areas}">
                                        <div class="empty-state">
                                            <i class="fa-solid fa-chair"></i>
                                            <h3>Chưa có khu vực nào</h3>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="area" items="${areas}">
                                            <div class="area-section">
                                                <div class="area-heading">
                                                    <i class="fa-solid fa-location-dot"
                                                        style="color:var(--primary)"></i>
                                                    <c:out value="${area.areaName}" />
                                                </div>
                                                <div class="table-grid">
                                                    <c:forEach var="t" items="${area.tables}">
                                                        <%-- Determine CSS class and link target --%>
                                                            <c:set var="isInUse" value="${t.status == 'IN_USE'}" />
                                                            <c:set var="openOrderId"
                                                                value="${openOrderByTable[t.id]}" />

                                                            <c:choose>
                                                                <c:when test="${isInUse && not empty openOrderId}">
                                                                    <%-- IN_USE with open order: go to existing order
                                                                        --%>
                                                                        <a href="${ctx}/staff/orders?orderId=${openOrderId}"
                                                                            class="table-tile t-in_use"
                                                                            title="Bàn đang có order #${openOrderId} — click để xem/chỉnh order">
                                                                            <div class="table-tile-name">
                                                                                <c:out value="${t.tableName}" />
                                                                            </div>
                                                                            <div class="table-tile-cap">
                                                                                <i class="fa-solid fa-user"></i>
                                                                                ${t.capacity} chỗ
                                                                            </div>
                                                                            <div
                                                                                style="margin-top:8px;font-size:11px;font-weight:700;color:#3b82f6">
                                                                                <i class="fa-solid fa-utensils"></i>
                                                                                Order #${openOrderId}
                                                                            </div>
                                                                            <div class="tile-action-hint">
                                                                                <i class="fa-solid fa-arrow-right"></i>
                                                                                Xem order
                                                                            </div>
                                                                        </a>
                                                                </c:when>
                                                                <c:when test="${isInUse && empty openOrderId}">
                                                                    <%-- IN_USE but no tracked order (edge case) --%>
                                                                        <div class="table-tile t-in_use"
                                                                            title="Bàn đang dùng (không tìm thấy order mở)">
                                                                            <div class="table-tile-name">
                                                                                <c:out value="${t.tableName}" />
                                                                            </div>
                                                                            <div class="table-tile-cap">
                                                                                <i class="fa-solid fa-user"></i>
                                                                                ${t.capacity} chỗ
                                                                            </div>
                                                                            <div
                                                                                style="margin-top:8px;font-size:11px;font-weight:600">
                                                                                IN_USE
                                                                            </div>
                                                                        </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <%-- AVAILABLE: click to create new order --%>
                                                                        <a href="${ctx}/staff/orders?action=create&tableId=${t.id}"
                                                                            class="table-tile t-available"
                                                                            title="Bàn trống — click để tạo order mới">
                                                                            <div class="table-tile-name">
                                                                                <c:out value="${t.tableName}" />
                                                                            </div>
                                                                            <div class="table-tile-cap">
                                                                                <i class="fa-solid fa-user"></i>
                                                                                ${t.capacity} chỗ
                                                                            </div>
                                                                            <div
                                                                                style="margin-top:8px;font-size:11px;font-weight:600">
                                                                                AVAILABLE
                                                                            </div>
                                                                            <div class="tile-action-hint">
                                                                                <i class="fa-solid fa-plus"></i> Tạo
                                                                                order
                                                                            </div>
                                                                        </a>
                                                                </c:otherwise>
                                                            </c:choose>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>

                        </div>
                    </div>
            </div>

            <script>
                function openSidebar() {
                    document.getElementById('sidebar').classList.add('open');
                    document.getElementById('sidebarOverlay').classList.add('active');
                }
                function closeSidebar() {
                    document.getElementById('sidebar').classList.remove('open');
                    document.getElementById('sidebarOverlay').classList.remove('active');
                }
            </script>
        </body>

        </html>