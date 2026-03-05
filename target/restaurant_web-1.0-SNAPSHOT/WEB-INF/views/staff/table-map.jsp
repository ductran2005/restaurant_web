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
                                <div style="display:flex;gap:14px;font-size:12px;color:#9e9488;align-items:center">
                                    <span>
                                        <span
                                            style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#22c55e;margin-right:4px"></span>
                                        Trống (AVAILABLE)
                                    </span>
                                    <span>
                                        <span
                                            style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#3b82f6;margin-right:4px"></span>
                                        Đang dùng (IN_USE)
                                    </span>
                                </div>
                            </div>
                        </header>

                        <div class="content">
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
                                                <i class="fa-solid fa-location-dot"></i>
                                                <c:out value="${area.areaName}" />
                                            </div>
                                            <div class="table-grid">
                                                <c:forEach var="t" items="${area.tables}">
                                                    <c:set var="statusClass" value="t-available" />
                                                    <c:if test="${t.status == 'IN_USE'}">
                                                        <c:set var="statusClass" value="t-in_use" />
                                                    </c:if>
                                                    <div class="table-tile ${statusClass}" data-id="${t.id}"
                                                        data-name="${t.tableName}" data-status="${t.status}"
                                                        data-cap="${t.capacity}" onclick="openTableDetail(this)">
                                                        <div class="table-tile-name">
                                                            <c:out value="${t.tableName}" />
                                                        </div>
                                                        <div class="table-tile-cap">
                                                            <i class="fa-solid fa-user"></i> ${t.capacity} chỗ
                                                        </div>
                                                        <div style="margin-top:8px;font-size:11px;font-weight:600">
                                                            ${t.status}
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
            </div>

            <!-- Table Detail Modal -->
            <div class="modal-overlay" id="tableModal">
                <div class="modal">
                    <div class="modal-header">
                        <span class="modal-title" id="modalTitle">Chi tiết bàn</span>
                        <button class="btn btn-ghost btn-icon" onclick="closeTableModal()">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p id="modalBody" style="color:#9e9488;font-size:14px"></p>
                        <form method="POST" action="${ctx}/staff" style="margin-top:1.25rem">
                            <input type="hidden" id="modalTableId" name="tableId">
                            <input type="hidden" name="action" value="updateStatus">
                            <div class="form-group">
                                <label class="form-label">Cập nhật trạng thái</label>
                                <select name="status" class="form-control" id="modalStatusSelect">
                                    <option value="AVAILABLE">Trống (AVAILABLE)</option>
                                    <option value="IN_USE">Đang dùng (IN_USE)</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary" style="width:100%">
                                <i class="fa-solid fa-check"></i> Cập nhật
                            </button>
                        </form>
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
                function openTableDetail(el) {
                    var id = el.getAttribute('data-id');
                    var name = el.getAttribute('data-name');
                    var status = el.getAttribute('data-status');
                    var cap = el.getAttribute('data-cap');
                    document.getElementById('modalTitle').textContent = name;
                    document.getElementById('modalBody').textContent = 'Sức chứa: ' + cap + ' người | Trạng thái: ' + status;
                    document.getElementById('modalTableId').value = id;
                    document.getElementById('modalStatusSelect').value = status;
                    document.getElementById('tableModal').classList.add('active');
                }
                function closeTableModal() {
                    document.getElementById('tableModal').classList.remove('active');
                }
            </script>
        </body>

        </html>