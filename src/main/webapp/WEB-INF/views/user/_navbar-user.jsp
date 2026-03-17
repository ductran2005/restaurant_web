<%-- User Navbar (Logged-in CUSTOMER) --%>
    <nav class="top-navbar">
        <div class="nav-inner">
            <a href="${pageContext.request.contextPath}/user/home" class="nav-brand">
                <div class="nav-brand-icon"><i class="fa-solid fa-utensils"></i></div>
                <span>Nhà hàng Hương Việt</span>
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/user/menu"
                    class="nav-link ${navActive == 'menu' ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> <span class="nav-label">Thực đơn</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/create"
                    class="nav-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> <span class="nav-label">Đặt bàn</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/status"
                    class="nav-link ${navActive == 'status' ? 'active' : ''}">
                    <i class="fa-solid fa-magnifying-glass"></i> <span class="nav-label">Tra cứu booking</span>
                </a>
                <a href="${pageContext.request.contextPath}/logout"
                    class="nav-link">
                    <i class="fa-solid fa-right-from-bracket"></i> <span class="nav-label">Đăng xuất</span>
                </a>
            </div>
            <button class="mobile-burger" onclick="document.getElementById('mobileDrawerUser').classList.add('open')" aria-label="Menu">
                <i class="fa-solid fa-bars"></i>
            </button>
        </div>
    </nav>

    <%-- Mobile Drawer --%>
    <div class="mobile-drawer" id="mobileDrawerUser">
        <div class="mobile-drawer-overlay" onclick="this.parentElement.classList.remove('open')"></div>
        <div class="mobile-drawer-panel">
            <div class="mobile-drawer-header">
                <a href="${pageContext.request.contextPath}/user/home" class="nav-brand">
                    <div class="nav-brand-icon"><i class="fa-solid fa-utensils"></i></div>
                    <span>Hương Việt</span>
                </a>
                <button class="mobile-drawer-close" onclick="document.getElementById('mobileDrawerUser').classList.remove('open')" aria-label="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="mobile-drawer-body">
                <a href="${pageContext.request.contextPath}/user/menu" class="mobile-drawer-link ${navActive == 'menu' ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> Thực đơn
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/create" class="mobile-drawer-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> Đặt bàn
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/status" class="mobile-drawer-link ${navActive == 'status' ? 'active' : ''}">
                    <i class="fa-solid fa-magnifying-glass"></i> Tra cứu booking
                </a>
                <a href="${pageContext.request.contextPath}/user/pre-order" class="mobile-drawer-link ${navActive == 'preorder' ? 'active' : ''}">
                    <i class="fa-solid fa-cart-shopping"></i> Đặt món trước
                </a>
                <a href="${pageContext.request.contextPath}/user/profile" class="mobile-drawer-link ${navActive == 'profile' ? 'active' : ''}">
                    <i class="fa-solid fa-user"></i> Tài khoản
                </a>
                <div class="mobile-drawer-divider"></div>
                <a href="${pageContext.request.contextPath}/logout" class="mobile-drawer-link mobile-drawer-cta">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </div>
        </div>
    </div>
