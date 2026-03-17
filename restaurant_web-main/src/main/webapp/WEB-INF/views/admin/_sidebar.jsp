<%-- Admin Sidebar Partial --%>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-logo">
                <div class="sidebar-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                <div>
                    <div class="sidebar-logo-name">Hương Việt</div>
                    <div class="sidebar-logo-role">${sessionScope.user.role.name}</div>
                </div>
            </div>
            <nav class="sidebar-nav">
                <!-- Admin Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN'}">
                    <div class="nav-group-label">Quản trị</div>
                    <a href="${pageContext.request.contextPath}/admin"
                        class="nav-item ${sidebarActive == 'dashboard' ? 'active' : ''}">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/categories"
                        class="nav-item ${sidebarActive == 'categories' ? 'active' : ''}">
                        <i class="fa-solid fa-tags"></i> Danh mục
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/menu"
                        class="nav-item ${sidebarActive == 'menu' ? 'active' : ''}">
                        <i class="fa-solid fa-bowl-food"></i> Thực đơn
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/tables"
                        class="nav-item ${sidebarActive == 'tables' ? 'active' : ''}">
                        <i class="fa-solid fa-chair"></i> Bàn & Khu vực
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/users"
                        class="nav-item ${sidebarActive == 'users' ? 'active' : ''}">
                        <i class="fa-solid fa-users"></i> Người dùng
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/rbac"
                        class="nav-item ${sidebarActive == 'rbac' ? 'active' : ''}">
                        <i class="fa-solid fa-shield-halved"></i> Phân quyền
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/reports"
                        class="nav-item ${sidebarActive == 'reports' ? 'active' : ''}">
                        <i class="fa-solid fa-chart-bar"></i> Báo cáo
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/config"
                        class="nav-item ${sidebarActive == 'config' ? 'active' : ''}">
                        <i class="fa-solid fa-gear"></i> Cấu hình
                    </a>
                </c:if>

                <!-- Staff Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN' || sessionScope.user.role.name == 'STAFF'}">
                    <div class="nav-group-label">Phục vụ</div>
                    <a href="${pageContext.request.contextPath}/staff"
                        class="nav-item ${sidebarActive == 'tablemap' ? 'active' : ''}">
                        <i class="fa-solid fa-map"></i> Sơ đồ bàn
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/bookings"
                        class="nav-item ${sidebarActive == 'bookings' ? 'active' : ''}">
                        <i class="fa-solid fa-calendar-check"></i> Booking
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/orders"
                        class="nav-item ${sidebarActive == 'orders' ? 'active' : ''}">
                        <i class="fa-solid fa-clipboard-list"></i> Order
                    </a>
                </c:if>

                <!-- Cashier Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN' || sessionScope.user.role.name == 'CASHIER'}">
                    <div class="nav-group-label">Thu ngân</div>
                    <a href="${pageContext.request.contextPath}/cashier"
                        class="nav-item ${sidebarActive == 'invoices' ? 'active' : ''}">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Hóa đơn
                    </a>
                    <a href="${pageContext.request.contextPath}/cashier/checkout"
                        class="nav-item ${sidebarActive == 'checkout' ? 'active' : ''}">
                        <i class="fa-solid fa-cash-register"></i> Thanh toán
                    </a>
                </c:if>
            </nav>
            <div class="sidebar-user">
                <div class="sidebar-avatar">${sessionScope.user.fullName.substring(0,1)}</div>
                <div>
                    <div class="sidebar-user-name">${sessionScope.user.fullName}</div>
                    <div class="sidebar-user-role">${sessionScope.user.role.name}</div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" title="Đăng xuất"
                    style="margin-left:auto;color:var(--text-muted)"><i class="fa-solid fa-right-from-bracket"></i></a>
            </div>
        </aside>