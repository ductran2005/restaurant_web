<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tra cứu đặt bàn — Nhà hàng Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
                <!-- intl-tel-input styles -->
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/css/intlTelInput.css">
                <style>
                    .lookup-hero {
                        padding: 140px 48px 40px;
                        text-align: center;
                        position: relative;
                    }

                    .lookup-hero::before {
                        content: '';
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, 0.08) 0%, transparent 60%);
                        pointer-events: none;
                    }

                    .lookup-hero h1 {
                        font-family: var(--font-serif);
                        font-size: clamp(28px, 4vw, 44px);
                        color: var(--text);
                        margin-bottom: 10px;
                    }

                    .lookup-hero h1 em {
                        color: var(--primary);
                        font-style: italic;
                    }

                    .lookup-hero p {
                        font-size: 15px;
                        color: var(--text-muted);
                        max-width: 480px;
                        margin: 0 auto;
                    }

                    .lookup-section {
                        max-width: 700px;
                        margin: 0 auto;
                        padding: 0 24px 80px;
                    }

                    /* Search Card */
                    .search-card {
                        background: rgba(26, 24, 20, 0.8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 32px;
                        backdrop-filter: blur(12px);
                        margin-bottom: 24px;
                    }

                    .search-form {
                        display: flex;
                        flex-direction: column;
                        gap: 0;
                    }

                    .form-field {
                        display: flex;
                        flex-direction: column;
                        gap: 6px;
                    }

                    .form-field label {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                        letter-spacing: .03em;
                    }

                    .search-form .form-control {
                        width: 100%;
                        background: rgba(255, 255, 255, 0.05);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 13px 16px;
                        color: var(--text);
                        font-size: 15px;
                        font-family: inherit;
                        outline: none;
                        box-sizing: border-box;
                        transition: border-color .2s, box-shadow .2s;
                    }

                    .search-form .form-control::placeholder {
                        color: var(--text-muted);
                    }

                    .search-form .form-control:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, 0.1);
                    }

                    /* Divider "hoặc" */
                    .or-divider {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        margin: 20px 0;
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    .or-divider::before,
                    .or-divider::after {
                        content: '';
                        flex: 1;
                        height: 1px;
                        background: var(--border);
                    }

                    .btn-search {
                        margin-top: 24px;
                        width: 100%;
                        padding: 14px;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 10px;
                        font-weight: 700;
                        font-size: 15px;
                        font-family: inherit;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                        transition: background .2s;
                    }

                    .btn-search:hover {
                        background: #cfa730;
                    }

                    /* Result Card */
                    .result-card {
                        background: rgba(26, 24, 20, 0.8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        overflow: hidden;
                        backdrop-filter: blur(12px);
                    }

                    .result-header {
                        padding: 20px 24px;
                        border-bottom: 1px solid var(--border);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        flex-wrap: wrap;
                        gap: 12px;
                    }

                    .result-header h3 {
                        font-size: 16px;
                        color: var(--text);
                    }

                    .result-body {
                        padding: 24px;
                    }

                    /* Status Banner */
                    .status-banner {
                        padding: 16px 20px;
                        border-radius: 12px;
                        margin-bottom: 20px;
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        font-size: 14px;
                    }

                    .status-banner i {
                        font-size: 20px;
                    }

                    .status-banner .status-title {
                        font-weight: 700;
                    }

                    .status-banner .status-desc {
                        font-size: 13px;
                        opacity: 0.85;
                    }

                    .s-pending {
                        background: rgba(245, 158, 11, 0.1);
                        border: 1px solid rgba(245, 158, 11, 0.2);
                        color: #fbbf24;
                    }

                    .s-confirmed {
                        background: rgba(34, 197, 94, 0.1);
                        border: 1px solid rgba(34, 197, 94, 0.2);
                        color: #4ade80;
                    }

                    .s-checked_in {
                        background: rgba(59, 130, 246, 0.1);
                        border: 1px solid rgba(59, 130, 246, 0.2);
                        color: #60a5fa;
                    }

                    .s-cancelled {
                        background: rgba(239, 68, 68, 0.1);
                        border: 1px solid rgba(239, 68, 68, 0.2);
                        color: #f87171;
                    }

                    .s-no_show {
                        background: rgba(156, 163, 175, 0.1);
                        border: 1px solid rgba(156, 163, 175, 0.2);
                        color: #9ca3af;
                    }

                    .s-completed {
                        background: rgba(99, 102, 241, 0.1);
                        border: 1px solid rgba(99, 102, 241, 0.2);
                        color: #a5b4fc;
                    }

                    /* Info Grid */
                    .info-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 16px;
                        margin-bottom: 24px;
                    }

                    .info-item {
                        background: rgba(255, 255, 255, 0.03);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 14px 16px;
                    }

                    .info-item .info-label {
                        font-size: 11px;
                        color: var(--text-muted);
                        text-transform: uppercase;
                        letter-spacing: .06em;
                        margin-bottom: 4px;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .info-item .info-value {
                        font-size: 15px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    /* Pre-order Items */
                    .preorder-section h4 {
                        font-size: 14px;
                        color: var(--text);
                        margin-bottom: 12px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .preorder-item {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 10px 0;
                        border-bottom: 1px solid var(--border);
                        font-size: 13px;
                    }

                    .preorder-item:last-child {
                        border-bottom: none;
                    }

                    .preorder-item .item-name {
                        color: var(--text);
                        font-weight: 500;
                    }

                    .preorder-item .item-qty {
                        color: var(--text-muted);
                    }

                    .preorder-item .item-price {
                        color: var(--primary);
                        font-weight: 600;
                    }

                    /* Action Buttons */
                    .result-actions {
                        display: flex;
                        gap: 10px;
                        flex-wrap: wrap;
                        padding: 16px 24px;
                        border-top: 1px solid var(--border);
                    }

                    .btn-action {
                        padding: 10px 18px;
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        color: var(--text);
                        background: none;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        font-family: inherit;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        transition: all .25s;
                        text-decoration: none;
                    }

                    .btn-action:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .btn-action.primary {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    .btn-action.primary:hover {
                        background: #cfa730;
                    }

                    /* Badge */
                    .badge-status {
                        padding: 4px 12px;
                        border-radius: 99px;
                        font-size: 11px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .04em;
                    }

                    .badge-pending {
                        background: rgba(245, 158, 11, 0.15);
                        color: #fbbf24;
                    }

                    .badge-confirmed {
                        background: rgba(34, 197, 94, 0.15);
                        color: #4ade80;
                    }

                    .badge-checked_in {
                        background: rgba(59, 130, 246, 0.15);
                        color: #60a5fa;
                    }

                    .badge-cancelled {
                        background: rgba(239, 68, 68, 0.15);
                        color: #f87171;
                    }

                    .badge-completed {
                        background: rgba(99, 102, 241, 0.15);
                        color: #a5b4fc;
                    }

                    .badge-no_show {
                        background: rgba(156, 163, 175, 0.15);
                        color: #9ca3af;
                    }

                    /* Empty/Error */
                    .lookup-empty {
                        text-align: center;
                        padding: 60px 24px;
                        color: var(--text-muted);
                    }

                    .lookup-empty i {
                        font-size: 3rem;
                        opacity: .3;
                        margin-bottom: 16px;
                    }

                    .lookup-empty h3 {
                        font-size: 16px;
                        color: var(--text);
                        margin-bottom: 6px;
                    }

                    .alert-error {
                        background: rgba(239, 68, 68, 0.08);
                        border: 1px solid rgba(239, 68, 68, 0.2);
                        color: #f87171;
                        padding: 12px 16px;
                        border-radius: 10px;
                        font-size: 13px;
                        margin-bottom: 20px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    @media (max-width: 640px) {
                        .lookup-hero {
                            padding: 120px 20px 32px;
                        }

                        .lookup-section {
                            padding: 0 16px 60px;
                        }
                    }

                    /* intl-tel-input dark theme */
                    .iti {
                        width: 100%;
                    }

                    .iti--separate-dial-code .iti__selected-flag,
                    .iti__country-list {
                        background: #1a1814;
                        border-color: rgba(255, 255, 255, .1);
                    }

                    .iti__country-list {
                        max-height: 220px;
                    }

                    .iti__country-list .iti__country-name,
                    .iti__dial-code {
                        color: #f0ebe3;
                    }

                    .iti__country-list .iti__country.iti__highlight,
                    .iti__country-list .iti__country:hover {
                        background: rgba(232, 160, 32, .15);
                    }

                    .iti__selected-dial-code {
                        color: #9e9488;
                    }
                </style>
            </head>

            <body>

                <!-- ── NAVBAR ── -->
                <nav class="navbar" id="navbar">
                    <a href="${pageContext.request.contextPath}/" class="nav-logo">
                        <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                    </a>
                    <div class="nav-links">
                        <a href="${pageContext.request.contextPath}/menu">Thực đơn</a>
                        <a href="${pageContext.request.contextPath}/booking">Đặt bàn</a>
                        <a href="${pageContext.request.contextPath}/booking/status" class="active">Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/pre-order">Đặt món trước</a>
                    </div>
                    <div class="nav-actions">
                        <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
                    </div>
                    <div class="nav-burger" id="navBurger"><span></span><span></span><span></span></div>
                </nav>

                <!-- ── HERO ── -->
                <section class="lookup-hero">
                    <div class="section-label"><i class="fa-solid fa-magnifying-glass"></i> Tra cứu đặt bàn</div>
                    <h1>Kiểm tra trạng thái <em>booking</em></h1>
                    <p>Nhập mã đặt bàn và số điện thoại để tra cứu thông tin chi tiết.</p>
                </section>

                <!-- ── CONTENT ── -->
                <div class="lookup-section">

                    <!-- Search Form -->
                    <div class="search-card">
                        <form method="get" action="${pageContext.request.contextPath}/booking/status"
                            class="search-form">
                            <div class="form-field">
                                <label for="searchCode">Mã booking</label>
                                <input type="text" id="searchCode" name="code" class="form-control"
                                    placeholder="BK-2026-001" value="${param.code}">
                            </div>

                            <div class="or-divider">hoặc</div>

                            <div class="form-field">
                                <label for="searchPhone">Số điện thoại</label>
                                <input type="tel" id="searchPhone" name="phone" class="form-control"
                                    placeholder="0901234567" value="${param.phone}">
                            </div>

                            <button type="submit" class="btn-search">
                                <i class="fa-solid fa-magnifying-glass"></i> Tra cứu
                            </button>
                        </form>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}</div>
                    </c:if>
                    <c:if test="${msg == 'confirmed'}">
                        <div class="alert-success"><i class="fa-solid fa-circle-check"></i> Đã xác nhận booking.</div>
                    </c:if>

                    <c:choose>
                        <%-- Search by code: single booking result --%>
                            <c:when test="${not empty booking}">
                                <!-- RESULT -->
                                <div class="result-card">
                                    <div class="result-header">
                                        <h3><i class="fa-solid fa-ticket" style="color:var(--primary)"></i>
                                            ${booking.bookingCode}</h3>
                                        <span
                                            class="badge-status badge-${booking.status.toLowerCase()}">${booking.status}</span>
                                    </div>
                                    <div class="result-body">
                                        <!-- Status Banner -->
                                        <c:choose>
                                            <c:when test="${booking.status == 'PENDING'}">
                                                <div class="status-banner s-pending">
                                                    <i class="fa-solid fa-clock"></i>
                                                    <div>
                                                        <div class="status-title">Đang chờ xác nhận</div>
                                                        <div class="status-desc">Nhà hàng sẽ xác nhận booking của bạn
                                                            sớm
                                                            nhất có thể.</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${booking.status == 'CONFIRMED'}">
                                                <div class="status-banner s-confirmed">
                                                    <i class="fa-solid fa-circle-check"></i>
                                                    <div>
                                                        <div class="status-title">Đã xác nhận</div>
                                                        <div class="status-desc">Booking đã được xác nhận. Vui lòng đến
                                                            đúng giờ!</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${booking.status == 'CHECKED_IN'}">
                                                <div class="status-banner s-checked_in">
                                                    <i class="fa-solid fa-right-to-bracket"></i>
                                                    <div>
                                                        <div class="status-title">Đã check-in</div>
                                                        <div class="status-desc">Chào mừng bạn! Chúc bạn có bữa tối vui
                                                            vẻ.</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${booking.status == 'CANCELLED'}">
                                                <div class="status-banner s-cancelled">
                                                    <i class="fa-solid fa-circle-xmark"></i>
                                                    <div>
                                                        <div class="status-title">Đã hủy</div>
                                                        <div class="status-desc">
                                                            <c:choose>
                                                                <c:when test="${not empty booking.cancelReason}">
                                                                    Lý do: <strong>${booking.cancelReason}</strong>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    Booking đã bị hủy. Vui lòng đặt lại nếu cần.
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${booking.status == 'COMPLETED'}">
                                                <div class="status-banner s-completed">
                                                    <i class="fa-solid fa-flag-checkered"></i>
                                                    <div>
                                                        <div class="status-title">Hoàn thành</div>
                                                        <div class="status-desc">Cảm ơn bạn đã sử dụng dịch vụ! Hẹn gặp
                                                            lại.</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${booking.status == 'NO_SHOW'}">
                                                <div class="status-banner s-no_show">
                                                    <i class="fa-solid fa-user-xmark"></i>
                                                    <div>
                                                        <div class="status-title">Không đến</div>
                                                        <div class="status-desc">Bạn đã không đến theo lịch hẹn.</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                        </c:choose>

                                        <!-- Booking Info -->
                                        <div class="info-grid">
                                            <div class="info-item">
                                                <div class="info-label"><i class="fa-solid fa-user"></i> Khách hàng
                                                </div>
                                                <div class="info-value">${booking.customerName}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label"><i class="fa-solid fa-phone"></i> Điện thoại
                                                </div>
                                                <div class="info-value">${booking.customerPhone}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label"><i class="fa-solid fa-calendar"></i> Ngày</div>
                                                <div class="info-value">${booking.bookingDate}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label"><i class="fa-solid fa-clock"></i> Giờ</div>
                                                <div class="info-value">${booking.bookingTime}</div>
                                            </div>
                                            <div class="info-item">
                                                <div class="info-label"><i class="fa-solid fa-users"></i> Số khách</div>
                                                <div class="info-value">${booking.partySize} người</div>
                                            </div>
                                            <c:if test="${not empty booking.tableName}">
                                                <div class="info-item">
                                                    <div class="info-label"><i class="fa-solid fa-chair"></i> Bàn</div>
                                                    <div class="info-value">${booking.tableName}</div>
                                                </div>
                                            </c:if>
                                        </div>

                                        <c:if test="${not empty booking.note}">
                                            <div class="info-item" style="margin-bottom:20px">
                                                <div class="info-label"><i class="fa-solid fa-sticky-note"></i> Ghi chú
                                                </div>
                                                <div class="info-value" style="font-size:14px;font-weight:400">
                                                    ${booking.note}</div>
                                            </div>
                                        </c:if>

                                        <!-- Pre-order Items -->
                                        <c:if test="${not empty booking.preOrderItems}">
                                            <div class="preorder-section">
                                                <h4><i class="fa-solid fa-utensils" style="color:var(--primary)"></i>
                                                    Món đã đặt trước</h4>
                                                <c:forEach var="item" items="${booking.preOrderItems}">
                                                    <div class="preorder-item">
                                                        <span class="item-name">${item.product.productName}</span>
                                                        <span class="item-qty">×${item.quantity}</span>
                                                        <span class="item-price">
                                                            <fmt:formatNumber
                                                                value="${item.product.price * item.quantity}"
                                                                pattern="#,###" />đ
                                                        </span>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Actions -->
                                    <div class="result-actions">
                                        <c:if test="${booking.status == 'CONFIRMED' || booking.status == 'PENDING'}">
                                            <a href="${pageContext.request.contextPath}/pre-order?code=${booking.bookingCode}"
                                                class="btn-action primary">
                                                <i class="fa-solid fa-utensils"></i> Đặt món trước
                                            </a>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/booking" class="btn-action">
                                            <i class="fa-solid fa-plus"></i> Đặt bàn mới
                                        </a>
                                    </div>
                                </div>
                            </c:when>

                            <%-- Search by phone: list of bookings --%>
                                <c:when test="${not empty bookings}">
                                    <div style="font-size:13px;color:var(--text-muted);margin-bottom:12px">
                                        Tìm thấy <strong style="color:var(--text)">${bookings.size()}</strong> booking
                                        với số điện thoại <strong style="color:var(--primary)">${phone}</strong>
                                    </div>
                                    <c:forEach var="b" items="${bookings}">
                                        <div class="result-card" style="margin-bottom:16px">
                                            <div class="result-header">
                                                <h3><i class="fa-solid fa-ticket" style="color:var(--primary)"></i>
                                                    ${b.bookingCode}</h3>
                                                <span
                                                    class="badge-status badge-${b.status.toLowerCase()}">${b.status}</span>
                                            </div>
                                            <div class="result-body">
                                                <div class="info-grid">
                                                    <div class="info-item">
                                                        <div class="info-label"><i class="fa-solid fa-user"></i> Khách
                                                            hàng</div>
                                                        <div class="info-value">${b.customerName}</div>
                                                    </div>
                                                    <div class="info-item">
                                                        <div class="info-label"><i class="fa-solid fa-calendar"></i>
                                                            Ngày</div>
                                                        <div class="info-value">${b.bookingDate}</div>
                                                    </div>
                                                    <div class="info-item">
                                                        <div class="info-label"><i class="fa-solid fa-clock"></i> Giờ
                                                        </div>
                                                        <div class="info-value">${b.bookingTime}</div>
                                                    </div>
                                                    <div class="info-item">
                                                        <div class="info-label"><i class="fa-solid fa-users"></i> Số
                                                            khách</div>
                                                        <div class="info-value">${b.partySize} người</div>
                                                    </div>
                                                </div>
                                                <c:if test="${b.status == 'CANCELLED' && not empty b.cancelReason}">
                                                    <div
                                                        style="font-size:13px;color:#f87171;padding:8px 12px;background:rgba(239,68,68,0.08);border:1px solid rgba(239,68,68,0.2);border-radius:8px;margin-bottom:12px">
                                                        <i class="fa-solid fa-circle-xmark"></i> <strong>Lý do
                                                            hủy:</strong> ${b.cancelReason}
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="result-actions">
                                                <a href="${pageContext.request.contextPath}/booking/status?code=${b.bookingCode}"
                                                    class="btn-action primary">
                                                    <i class="fa-solid fa-eye"></i> Xem chi tiết
                                                </a>
                                                <c:if test="${b.status == 'CONFIRMED' || b.status == 'PENDING'}">
                                                    <a href="${pageContext.request.contextPath}/pre-order?code=${b.bookingCode}"
                                                        class="btn-action">
                                                        <i class="fa-solid fa-utensils"></i> Đặt món trước
                                                    </a>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>

                                <%-- Not found --%>
                                    <c:when test="${searched && empty booking && empty bookings}">
                                        <div class="result-card">
                                            <div class="lookup-empty">
                                                <i class="fa-solid fa-magnifying-glass"></i>
                                                <h3>Không tìm thấy booking</h3>
                                                <p>Vui lòng kiểm tra lại mã đặt bàn hoặc số điện thoại.</p>
                                            </div>
                                        </div>
                                    </c:when>
                    </c:choose>

                </div>

                <!-- ── FOOTER ── -->
                <footer class="footer">
                    <div class="footer-grid">
                        <div class="footer-brand">
                            <div class="footer-logo">
                                <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                                <div class="footer-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                            </div>
                            <p class="footer-desc">Điểm hẹn của hương vị Việt Nam đích thực.</p>
                        </div>
                    </div>
                    <div class="footer-bottom">
                        <p>© 2026 Nhà hàng Hương Việt.</p>
                    </div>
                </footer>

                <script>
                    const navbar = document.getElementById('navbar');
                    window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 60));
                    document.getElementById('navBurger').addEventListener('click', function () {
                        const links = document.querySelector('.nav-links');
                        links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
                    });
                </script>
                <script
                    src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/intlTelInput.min.js"></script>
                <script>
                    const searchPhone = document.querySelector('#searchPhone');
                    if (searchPhone) {
                        const iti2 = window.intlTelInput(searchPhone, {
                            initialCountry: 'vn',
                            separateDialCode: true,
                            utilsScript: 'https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/utils.js',
                        });
                        const form2 = document.querySelector('.search-form');
                        form2.addEventListener('submit', function () {
                            const raw = searchPhone.value.trim();
                            // Keep local VN format (0xxx) as-is, server handles both
                            if (!raw.startsWith('+')) return;
                            searchPhone.value = iti2.getNumber();
                        });
                    }
                </script>

                <!-- chatbot widget include -->
                <jsp:include page="/chatbot.jsp" />
            </body>

            </html>