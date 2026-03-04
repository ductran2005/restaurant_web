<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="categories" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Danh mục — Admin</title>
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
                            <h1 class="topbar-title"><i class="fa-solid fa-tags"></i> Quản lý Danh mục</h1>
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
                                    <h2>Danh mục sản phẩm</h2>
                                    <p>Quản lý danh mục thực đơn</p>
                                </div>
                                <button class="btn btn-primary" onclick="openCreateModal()"><i
                                        class="fa-solid fa-plus"></i> Thêm danh mục</button>
                            </div>
                            <form method="get" action="${ctx}/admin/categories"
                                style="margin-bottom:20px;display:flex;gap:12px">
                                <div class="search-wrap">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <input type="text" name="search" class="search-input" placeholder="Tìm theo tên..."
                                        value="${param.search}">
                                </div>
                                <button type="submit" class="btn btn-ghost"><i class="fa-solid fa-search"></i>
                                    Tìm</button>
                            </form>
                            <div class="table-card">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>Tên danh mục</th>
                                            <th>Số sản phẩm</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="cat" items="${categories}">
                                            <tr>
                                                <td style="font-weight:600">
                                                    <c:out value="${cat.categoryName}" />
                                                </td>
                                                <td>${cat.products != null ? cat.products.size() : 0}</td>
                                                <td><span
                                                        class="badge ${cat.status=='ACTIVE'?'b-success':'b-danger'}">${cat.status=='ACTIVE'?'Hoạt
                                                        động':'Tắt'}</span></td>
                                                <td>
                                                    <div style="display:flex;gap:4px">
                                                        <button class="btn btn-ghost btn-sm"
                                                            onclick="openEditModal(${cat.id},'${cat.categoryName}','${cat.status}')"
                                                            title="Sửa"><i class="fa-solid fa-pen"></i></button>
                                                        <form method="post" action="${ctx}/admin/categories"
                                                            style="display:inline">
                                                            <input type="hidden" name="action" value="toggleStatus">
                                                            <input type="hidden" name="categoryId" value="${cat.id}">
                                                            <button type="submit" class="btn btn-ghost btn-sm"
                                                                title="${cat.status=='ACTIVE'?'Tắt':'Bật'}"
                                                                style="color:${cat.status=='ACTIVE'?'var(--warning)':'var(--success)'}">
                                                                <i
                                                                    class="fa-solid ${cat.status=='ACTIVE'?'fa-toggle-on':'fa-toggle-off'}"></i>
                                                            </button>
                                                        </form>
                                                        <button class="btn btn-ghost btn-sm"
                                                            style="color:var(--destructive)"
                                                            onclick="openDeleteModal(${cat.id},'${cat.categoryName}')"
                                                            title="Xóa"><i class="fa-solid fa-trash"></i></button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty categories}">
                                            <tr>
                                                <td colspan="4" class="empty-state"><i class="fa-solid fa-tags"></i>
                                                    <h3>Chưa có danh mục</h3>
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
                    <div class="modal">
                        <div class="modal-header">
                            <h3 class="modal-title" id="formTitle">Thêm danh mục</h3><button
                                class="btn btn-ghost btn-sm" onclick="closeModal('formModal')"><i
                                    class="fa-solid fa-xmark"></i></button>
                        </div>
                        <form method="post" id="catForm" action="${ctx}/admin/categories">
                            <input type="hidden" name="action" id="catAction" value="create">
                            <input type="hidden" name="categoryId" id="catId">
                            <div class="modal-body">
                                <div class="form-group">
                                    <label class="form-label">Tên danh mục <span
                                            style="color:var(--destructive)">*</span></label>
                                    <input type="text" name="categoryName" id="catName" class="form-control" required
                                        placeholder="VD: Khai vị, Món chính...">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Trạng thái</label>
                                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
                                        <input type="checkbox" name="isActive" id="catIsActive" checked>
                                        <span id="catStatusLabel">Hoạt động</span>
                                    </label>
                                </div>
                            </div>
                            <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                    onclick="closeModal('formModal')">Hủy</button><button type="submit"
                                    class="btn btn-primary" id="formBtn">Thêm mới</button></div>
                        </form>
                    </div>
                </div>

                <%-- Delete Confirm Modal --%>
                    <div class="modal-overlay" id="deleteModal">
                        <div class="modal">
                            <div class="modal-header">
                                <h3 class="modal-title"><i class="fa-solid fa-triangle-exclamation"
                                        style="color:var(--destructive)"></i> Xóa danh mục</h3><button
                                    class="btn btn-ghost btn-sm" onclick="closeModal('deleteModal')"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" action="${ctx}/admin/categories" id="deleteForm">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="categoryId" id="deleteId">
                                <div class="modal-body">
                                    <p id="deleteDesc" style="color:var(--text-muted);margin-bottom:16px"></p>
                                    <div class="form-group"><label class="form-label">Lý do <span
                                                style="color:var(--destructive)">*</span></label><textarea name="reason"
                                            class="form-control" rows="2" required
                                            placeholder="Nhập lý do xóa..."></textarea></div>
                                </div>
                                <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                        onclick="closeModal('deleteModal')">Hủy</button><button type="submit"
                                        class="btn btn-danger">Xóa</button></div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openModal(id) { document.getElementById(id).classList.add('active') }
                        function closeModal(id) { document.getElementById(id).classList.remove('active') }
                        function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                        function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }

                        function openCreateModal() {
                            document.getElementById('formTitle').textContent = 'Thêm danh mục';
                            document.getElementById('formBtn').textContent = 'Thêm mới';
                            document.getElementById('catAction').value = 'create';
                            document.getElementById('catId').value = '';
                            document.getElementById('catName').value = '';
                            document.getElementById('catIsActive').checked = true;
                            openModal('formModal');
                        }
                        function openEditModal(id, name, status) {
                            document.getElementById('formTitle').textContent = 'Sửa danh mục';
                            document.getElementById('formBtn').textContent = 'Cập nhật';
                            document.getElementById('catAction').value = 'update';
                            document.getElementById('catId').value = id;
                            document.getElementById('catName').value = name;
                            document.getElementById('catIsActive').checked = (status === 'ACTIVE');
                            openModal('formModal');
                        }
                        function openDeleteModal(id, name) {
                            document.getElementById('deleteId').value = id;
                            document.getElementById('deleteDesc').textContent = 'Xóa danh mục "' + name + '"? Thao tác này không thể hoàn tác.';
                            openModal('deleteModal');
                        }
                    </script>
        </body>

        </html>