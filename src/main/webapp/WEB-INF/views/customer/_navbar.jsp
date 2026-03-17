<%-- Customer Navbar Partial (Logged-in Customer viewing public pages) --%>
    <nav class="top-navbar">
        <div class="nav-inner">
            <a href="${pageContext.request.contextPath}/" class="nav-brand">
                <div class="nav-brand-icon"><i class="fa-solid fa-utensils"></i></div>
                <span>Nhà hàng Hương Việt</span>
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/menu"
                    class="nav-link ${navActive == 'menu' ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> <span class="nav-label">Thực đơn</span>
                </a>
                <a href="${pageContext.request.contextPath}/about"
                    class="nav-link ${navActive == 'about' ? 'active' : ''}">
                    <i class="fa-solid fa-info-circle"></i> <span class="nav-label">Về chúng tôi</span>
                </a>
                <a href="${pageContext.request.contextPath}/contact"
                    class="nav-link ${navActive == 'contact' ? 'active' : ''}">
                    <i class="fa-solid fa-phone"></i> <span class="nav-label">Liên hệ</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/create"
                    class="nav-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> <span class="nav-label">Đặt bàn</span>
                </a>
                <a href="${pageContext.request.contextPath}/logout"
                    class="nav-link">
                    <i class="fa-solid fa-right-from-bracket"></i> <span class="nav-label">Đăng xuất</span>
                </a>
            </div>
            <button class="mobile-burger" onclick="document.getElementById('mobileDrawerCustomer').classList.add('open')" aria-label="Menu">
                <i class="fa-solid fa-bars"></i>
            </button>
        </div>
    </nav>

    <%-- Mobile Drawer --%>
    <div class="mobile-drawer" id="mobileDrawerCustomer">
        <div class="mobile-drawer-overlay" onclick="this.parentElement.classList.remove('open')"></div>
        <div class="mobile-drawer-panel">
            <div class="mobile-drawer-header">
                <a href="${pageContext.request.contextPath}/" class="nav-brand">
                    <div class="nav-brand-icon"><i class="fa-solid fa-utensils"></i></div>
                    <span>Hương Việt</span>
                </a>
                <button class="mobile-drawer-close" onclick="document.getElementById('mobileDrawerCustomer').classList.remove('open')" aria-label="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="mobile-drawer-body">
                <a href="${pageContext.request.contextPath}/menu" class="mobile-drawer-link ${navActive == 'menu' ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> Thực đơn
                </a>
                <a href="${pageContext.request.contextPath}/about" class="mobile-drawer-link ${navActive == 'about' ? 'active' : ''}">
                    <i class="fa-solid fa-info-circle"></i> Về chúng tôi
                </a>
                <a href="${pageContext.request.contextPath}/contact" class="mobile-drawer-link ${navActive == 'contact' ? 'active' : ''}">
                    <i class="fa-solid fa-phone"></i> Liên hệ
                </a>
                <a href="${pageContext.request.contextPath}/user/booking/create" class="mobile-drawer-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> Đặt bàn
                </a>
                <div class="mobile-drawer-divider"></div>
                <a href="${pageContext.request.contextPath}/logout" class="mobile-drawer-link mobile-drawer-cta">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </div>
        </div>
    </div>