<%-- Customer Navbar Partial --%>
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
                <%-- Booking: controller đã xóa (không có bảng bookings trong DB) <a
                    href="${pageContext.request.contextPath}/booking/create"
                    class="nav-link ${navActive == 'booking' ? 'active' : ''}">
                    <i class="fa-solid fa-calendar-plus"></i> <span class="nav-label">Đặt bàn</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/booking/status"
                        class="nav-link ${navActive == 'status' ? 'active' : ''}">
                        <i class="fa-solid fa-magnifying-glass"></i> <span class="nav-label">Tra cứu</span>
                    </a>
                    --%>
                    <%-- Pre-order: controller đã xóa (không có bảng booking_items trong DB) <a
                        href="${pageContext.request.contextPath}/pre-order"
                        class="nav-link ${navActive == 'preorder' ? 'active' : ''}">
                        <i class="fa-solid fa-cart-shopping"></i> <span class="nav-label">Đặt món trước</span>
                        </a>
                        --%>
                        <a href="${pageContext.request.contextPath}/about"
                            class="nav-link ${navActive == 'about' ? 'active' : ''}">
                            <i class="fa-solid fa-info-circle"></i> <span class="nav-label">Về chúng tôi</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/contact"
                            class="nav-link ${navActive == 'contact' ? 'active' : ''}">
                            <i class="fa-solid fa-phone"></i> <span class="nav-label">Liên hệ</span>
                        </a>
            </div>
            <%-- Login/Register đã chuyển sang dành riêng cho nhà hàng (admin/staff/cashier) --%>
                <%-- Khách hàng không cần đăng nhập --%>
        </div>
    </nav>