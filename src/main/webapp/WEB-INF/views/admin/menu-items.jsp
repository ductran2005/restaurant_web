<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="menu" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thực đơn — Admin</title>
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
                                <h1 class="topbar-title"><i class="fa-solid fa-bowl-food"></i> Quản lý Thực đơn</h1>
                                <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <c:if test="${not empty sessionScope.flash_msg}">
                                    <div
                                        class="alert alert-${sessionScope.flash_type == 'error' ? 'error' : 'success'}">
                                        <i
                                            class="fa-solid ${sessionScope.flash_type == 'error' ? 'fa-circle-exclamation' : 'fa-check-circle'}"></i>
                                        ${sessionScope.flash_msg}
                                    </div>
                                    <c:remove var="flash_msg" scope="session" />
                                    <c:remove var="flash_type" scope="session" />
                                </c:if>
                                <div class="page-header">
                                    <div class="page-header-left">
                                        <h2>Sản phẩm thực đơn</h2>
                                        <p>Quản lý món ăn, đồ uống</p>
                                    </div>
                                    <button class="btn btn-primary" onclick="openCreateModal()"><i
                                            class="fa-solid fa-plus"></i> Thêm sản phẩm</button>
                                </div>
                                <form method="get" action="${ctx}/admin/menu"
                                    style="display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap">
                                    <div class="search-wrap" style="flex:1;min-width:200px">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" name="search" class="search-input" style="width:100%"
                                            placeholder="Tìm theo tên..." value="${param.search}">
                                    </div>
                                    <select name="categoryId" class="form-control" style="width:180px">
                                        <option value="">Tất cả danh mục</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}" ${param.categoryId==cat.id ? 'selected' : '' }>
                                                ${cat.categoryName}</option>
                                        </c:forEach>
                                    </select>
                                    <select name="status" class="form-control" style="width:160px">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="AVAILABLE" ${param.status=='AVAILABLE' ?'selected':''}>Đang bán
                                        </option>
                                        <option value="UNAVAILABLE" ${param.status=='UNAVAILABLE' ?'selected':''}>Ngừng
                                            bán</option>
                                    </select>
                                    <button type="submit" class="btn btn-ghost"><i class="fa-solid fa-filter"></i>
                                        Lọc</button>
                                </form>
                                <div class="table-card">
                                    <table class="admin-table">
                                        <thead>
                                            <tr>
                                                <th>Tên</th>
                                                <th>Danh mục</th>
                                                <th style="text-align:right">Giá bán</th>
                                                <th style="text-align:right">Giá vốn</th>
                                                <th>Trạng thái</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="p" items="${products}">
                                                <tr>
                                                    <td style="font-weight:600">
                                                        <c:out value="${p.productName}" />
                                                    </td>
                                                    <td style="color:var(--text-muted)">${p.category.categoryName}</td>
                                                    <td style="text-align:right">
                                                        <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                                    </td>
                                                    <td style="text-align:right;color:var(--text-muted)">
                                                        <fmt:formatNumber value="${p.costPrice}" pattern="#,###" />đ
                                                    </td>
                                                    <td><span
                                                            class="badge ${p.status=='AVAILABLE'?'b-success':'b-danger'}">${p.status=='AVAILABLE'?'Đang
                                                            bán':'Ngừng bán'}</span></td>
                                                    <td>
                                                        <div style="display:flex;gap:4px">
                                                            <button class="btn btn-ghost btn-sm"
                                                                onclick="openEditModal(${p.id},'${p.productName}',${p.category.id},${p.price},${p.costPrice},'${p.status}','${p.description}')"
                                                                title="Sửa"><i class="fa-solid fa-pen"></i></button>
                                                            <form method="post" action="${ctx}/admin/menu"
                                                                style="display:inline">
                                                                <input type="hidden" name="action" value="toggleStatus">
                                                                <input type="hidden" name="itemId" value="${p.id}">
                                                                <button type="submit" class="btn btn-ghost btn-sm"
                                                                    title="Đổi trạng thái"
                                                                    style="color:${p.status=='AVAILABLE'?'var(--warning)':'var(--success)'}">
                                                                    <i
                                                                        class="fa-solid ${p.status=='AVAILABLE'?'fa-toggle-on':'fa-toggle-off'}"></i>
                                                                </button>
                                                            </form>
                                                            <button class="btn btn-ghost btn-sm"
                                                                style="color:var(--destructive)"
                                                                onclick="openDeleteModal(${p.id},'${p.productName}')"
                                                                title="Xóa"><i class="fa-solid fa-trash"></i></button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty products}">
                                                <tr>
                                                    <td colspan="6" class="empty-state"><i
                                                            class="fa-solid fa-bowl-food"></i>
                                                        <h3>Chưa có sản phẩm</h3>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                </div>

                <%-- Create/Edit Modal --%>
                    <div class="modal-overlay" id="formModal">
                        <div class="modal" style="max-width:540px">
                            <div class="modal-header">
                                <h3 class="modal-title" id="fTitle">Thêm sản phẩm</h3><button
                                    class="btn btn-ghost btn-sm" onclick="closeModal('formModal')"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" id="prodForm" action="${ctx}/admin/menu">
                                <input type="hidden" name="action" id="pAction" value="create">
                                <input type="hidden" name="itemId" id="pId">
                                <div class="modal-body">
                                    <div class="form-group"><label class="form-label">Tên sản phẩm *</label><input
                                            type="text" name="itemName" id="pName" class="form-control" required>
                                    </div>
                                    <div class="form-group"><label class="form-label">Danh mục *</label>
                                        <select name="categoryId" id="pCat" class="form-control" required>
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.id}">${cat.categoryName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Giá bán *</label><input
                                                type="number" name="price" id="pPrice" class="form-control" required
                                                min="0" step="1000"></div>
                                        <div class="form-group"><label class="form-label">Giá vốn *</label><input
                                                type="number" name="costPrice" id="pCost" class="form-control" required
                                                min="0" step="1000"></div>
                                    </div>
                                    <div class="form-group"><label class="form-label">Mô tả</label><textarea
                                            name="description" id="pDesc" class="form-control" rows="2"></textarea>
                                    </div>
                                    <div class="form-group"><label class="form-label">Trạng thái</label>
                                        <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
                                            <input type="checkbox" name="isActive" id="pIsActive" checked>
                                            <span>Đang bán</span>
                                        </label>
                                    </div>
                                </div>
                                <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                        onclick="closeModal('formModal')">Hủy</button><button type="submit"
                                        class="btn btn-primary" id="fBtn">Thêm mới</button></div>
                            </form>
                        </div>
                    </div>

                    <%-- Delete Modal --%>
                        <div class="modal-overlay" id="delModal">
                            <div class="modal">
                                <div class="modal-header">
                                    <h3 class="modal-title"><i class="fa-solid fa-triangle-exclamation"
                                            style="color:var(--destructive)"></i> Xóa sản phẩm</h3><button
                                        class="btn btn-ghost btn-sm" onclick="closeModal('delModal')"><i
                                            class="fa-solid fa-xmark"></i></button>
                                </div>
                                <form method="post" action="${ctx}/admin/menu" id="delForm">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="itemId" id="delId">
                                    <div class="modal-body">
                                        <p id="delDesc" style="color:var(--text-muted);margin-bottom:16px"></p>
                                        <div class="form-group"><label class="form-label">Lý do *</label><textarea
                                                name="reason" class="form-control" rows="2" required
                                                placeholder="Nhập lý do..."></textarea></div>
                                    </div>
                                    <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                            onclick="closeModal('delModal')">Hủy</button><button type="submit"
                                            class="btn btn-danger">Xóa</button></div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function openModal(id) { document.getElementById(id).classList.add('active') }
                            function closeModal(id) { document.getElementById(id).classList.remove('active') }
                            function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                            function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }
                            function openCreateModal() { document.getElementById('fTitle').textContent = 'Thêm sản phẩm'; document.getElementById('fBtn').textContent = 'Thêm mới'; document.getElementById('pAction').value = 'create'; document.getElementById('pId').value = ''; document.getElementById('pName').value = ''; document.getElementById('pPrice').value = ''; document.getElementById('pCost').value = ''; document.getElementById('pDesc').value = ''; document.getElementById('pIsActive').checked = true; openModal('formModal') }
                            function openEditModal(id, n, cat, pr, co, st, de) { document.getElementById('fTitle').textContent = 'Sửa sản phẩm'; document.getElementById('fBtn').textContent = 'Cập nhật'; document.getElementById('pAction').value = 'update'; document.getElementById('pId').value = id; document.getElementById('pName').value = n; document.getElementById('pCat').value = cat; document.getElementById('pPrice').value = pr; document.getElementById('pCost').value = co; document.getElementById('pIsActive').checked = (st === 'AVAILABLE'); document.getElementById('pDesc').value = de || ''; openModal('formModal') }
                            function openDeleteModal(id, n) { document.getElementById('delId').value = id; document.getElementById('delDesc').textContent = 'Xóa "' + n + '"? Không thể hoàn tác.'; openModal('delModal') }
                        </script>
            </body>

            </html>