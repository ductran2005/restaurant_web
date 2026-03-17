<%-- Action-Version: 3.0 --%>
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
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
                <style>
                    .t-occupied,
                    .t-waiting_payment {
                        border-color: #3b82f6;
                        background: rgba(59, 130, 246, 0.09);
                        color: #3b82f6;
                    }

                    .t-reserved {
                        border-color: #f59e0b;
                        background: rgba(245, 158, 11, 0.09);
                        color: #f59e0b;
                    }

                    .t-dirty {
                        border-color: #92400e;
                        background: rgba(146, 64, 14, 0.09);
                        color: #92400e;
                    }

                    .t-disabled {
                        border-color: #ef4444;
                        background: rgba(239, 68, 68, 0.09);
                        opacity: 0.6;
                        cursor: not-allowed;
                    }

                    .table-tile {
                        cursor: pointer;
                        position: relative;
                        transition: transform .18s, box-shadow .18s;
                        padding-bottom: 60px !important;
                    }

                    .table-tile:hover:not(.t-disabled) {
                        transform: translateY(-3px);
                        box-shadow: 0 6px 20px rgba(0, 0, 0, .35);
                    }

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

                    .tile-actions {
                        position: absolute;
                        bottom: 10px;
                        right: 10px;
                        display: flex;
                        gap: 8px;
                        z-index: 1000;
                    }

                    .action-btn {
                        width: 36px;
                        height: 36px;
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: white !important;
                        border: 1px solid rgba(0, 0, 0, 0.1) !important;
                        color: #333 !important;
                        cursor: pointer;
                        transition: all 0.2s;
                        font-size: 16px;
                        pointer-events: auto !important;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                    }

                    .action-btn:hover {
                        background: #f0f0f0 !important;
                        transform: scale(1.1);
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
                    }
                </style>
                <script>
                    function statusControl(event, tableId, action) {
                        console.log('>>> statusControl triggered:', action, tableId);
                        if (event) {
                            if (event.stopPropagation) event.stopPropagation();
                            if (event.preventDefault) event.preventDefault();
                        }

                        const msg = "Bạn có chắc muốn thực hiện thao tác này?";
                        if (!confirm(msg)) return false;

                        const base = "${ctx}";
                        const url = base + "/api/tables/" + tableId + "/" + action;
                        console.log('>>> Fetching URL:', url);

                        fetch(url, { method: 'POST' })
                            .then(resp => {
                                console.log('>>> Response Status:', resp.status);
                                if (resp.ok) {
                                    window.location.reload();
                                } else {
                                    return resp.json().then(data => {
                                        alert("Lỗi: " + (data.error || "Thao tác thất bại"));
                                    });
                                }
                            })
                            .catch(err => {
                                console.error('>>> Fetch Error:', err);
                                alert("Lỗi kết nối server");
                            });

                        return false;
                    }
                </script>
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
                                    <div
                                        style="display:flex;gap:12px;font-size:11px;color:#9e9488;align-items:center;flex-wrap:wrap;max-width:400px;justify-content:flex-end">
                                        <span><span class="legend-dot" style="background:#22c55e"></span>Trống</span>
                                        <span><span class="legend-dot" style="background:#f59e0b"></span>Đặt
                                            trước</span>
                                        <span><span class="legend-dot" style="background:#3b82f6"></span>Đang
                                            dùng</span>
                                        <span><span class="legend-dot" style="background:#06b6d4"></span>Chờ TT</span>
                                        <span><span class="legend-dot" style="background:#92400e"></span>Bẩn</span>
                                        <span><span class="legend-dot" style="background:#ef4444"></span>Khóa</span>
                                    </div>
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <c:if test="${not empty sessionScope.flash_msg}">
                                    <div class="flash-bar"
                                        style="padding:10px;background:rgba(239,68,68,0.1);border-radius:8px;margin-bottom:15px;color:#ef4444">
                                        <i class="fa-solid fa-circle-exclamation"></i> ${sessionScope.flash_msg}
                                    </div>
                                    <c:remove var="flash_msg" scope="session" />
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
                                            <div class="area-section" style="margin-bottom:30px">
                                                <div class="area-heading"
                                                    style="margin-bottom:15px;font-weight:700;font-size:1.1rem">
                                                    <i class="fa-solid fa-location-dot"
                                                        style="color:var(--primary)"></i>
                                                    <c:out value="${area.areaName}" />
                                                </div>
                                                <div class="table-grid"
                                                    style="display:grid;grid-template-columns:repeat(auto-fill, minmax(140px, 1fr));gap:15px">
                                                    <c:forEach var="t" items="${area.tables}">
                                                        <c:set var="status" value="${t.status}" />
                                                        <c:set var="openOrderId" value="${openOrderByTable[t.id]}" />

                                                        <c:choose>
                                                            <c:when
                                                                test="${status == 'OCCUPIED' || status == 'IN_USE' || status == 'WAITING_PAYMENT'}">
                                                                <div onclick="if(!event.target.closest('button')) location.href='${ctx}/staff/orders?orderId=${openOrderId}'"
                                                                    class="table-tile t-occupied ${status == 'WAITING_PAYMENT' ? 't-waiting_payment' : ''}">
                                                                    <div class="table-tile-name">
                                                                        <c:out value="${t.tableName}" />
                                                                    </div>
                                                                    <div class="table-tile-cap"><i
                                                                            class="fa-solid fa-user"></i> ${t.capacity}
                                                                        chỗ</div>
                                                                    <div
                                                                        style="margin-top:8px;font-size:11px;font-weight:700">
                                                                        <i class="fa-solid fa-utensils"></i>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${status == 'WAITING_PAYMENT'}">
                                                                                CHỜ THANH TOÁN</c:when>
                                                                            <c:otherwise>ĐANG PHỤC VỤ</c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="tile-action-hint">Order #${openOrderId
                                                                        != null ? openOrderId : '...'}</div>
                                                                    <c:if
                                                                        test="${status == 'OCCUPIED' || status == 'IN_USE'}">
                                                                        <div class="tile-actions">
                                                                            <button type="button" class="action-btn"
                                                                                onclick="statusControl(event, ${t.id}, 'request-payment')"
                                                                                title="Khách yêu cầu thanh toán">
                                                                                <i class="fa-solid fa-receipt"></i>
                                                                            </button>
                                                                        </div>
                                                                    </c:if>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${status == 'RESERVED'}">
                                                                <div onclick="if(!event.target.closest('button')) location.href='${ctx}/staff/orders?action=create&tableId=${t.id}'"
                                                                    class="table-tile t-reserved">
                                                                    <div class="table-tile-name">
                                                                        <c:out value="${t.tableName}" />
                                                                    </div>
                                                                    <div class="table-tile-cap"><i
                                                                            class="fa-solid fa-user"></i> ${t.capacity}
                                                                        chỗ</div>
                                                                    <div
                                                                        style="margin-top:8px;font-size:11px;font-weight:700">
                                                                        ĐÃ ĐẶT TRƯỚC</div>
                                                                    <div class="tile-action-hint">Mở order</div>
                                                                    <div class="tile-actions">
                                                                        <button type="button" class="action-btn"
                                                                            onclick="statusControl(event, ${t.id}, 'cancel-reservation')"
                                                                            title="Hủy đặt bàn">
                                                                            <i class="fa-solid fa-xmark"></i>
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${status == 'DIRTY'}">
                                                                <div class="table-tile t-dirty">
                                                                    <div class="table-tile-name">
                                                                        <c:out value="${t.tableName}" />
                                                                    </div>
                                                                    <div class="table-tile-cap"><i
                                                                            class="fa-solid fa-user"></i> ${t.capacity}
                                                                        chỗ</div>
                                                                    <div
                                                                        style="margin-top:8px;font-size:11px;font-weight:700">
                                                                        CHỜ DỌN DẸP</div>
                                                                    <div class="tile-actions">
                                                                        <button type="button" class="action-btn"
                                                                            onclick="statusControl(event, ${t.id}, 'clean')"
                                                                            title="Dọn bàn xong">
                                                                            <i class="fa-solid fa-broom"></i>
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${status == 'DISABLED'}">
                                                                <div class="table-tile t-disabled">
                                                                    <div class="table-tile-name">
                                                                        <c:out value="${t.tableName}" />
                                                                    </div>
                                                                    <div class="table-tile-cap"><i
                                                                            class="fa-solid fa-user"></i> ${t.capacity}
                                                                        chỗ</div>
                                                                    <div
                                                                        style="margin-top:8px;font-size:11px;font-weight:700">
                                                                        ĐANG KHÓA</div>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div onclick="if(!event.target.closest('button')) location.href='${ctx}/staff/orders?action=create&tableId=${t.id}'"
                                                                    class="table-tile t-available">
                                                                    <div class="table-tile-name">
                                                                        <c:out value="${t.tableName}" />
                                                                    </div>
                                                                    <div class="table-tile-cap"><i
                                                                            class="fa-solid fa-user"></i> ${t.capacity}
                                                                        chỗ</div>
                                                                    <div
                                                                        style="margin-top:8px;font-size:11px;font-weight:600">
                                                                        TRỐNG</div>
                                                                    <div class="tile-action-hint"><i
                                                                            class="fa-solid fa-plus"></i> Tạo order
                                                                    </div>
                                                                    <div class="tile-actions">
                                                                        <button type="button" class="action-btn"
                                                                            onclick="statusControl(event, ${t.id}, 'reserve')"
                                                                            title="Đặt bàn trước">
                                                                            <i class="fa-solid fa-calendar-check"></i>
                                                                            <span style="display:none">reserve</span>
                                                                        </button>
                                                                    </div>
                                                                </div>
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