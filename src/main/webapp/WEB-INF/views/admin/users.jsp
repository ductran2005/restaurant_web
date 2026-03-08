<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="users" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Quản lý Người dùng — Admin</title>
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
                            <h1 class="topbar-title"><i class="fa-solid fa-users"></i> Quản lý Người dùng</h1>
                            <div class="topbar-right">
                                <span class="badge-role">${sessionScope.user.role.name}</span>
                            </div>
                        </header>

                        <div class="content">
                            <%-- Flash messages --%>
                                <c:if test="${not empty sessionScope.flash_msg}">
                                    <div class="alert alert-success"><i class="fa-solid fa-check-circle"></i>
                                        ${sessionScope.flash_msg}</div>
                                    <c:remove var="flash_msg" scope="session" />
                                </c:if>
                                <c:if test="${not empty sessionScope.flash_error}">
                                    <div class="alert alert-error"><i class="fa-solid fa-circle-exclamation"></i>
                                        ${sessionScope.flash_error}</div>
                                    <c:remove var="flash_error" scope="session" />
                                </c:if>

                                <%-- Header --%>
                                    <div class="page-header">
                                        <div class="page-header-left">
                                            <h2>Danh sách người dùng</h2>
                                            <p>Quản lý tài khoản nhân viên và khách hàng</p>
                                        </div>
                                        <button class="btn btn-primary" onclick="openModal('createModal')">
                                            <i class="fa-solid fa-plus"></i> Thêm người dùng
                                        </button>
                                    </div>

                                    <%-- Search & Filter --%>
                                        <div style="display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap">
                                            <form method="get" action="${ctx}/admin/users"
                                                style="display:flex;gap:12px;flex-wrap:wrap;flex:1">
                                                <div class="search-wrap">
                                                    <i class="fa-solid fa-magnifying-glass"></i>
                                                    <input type="text" name="search" class="search-input"
                                                        placeholder="Tìm theo tên, email, SĐT..."
                                                        value="${param.search}">
                                                </div>
                                                <select name="role" class="form-control" style="width:160px">
                                                    <option value="">Tất cả vai trò</option>
                                                    <option value="ADMIN" ${param.role=='ADMIN' ? 'selected' : '' }>
                                                        Admin</option>
                                                    <option value="STAFF" ${param.role=='STAFF' ? 'selected' : '' }>
                                                        Staff</option>
                                                    <option value="CASHIER" ${param.role=='CASHIER' ? 'selected' : '' }>
                                                        Cashier</option>
                                                    <option value="CUSTOMER" ${param.role=='CUSTOMER' ? 'selected' : ''
                                                        }>Customer</option>
                                                </select>
                                                <button type="submit" class="btn btn-ghost"><i
                                                        class="fa-solid fa-filter"></i> Lọc</button>
                                            </form>
                                        </div>

                                        <%-- Users Table --%>
                                            <div class="table-card">
                                                <table class="admin-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Họ tên</th>
                                                            <th>Username</th>
                                                            <th>Email</th>
                                                            <th>SĐT</th>
                                                            <th>Vai trò</th>
                                                            <th>Trạng thái</th>
                                                            <th>Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="u" items="${users}">
                                                            <tr data-id="${u.id}" data-fullname="${u.fullName}"
                                                                data-username="${u.username}" data-email="${u.email}"
                                                                data-phone="${u.phone}" data-role="${u.role.id}">
                                                                <td style="font-weight:600">${u.fullName}</td>
                                                                <td style="color:var(--text-muted)">${u.username}</td>
                                                                <td style="color:var(--text-muted)">${u.email}</td>
                                                                <td>${u.phone}</td>
                                                                <td>
                                                                    <span
                                                                        class="badge ${u.role.name == 'ADMIN' ? 'b-primary' : u.role.name == 'STAFF' ? 'b-info' : u.role.name == 'CASHIER' ? 'b-success' : 'b-warning'}">
                                                                        ${u.role.name}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <span
                                                                        class="badge ${u.status == 'ACTIVE' ? 'b-success' : 'b-danger'}">
                                                                        <i
                                                                            class="fa-solid ${u.status == 'ACTIVE' ? 'fa-check-circle' : 'fa-lock'}"></i>
                                                                        ${u.status == 'ACTIVE' ? 'Hoạt động' : 'Khóa'}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <div style="display:flex;gap:4px">
                                                                        <button class="btn btn-ghost btn-sm"
                                                                            onclick="editUser(${u.id})" title="Sửa">
                                                                            <i class="fa-solid fa-pen"></i>
                                                                        </button>
                                                                        <c:if test="${u.status == 'ACTIVE'}">
                                                                            <button class="btn btn-ghost btn-sm"
                                                                                onclick="confirmAction('lock', ${u.id}, '${u.fullName}')"
                                                                                title="Khóa"
                                                                                style="color:var(--warning)">
                                                                                <i class="fa-solid fa-lock"></i>
                                                                            </button>
                                                                        </c:if>
                                                                        <c:if test="${u.status != 'ACTIVE'}">
                                                                            <button class="btn btn-ghost btn-sm"
                                                                                onclick="confirmAction('unlock', ${u.id}, '${u.fullName}')"
                                                                                title="Mở khóa"
                                                                                style="color:var(--success)">
                                                                                <i class="fa-solid fa-lock-open"></i>
                                                                            </button>
                                                                        </c:if>
                                                                        <button class="btn btn-ghost btn-sm"
                                                                            onclick="confirmAction('resetpw', ${u.id}, '${u.fullName}')"
                                                                            title="Reset mật khẩu"
                                                                            style="color:var(--info)">
                                                                            <i class="fa-solid fa-key"></i>
                                                                        </button>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty users}">
                                                            <tr>
                                                                <td colspan="7" class="empty-state"><i
                                                                        class="fa-solid fa-users"></i>
                                                                    <h3>Chưa có người dùng</h3>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </tbody>
                                                </table>
                                            </div>
                        </div>
                    </div>
            </div>

            <%-- CREATE/EDIT MODAL --%>
                <div class="modal-overlay" id="createModal">
                    <div class="modal">
                        <div class="modal-header">
                            <h3 class="modal-title" id="modalTitle">Thêm người dùng</h3>
                            <button class="btn btn-ghost btn-sm" onclick="closeModal('createModal')"><i
                                    class="fa-solid fa-xmark"></i></button>
                        </div>
                        <form method="post" action="${ctx}/admin/users/save" id="userForm">
                            <input type="hidden" name="userId" id="userId">
                            <div class="modal-body">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Họ tên <span
                                                style="color:var(--destructive)">*</span></label>
                                        <input type="text" name="fullName" id="fullName" class="form-control" required>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Username <span
                                                style="color:var(--destructive)">*</span></label>
                                        <input type="text" name="username" id="usernameField" class="form-control"
                                            required>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Email</label>
                                        <input type="email" name="email" id="emailField" class="form-control">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">SĐT</label>
                                        <input type="tel" name="phone" id="phoneField" class="form-control">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Vai trò <span
                                                style="color:var(--destructive)">*</span></label>
                                        <select name="roleId" id="roleField" class="form-control" required>
                                            <c:forEach var="r" items="${roles}">
                                                <option value="${r.id}">${r.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-group" id="passwordGroup">
                                        <label class="form-label">Mật khẩu <span
                                                style="color:var(--destructive)">*</span></label>
                                        <input type="password" name="password" id="passwordField" class="form-control">
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-ghost"
                                    onclick="closeModal('createModal')">Hủy</button>
                                <button type="submit" class="btn btn-primary" id="submitBtn">Thêm mới</button>
                            </div>
                        </form>
                    </div>
                </div>

                <%-- CONFIRM MODAL --%>
                    <div class="modal-overlay" id="confirmModal">
                        <div class="modal">
                            <div class="modal-header">
                                <h3 class="modal-title" id="confirmTitle">Xác nhận</h3>
                                <button class="btn btn-ghost btn-sm" onclick="closeModal('confirmModal')"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" id="confirmForm">
                                <div class="modal-body">
                                    <p id="confirmDesc" style="color:var(--text-muted);margin-bottom:16px"></p>
                                    <div class="form-group">
                                        <label class="form-label">Lý do <span
                                                style="color:var(--destructive)">*</span></label>
                                        <textarea name="reason" class="form-control" rows="3" required
                                            placeholder="Nhập lý do..."></textarea>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-ghost"
                                        onclick="closeModal('confirmModal')">Hủy</button>
                                    <button type="submit" class="btn btn-danger" id="confirmBtn">Xác nhận</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openModal(id) { document.getElementById(id).classList.add('active'); }
                        function closeModal(id) { document.getElementById(id).classList.remove('active'); }
                        function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                        function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }

                        function editUser(id) {
                            const row = document.querySelector('tr[data-id="' + id + '"]');
                            document.getElementById('modalTitle').textContent = 'Sửa người dùng';
                            document.getElementById('submitBtn').textContent = 'Cập nhật';
                            document.getElementById('userId').value = id;
                            if (row) {
                                document.getElementById('fullName').value = row.dataset.fullname || '';
                                document.getElementById('usernameField').value = row.dataset.username || '';
                                document.getElementById('emailField').value = row.dataset.email || '';
                                document.getElementById('phoneField').value = row.dataset.phone || '';
                                document.getElementById('roleField').value = row.dataset.role || '';
                            }
                            document.getElementById('userForm').action = '${ctx}/admin/users/update';
                            document.getElementById('passwordGroup').style.display = 'none';
                            openModal('createModal');
                        }

                        function confirmAction(action, id, name) {
                            const form = document.getElementById('confirmForm');
                            const title = document.getElementById('confirmTitle');
                            const desc = document.getElementById('confirmDesc');
                            if (action === 'lock') {
                                title.textContent = 'Khóa tài khoản';
                                desc.textContent = 'Khóa tài khoản "' + name + '"? Người dùng sẽ không thể đăng nhập.';
                                form.action = '${ctx}/admin/users/lock?id=' + id;
                            } else if (action === 'unlock') {
                                title.textContent = 'Mở khóa tài khoản';
                                desc.textContent = 'Mở khóa tài khoản "' + name + '"?';
                                form.action = '${ctx}/admin/users/unlock?id=' + id;
                            } else if (action === 'resetpw') {
                                title.textContent = 'Reset mật khẩu';
                                desc.textContent = 'Reset mật khẩu cho "' + name + '"? Mật khẩu mới sẽ là "123456".';
                                form.action = '${ctx}/admin/users/reset-password?id=' + id;
                            }
                            openModal('confirmModal');
                        }
                    </script>
        </body>

        </html>