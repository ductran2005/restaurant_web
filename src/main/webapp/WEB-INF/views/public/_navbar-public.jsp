<%-- Public Navbar (Guest — no login) --%>
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
                <a href="${pageContext.request.contextPath}/login"
                    class="nav-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> <span class="nav-label">Đặt bàn</span>
                </a>
                <a href="${pageContext.request.contextPath}/login"
                    class="nav-link">
                    <i class="fa-solid fa-right-to-bracket"></i> <span class="nav-label">Đăng nhập</span>
                </a>
            </div>
        </div>
    </nav>
