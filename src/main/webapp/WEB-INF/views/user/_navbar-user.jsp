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
        </div>
    </nav>
