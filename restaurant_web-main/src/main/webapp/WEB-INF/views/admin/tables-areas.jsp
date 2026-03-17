<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="tables" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Bàn & Khu vực — Admin</title>
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
                            <h1 class="topbar-title"><i class="fa-solid fa-chair"></i> Bàn & Khu vực</h1>
                            <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                            </div>
                        </header>
                        <div class="content">
                            <c:if test="${not empty sessionScope.flash_msg}">
                                <div class="alert alert-${sessionScope.flash_type == 'error' ? 'error' : 'success'}">
                                    <i
                                        class="fa-solid ${sessionScope.flash_type == 'error' ? 'fa-circle-exclamation' : 'fa-check-circle'}"></i>
                                    ${sessionScope.flash_msg}
                                </div>
                                <c:remove var="flash_msg" scope="session" />
                                <c:remove var="flash_type" scope="session" />
                            </c:if>
                            <div class="page-header">
                                <div class="page-header-left">
                                    <h2>Quản lý Bàn & Khu vực</h2>
                                    <p>Tổ chức sơ đồ nhà hàng</p>
                                </div>
                                <div style="display:flex;gap:8px">
                                    <button class="btn btn-ghost" onclick="openCreateArea()"><i
                                            class="fa-solid fa-plus"></i> Thêm Khu vực</button>
                                    <button class="btn btn-primary" onclick="openCreateTable()"><i
                                            class="fa-solid fa-plus"></i> Thêm Bàn</button>
                                </div>
                            </div>

                            <c:forEach var="area" items="${areas}">
                                <div class="area-section">
                                    <div class="area-heading">
                                        <i class="fa-solid fa-location-dot" style="color:var(--primary)"></i>
                                        <c:out value="${area.areaName}" />
                                        <span
                                            style="font-size:12px;font-weight:400;color:var(--text-muted);text-transform:none;letter-spacing:0">(${area.tables.size()}
                                            bàn)</span>
                                        <button class="btn btn-ghost btn-sm"
                                            style="margin-left:auto;text-transform:none"
                                            onclick="editArea(${area.id},'${area.areaName}','${area.description}')"><i
                                                class="fa-solid fa-pen"></i></button>
                                    </div>
                                    <div class="table-grid">
                                        <c:forEach var="t" items="${area.tables}">
                                            <c:set var="tStatus" value="${t.status}" />
                                            <div class="table-tile t-${tStatus.name().toLowerCase()}"
                                                onclick="editTable(${t.id},'${t.tableName}',${t.capacity},'${tStatus}',${area.id})">
                                                <div class="table-tile-name">${t.tableName}</div>
                                                <div class="table-tile-cap"><i class="fa-solid fa-user"></i>
                                                    ${t.capacity} chỗ</div>
                                                <span class="badge"
                                                    style="margin-top:6px;font-size:10px">${tStatus}</span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty areas}">
                                <div class="empty-state"><i class="fa-solid fa-map"></i>
                                    <h3>Chưa có khu vực</h3>
                                    <p>Thêm khu vực để bắt đầu tổ chức bàn</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
            </div>

            <%-- Area Modal --%>
                <div class="modal-overlay" id="areaModal">
                    <div class="modal">
                        <div class="modal-header">
                            <h3 class="modal-title" id="areaMTitle">Thêm khu vực</h3><button
                                class="btn btn-ghost btn-sm" onclick="closeModal('areaModal')"><i
                                    class="fa-solid fa-xmark"></i></button>
                        </div>
                        <form method="post" id="areaForm" action="${ctx}/admin/tables">
                            <input type="hidden" name="action" id="areaAction" value="saveArea">
                            <input type="hidden" name="areaId" id="areaId">
                            <div class="modal-body">
                                <div class="form-group"><label class="form-label">Tên khu vực *</label><input
                                        type="text" name="areaName" id="areaName" class="form-control" required
                                        placeholder="VD: Tầng 1, Sân vườn..."></div>
                                <div class="form-group"><label class="form-label">Mô tả</label><input type="text"
                                        name="description" id="areaDesc" class="form-control"
                                        placeholder="Mô tả ngắn..."></div>
                            </div>
                            <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                    onclick="closeModal('areaModal')">Hủy</button><button type="submit"
                                    class="btn btn-primary" id="areaMBtn">Thêm</button></div>
                        </form>
                    </div>
                </div>

                <%-- Table Modal --%>
                    <div class="modal-overlay" id="tableModal">
                        <div class="modal">
                            <div class="modal-header">
                                <h3 class="modal-title" id="tableMTitle">Thêm bàn</h3><button
                                    class="btn btn-ghost btn-sm" onclick="closeModal('tableModal')"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" id="tableForm" action="${ctx}/admin/tables">
                                <input type="hidden" name="action" id="tableAction" value="saveTable">
                                <input type="hidden" name="tableId" id="tableId">
                                <div class="modal-body">
                                    <div class="form-group"><label class="form-label">Tên bàn *</label><input
                                            type="text" name="tableCode" id="tName" class="form-control" required
                                            placeholder="VD: Bàn 01, VIP 1..."></div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Khu vực *</label>
                                            <select name="areaId" id="tAreaId" class="form-control" required>
                                                <c:forEach var="a" items="${areas}">
                                                    <option value="${a.id}">${a.areaName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="form-group"><label class="form-label">Số chỗ *</label><input
                                                type="number" name="seats" id="tCap" class="form-control" required
                                                min="1" max="30" value="4"></div>
                                    </div>
                                    <div class="form-group" id="tStatusGroup" style="display:none">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" id="tStatus" class="form-control">
                                            <option value="EMPTY">EMPTY (Trống)</option>
                                            <option value="RESERVED">RESERVED (Đã đặt)</option>
                                            <option value="OCCUPIED">OCCUPIED (Đang dùng)</option>
                                            <option value="WAITING_PAYMENT">WAITING_PAYMENT (Đang chờ TT)</option>
                                            <option value="DIRTY">DIRTY (Bẩn)</option>
                                            <option value="DISABLED">DISABLED (Khóa)</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-danger" id="tDelBtn"
                                        style="display:none;margin-right:auto" onclick="deleteTable()"><i
                                            class="fa-solid fa-trash"></i> Xóa</button>
                                    <button type="button" class="btn btn-ghost"
                                        onclick="closeModal('tableModal')">Hủy</button>
                                    <button type="submit" class="btn btn-primary" id="tableMBtn">Thêm</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openModal(id) { document.getElementById(id).classList.add('active') }
                        function closeModal(id) { document.getElementById(id).classList.remove('active') }
                        function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                        function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }

                        function openCreateArea() {
                            document.getElementById('areaMTitle').textContent = 'Thêm khu vực';
                            document.getElementById('areaMBtn').textContent = 'Thêm';
                            document.getElementById('areaId').value = '';
                            document.getElementById('areaName').value = '';
                            document.getElementById('areaDesc').value = '';
                            openModal('areaModal');
                        }
                        function editArea(id, name, desc) {
                            document.getElementById('areaMTitle').textContent = 'Sửa khu vực';
                            document.getElementById('areaMBtn').textContent = 'Cập nhật';
                            document.getElementById('areaId').value = id;
                            document.getElementById('areaName').value = name;
                            document.getElementById('areaDesc').value = desc || '';
                            openModal('areaModal');
                        }
                        function openCreateTable() {
                            document.getElementById('tableMTitle').textContent = 'Thêm bàn';
                            document.getElementById('tableMBtn').textContent = 'Thêm';
                            document.getElementById('tableId').value = '';
                            document.getElementById('tName').value = '';
                            document.getElementById('tCap').value = '4';
                            document.getElementById('tStatus').value = 'AVAILABLE';
                            document.getElementById('tStatusGroup').style.display = 'none';
                            document.getElementById('tDelBtn').style.display = 'none';
                            openModal('tableModal');
                        }
                        function editTable(id, name, cap, status, areaId) {
                            document.getElementById('tableMTitle').textContent = 'Sửa bàn';
                            document.getElementById('tableMBtn').textContent = 'Cập nhật';
                            document.getElementById('tableId').value = id;
                            document.getElementById('tName').value = name;
                            document.getElementById('tCap').value = cap;
                            document.getElementById('tAreaId').value = areaId;
                            document.getElementById('tStatus').value = status;
                            document.getElementById('tStatusGroup').style.display = 'block';
                            document.getElementById('tDelBtn').style.display = 'inline-flex';
                            openModal('tableModal');
                        }
                        function deleteTable() {
                            var id = document.getElementById('tableId').value;
                            if (confirm('Xóa bàn này?')) { var f = document.createElement('form'); f.method = 'post'; f.action = '${ctx}/admin/tables'; var i = document.createElement('input'); i.type = 'hidden'; i.name = 'action'; i.value = 'deleteTable'; var j = document.createElement('input'); j.type = 'hidden'; j.name = 'tableId'; j.value = id; f.appendChild(i); f.appendChild(j); document.body.appendChild(f); f.submit(); }
                        }
                    </script>
        </body>

        </html>