<%-- Admin Sidebar Partial --%>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <aside class="admin-sidebar">
            <div class="sidebar-header">
                <div class="nav-brand-icon"><i class="fa-solid fa-utensils"></i></div>
                <span style="font-size:.875rem;font-weight:500">Huong Viet</span>
            </div>
            <nav class="sidebar-nav">
                <!-- Admin Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN'}">
                    <div class="sidebar-section">
                        <div class="sidebar-section-title">Quản lý</div>
                        <a href="${pageContext.request.contextPath}/admin"
                            class="sidebar-link ${sidebarActive == 'dashboard' ? 'active' : ''}">
                            <i class="fa-solid fa-chart-pie"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/categories"
                            class="sidebar-link ${sidebarActive == 'categories' ? 'active' : ''}">
                            <i class="fa-solid fa-tags"></i> Danh mục
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/menu"
                            class="sidebar-link ${sidebarActive == 'menu' ? 'active' : ''}">
                            <i class="fa-solid fa-bowl-food"></i> Thực đơn
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/tables"
                            class="sidebar-link ${sidebarActive == 'tables' ? 'active' : ''}">
                            <i class="fa-solid fa-chair"></i> Bàn & Khu vực
                        </a>
                        <%-- Phân quyền & Cấu hình: controller đã xóa (không có bảng permissions/system_configs trong
                            DB) --%>
                    </div>
                </c:if>

                <!-- Staff Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN' || sessionScope.user.role.name == 'STAFF'}">
                    <div class="sidebar-section">
                        <div class="sidebar-section-title">Phục vụ</div>
                        <a href="${pageContext.request.contextPath}/staff"
                            class="sidebar-link ${sidebarActive == 'tablemap' ? 'active' : ''}">
                            <i class="fa-solid fa-map"></i> Sơ đồ bàn
                        </a>
                        <%-- Booking: controller đã xóa (không có bảng bookings trong DB) --%>
                            <a href="${pageContext.request.contextPath}/staff/orders"
                                class="sidebar-link ${sidebarActive == 'orders' ? 'active' : ''}">
                                <i class="fa-solid fa-clipboard-list"></i> Order
                            </a>
                    </div>
                </c:if>

                <!-- Cashier Section -->
                <c:if test="${sessionScope.user.role.name == 'ADMIN' || sessionScope.user.role.name == 'CASHIER'}">
                    <div class="sidebar-section">
                        <div class="sidebar-section-title">Thu ngân</div>
                        <a href="${pageContext.request.contextPath}/cashier"
                            class="sidebar-link ${sidebarActive == 'invoices' ? 'active' : ''}">
                            <i class="fa-solid fa-file-invoice-dollar"></i> Hóa đơn
                        </a>
                    </div>
                </c:if>
            </nav>
            <div class="sidebar-footer">
                <div style="display:flex;align-items:center;gap:.5rem;margin-bottom:.5rem">
                    <div
                        style="width:2rem;height:2rem;border-radius:50%;background:var(--primary);color:var(--primary-fg);display:flex;align-items:center;justify-content:center;font-size:.75rem;font-weight:700">
                        ${sessionScope.user.fullName.substring(0,1)}
                    </div>
                    <div>
                        <div style="font-size:.8125rem;font-weight:600">${sessionScope.user.fullName}</div>
                        <div style="font-size:.6875rem;color:var(--muted-fg)">${sessionScope.user.role.name}</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-ghost btn-sm btn-block"
                    style="justify-content:flex-start">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </div>
        </aside>