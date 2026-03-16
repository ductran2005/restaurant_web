<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Đặt món trước — Nhà hàng Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
                <style>
                    .preorder-hero {
                        padding: 140px 48px 40px;
                        text-align: center;
                        position: relative;
                    }

                    .preorder-hero::before {
                        content: '';
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, .08) 0%, transparent 60%);
                        pointer-events: none;
                    }

                    .preorder-hero h1 {
                        font-family: var(--font-serif);
                        font-size: clamp(28px, 4vw, 44px);
                        color: var(--text);
                        margin-bottom: 10px;
                    }

                    .preorder-hero h1 em {
                        color: var(--primary);
                        font-style: italic;
                    }

                    .preorder-hero p {
                        font-size: 15px;
                        color: var(--text-muted);
                        max-width: 480px;
                        margin: 0 auto;
                    }

                    .preorder-section {
                        max-width: 1000px;
                        margin: 0 auto;
                        padding: 0 24px 80px;
                    }

                    /* Lookup Card */
                    .lookup-card {
                        background: rgba(26, 24, 20, .8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 28px;
                        backdrop-filter: blur(12px);
                        margin-bottom: 24px;
                    }

                    .lookup-form {
                        display: flex;
                        gap: 12px;
                        flex-wrap: wrap;
                    }

                    .lookup-form .form-control {
                        flex: 1;
                        min-width: 200px;
                        background: rgba(255, 255, 255, .05);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 12px 14px;
                        color: var(--text);
                        font-size: 14px;
                        font-family: inherit;
                        outline: none;
                    }

                    .lookup-form .form-control::placeholder {
                        color: var(--text-muted);
                    }

                    .lookup-form .form-control:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, .1);
                    }

                    .btn-lookup {
                        padding: 12px 24px;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 10px;
                        font-weight: 700;
                        font-size: 14px;
                        font-family: inherit;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .btn-lookup:hover {
                        background: #cfa730;
                    }

                    /* Booking Info Bar */
                    .booking-bar {
                        background: rgba(232, 160, 32, .06);
                        border: 1px solid rgba(232, 160, 32, .15);
                        border-radius: 12px;
                        padding: 16px 20px;
                        margin-bottom: 24px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        flex-wrap: wrap;
                        gap: 12px;
                    }

                    .booking-bar-info {
                        display: flex;
                        align-items: center;
                        gap: 16px;
                        flex-wrap: wrap;
                    }

                    .booking-bar-info .info-chip {
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        font-size: 13px;
                        color: var(--text-muted);
                    }

                    .booking-bar-info .info-chip i {
                        color: var(--primary);
                    }

                    .booking-bar-info .info-chip strong {
                        color: var(--text);
                    }

                    .cutoff-timer {
                        background: rgba(239, 68, 68, .1);
                        border: 1px solid rgba(239, 68, 68, .2);
                        color: #f87171;
                        padding: 8px 14px;
                        border-radius: 8px;
                        font-size: 13px;
                        font-weight: 600;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .cutoff-timer.ok {
                        background: rgba(34, 197, 94, .1);
                        border-color: rgba(34, 197, 94, .2);
                        color: #4ade80;
                    }

                    /* Two-panel layout */
                    .preorder-grid {
                        display: grid;
                        grid-template-columns: 1fr 380px;
                        gap: 24px;
                    }

                    @media(max-width:860px) {
                        .preorder-grid {
                            grid-template-columns: 1fr;
                        }
                    }

                    /* Menu Panel */
                    .menu-panel {
                        background: rgba(26, 24, 20, .8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        overflow: hidden;
                        backdrop-filter: blur(12px);
                    }

                    .menu-panel-header {
                        padding: 16px 20px;
                        border-bottom: 1px solid var(--border);
                    }

                    .menu-panel-header h3 {
                        font-size: 15px;
                        color: var(--text);
                        margin-bottom: 12px;
                    }

                    .menu-search {
                        width: 100%;
                        background: rgba(255, 255, 255, .05);
                        border: 1px solid var(--border);
                        border-radius: 8px;
                        padding: 10px 12px 10px 36px;
                        color: var(--text);
                        font-size: 13px;
                        font-family: inherit;
                        outline: none;
                    }

                    .menu-search:focus {
                        border-color: var(--primary);
                    }

                    .search-wrap {
                        position: relative;
                    }

                    .search-wrap i {
                        position: absolute;
                        left: 12px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    /* Category Tabs */
                    .cat-tabs {
                        display: flex;
                        gap: 8px;
                        padding: 12px 20px;
                        border-bottom: 1px solid var(--border);
                        overflow-x: auto;
                    }

                    .cat-tab {
                        padding: 6px 14px;
                        border-radius: 99px;
                        font-size: 12px;
                        font-weight: 600;
                        border: 1px solid var(--border);
                        background: none;
                        color: var(--text-muted);
                        cursor: pointer;
                        white-space: nowrap;
                        font-family: inherit;
                        transition: all .2s;
                    }

                    .cat-tab:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .cat-tab.active {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    /* Menu Items */
                    .menu-list {
                        max-height: 500px;
                        overflow-y: auto;
                    }

                    .menu-item {
                        display: flex;
                        align-items: center;
                        gap: 14px;
                        padding: 12px 20px;
                        border-bottom: 1px solid var(--border);
                        cursor: pointer;
                        transition: background .15s;
                    }

                    .menu-item:hover {
                        background: rgba(255, 255, 255, .03);
                    }

                    .menu-item:last-child {
                        border-bottom: none;
                    }

                    .menu-item-info {
                        flex: 1;
                        min-width: 0;
                    }

                    .menu-item-name {
                        font-size: 14px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    .menu-item-cat {
                        font-size: 11px;
                        color: var(--text-muted);
                        margin-top: 2px;
                    }

                    .menu-item-price {
                        font-size: 14px;
                        font-weight: 700;
                        color: var(--primary);
                        white-space: nowrap;
                    }

                    .menu-item-soldout {
                        opacity: .5;
                        pointer-events: none;
                    }

                    .menu-item-soldout .menu-item-name::after {
                        content: ' (Hết)';
                        color: #ef4444;
                        font-weight: 400;
                        font-size: 12px;
                    }

                    .btn-add-item {
                        width: 32px;
                        height: 32px;
                        border-radius: 8px;
                        background: rgba(232, 160, 32, .1);
                        border: 1px solid rgba(232, 160, 32, .2);
                        color: var(--primary);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        flex-shrink: 0;
                        font-size: 14px;
                        transition: all .2s;
                    }

                    .btn-add-item:hover {
                        background: var(--primary);
                        color: #000;
                    }

                    /* Cart Panel */
                    .cart-panel {
                        background: rgba(26, 24, 20, .8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        backdrop-filter: blur(12px);
                        display: flex;
                        flex-direction: column;
                        position: sticky;
                        top: 100px;
                    }

                    .cart-header {
                        padding: 16px 20px;
                        border-bottom: 1px solid var(--border);
                    }

                    .cart-header h3 {
                        font-size: 15px;
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .cart-header h3 .cart-count {
                        background: var(--primary);
                        color: #000;
                        font-size: 11px;
                        font-weight: 700;
                        padding: 2px 8px;
                        border-radius: 99px;
                    }

                    .cart-body {
                        flex: 1;
                        overflow-y: auto;
                        max-height: 340px;
                    }

                    .cart-empty {
                        text-align: center;
                        padding: 40px 20px;
                        color: var(--text-muted);
                    }

                    .cart-empty i {
                        font-size: 2rem;
                        opacity: .3;
                        margin-bottom: 12px;
                        display: block;
                    }

                    .cart-item {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 12px 20px;
                        border-bottom: 1px solid var(--border);
                    }

                    .cart-item:last-child {
                        border-bottom: none;
                    }

                    .cart-item-info {
                        flex: 1;
                        min-width: 0;
                    }

                    .cart-item-name {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    .cart-item-price {
                        font-size: 12px;
                        color: var(--text-muted);
                    }

                    .qty-controls {
                        display: flex;
                        align-items: center;
                        gap: 4px;
                    }

                    .qty-btn {
                        width: 28px;
                        height: 28px;
                        border-radius: 6px;
                        border: 1px solid var(--border);
                        background: none;
                        color: var(--text);
                        font-size: 14px;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .qty-btn:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .qty-val {
                        width: 28px;
                        text-align: center;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    .btn-remove {
                        color: #ef4444;
                        background: none;
                        border: none;
                        cursor: pointer;
                        font-size: 14px;
                        padding: 4px;
                    }

                    .btn-remove:hover {
                        color: #dc2626;
                    }

                    /* Cart Footer */
                    .cart-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--border);
                    }

                    .cart-total-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 12px;
                    }

                    .cart-total-label {
                        font-size: 14px;
                        color: var(--text-muted);
                    }

                    .cart-total-value {
                        font-size: 20px;
                        font-weight: 800;
                        color: var(--primary);
                    }

                    .btn-confirm-preorder {
                        width: 100%;
                        padding: 14px;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 12px;
                        font-size: 15px;
                        font-weight: 700;
                        cursor: pointer;
                        font-family: inherit;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                        transition: all .25s;
                    }

                    .btn-confirm-preorder:hover {
                        background: #cfa730;
                    }

                    .btn-confirm-preorder:disabled {
                        opacity: .5;
                        cursor: not-allowed;
                    }

                    /* Note area */
                    .cart-note {
                        margin-top: 12px;
                    }

                    .cart-note textarea {
                        width: 100%;
                        background: rgba(255, 255, 255, .05);
                        border: 1px solid var(--border);
                        border-radius: 8px;
                        color: var(--text);
                        padding: 10px;
                        font-size: 13px;
                        font-family: inherit;
                        resize: vertical;
                        min-height: 60px;
                        outline: none;
                    }

                    .cart-note textarea:focus {
                        border-color: var(--primary);
                    }

                    .alert-error {
                        background: rgba(239, 68, 68, .08);
                        border: 1px solid rgba(239, 68, 68, .2);
                        color: #f87171;
                        padding: 12px 16px;
                        border-radius: 10px;
                        font-size: 13px;
                        margin-bottom: 20px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .alert-success {
                        background: rgba(34, 197, 94, .08);
                        border: 1px solid rgba(34, 197, 94, .2);
                        color: #4ade80;
                        padding: 12px 16px;
                        border-radius: 10px;
                        font-size: 13px;
                        margin-bottom: 20px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    @media(max-width:640px) {
                        .preorder-hero {
                            padding: 120px 20px 32px;
                        }

                        .preorder-section {
                            padding: 0 16px 60px;
                        }

                        .lookup-form {
                            flex-direction: column;
                        }

                        .btn-lookup {
                            width: 100%;
                            justify-content: center;
                        }
                    }
                </style>
            </head>

            <body>

                <!-- NAVBAR -->
                <nav class="navbar" id="navbar">
                    <a href="${pageContext.request.contextPath}/" class="nav-logo">
                        <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                    </a>
                    <div class="nav-links">
                        <a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a>
                        <a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a>
                        <a href="${pageContext.request.contextPath}/user/booking/status">Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/user/pre-order" class="active">Đặt món trước</a>
                        <a href="${pageContext.request.contextPath}/about">Về chúng tôi</a>
                        <a href="${pageContext.request.contextPath}/contact">Liên hệ</a>
                    </div>
                    <div class="nav-actions">
                        <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
                    </div>
                    <div class="nav-burger" id="navBurger"><span></span><span></span><span></span></div>
                </nav>

                <!-- HERO -->
                <section class="preorder-hero">
                    <div class="section-label"><i class="fa-solid fa-utensils"></i> Đặt món trước</div>
                    <h1>Chuẩn bị <em>bữa tiệc</em> hoàn hảo</h1>
                    <p>Đặt món trước khi đến nhà hàng. Món ăn sẽ được chuẩn bị sẵn sàng khi bạn tới.</p>
                </section>

                <!-- CONTENT -->
                <div class="preorder-section">

                    <c:if test="${not empty successMsg}">
                        <div class="alert-success"><i class="fa-solid fa-circle-check"></i> ${successMsg}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}</div>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty booking}">
                            <!-- LOOKUP STEP -->
                            <div class="lookup-card">
                                <h3
                                    style="font-size:16px;color:var(--text);margin-bottom:16px;display:flex;align-items:center;gap:8px">
                                    <i class="fa-solid fa-ticket" style="color:var(--primary)"></i> Nhập mã đặt bàn
                                </h3>
                                <form method="get" action="${pageContext.request.contextPath}/user/pre-order"
                                    class="lookup-form">
                                    <input type="text" name="code" class="form-control"
                                        placeholder="Mã đặt bàn (VD: BK-2026-001)" value="${param.code}" required>
                                    <button type="submit" class="btn-lookup"><i class="fa-solid fa-search"></i> Tìm
                                        booking</button>
                                </form>
                                <p style="font-size:13px;color:var(--text-muted);margin-top:12px">
                                    <i class="fa-solid fa-info-circle"></i> Bạn cần có mã đặt bàn để đặt món trước.
                                    <a href="${pageContext.request.contextPath}/user/booking/create"
                                        style="color:var(--primary)">Đặt bàn ngay →</a>
                                </p>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <!-- BOOKING INFO BAR -->
                            <div class="booking-bar">
                                <div class="booking-bar-info">
                                    <div class="info-chip"><i class="fa-solid fa-ticket"></i>
                                        <strong>${booking.bookingCode}</strong>
                                    </div>
                                    <div class="info-chip"><i class="fa-solid fa-user"></i> ${booking.customerName}
                                    </div>
                                    <div class="info-chip"><i class="fa-solid fa-calendar"></i> ${booking.bookingDate}
                                    </div>
                                    <div class="info-chip"><i class="fa-solid fa-clock"></i> ${booking.bookingTime}
                                    </div>
                                    <div class="info-chip"><i class="fa-solid fa-users"></i> ${booking.partySize} khách
                                    </div>
                                </div>
                                <c:if test="${not empty cutoffDisplay}">
                                    <div class="cutoff-timer ${cutoffOk ? 'ok' : ''}">
                                        <i class="fa-solid fa-hourglass-half"></i> Hạn sửa: ${cutoffDisplay}
                                    </div>
                                </c:if>
                            </div>

                            <!-- TWO-PANEL -->
                            <div class="preorder-grid">
                                <!-- LEFT: Menu -->
                                <div class="menu-panel">
                                    <div class="menu-panel-header">
                                        <h3><i class="fa-solid fa-bowl-food" style="color:var(--primary)"></i> Chọn món
                                        </h3>
                                        <div class="search-wrap">
                                            <i class="fa-solid fa-magnifying-glass"></i>
                                            <input type="text" class="menu-search" placeholder="Tìm món..."
                                                id="menuSearch" onkeyup="filterMenu()">
                                        </div>
                                    </div>
                                    <div class="cat-tabs" id="catTabs">
                                        <button class="cat-tab active" onclick="filterCat(this, '')" type="button">Tất
                                            cả</button>
                                        <c:forEach var="cat" items="${categories}">
                                            <button class="cat-tab" onclick="filterCat(this, '${cat.categoryName}')"
                                                type="button">${cat.categoryName}</button>
                                        </c:forEach>
                                    </div>
                                    <div class="menu-list" id="menuList">
                                        <c:forEach var="item" items="${menuItems}">
                                            <div class="menu-item ${item.status != 'AVAILABLE' ? 'menu-item-soldout' : ''}"
                                                data-name="${item.productName}" data-cat="${item.category.categoryName}"
                                                data-id="${item.id}" data-price="${item.price}">
                                                <div class="menu-item-info">
                                                    <div class="menu-item-name">${item.productName}</div>
                                                    <div class="menu-item-cat">${item.category.categoryName}</div>
                                                </div>
                                                <div class="menu-item-price">
                                                    <fmt:formatNumber value="${item.price}" pattern="#,###" />đ
                                                </div>
                                                <c:if test="${item.status == 'AVAILABLE'}">
                                                    <button type="button" class="btn-add-item" title="Thêm"
                                                        onclick="addToCart('${item.id}', '${item.productName}', ${item.price}, '${item.category.categoryName}')">
                                                        <i class="fa-solid fa-plus"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${empty menuItems}">
                                            <div class="cart-empty"><i class="fa-solid fa-bowl-food"></i>Chưa có món nào
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- RIGHT: Cart -->
                                <div class="cart-panel">
                                    <div class="cart-header">
                                        <h3><i class="fa-solid fa-cart-shopping" style="color:var(--primary)"></i> Món
                                            đã chọn
                                            <span class="cart-count" id="cartCount" style="display:none">0</span>
                                        </h3>
                                    </div>
                                    <div class="cart-body" id="cartBody">
                                        <div class="cart-empty" id="cartEmpty">
                                            <i class="fa-solid fa-cart-shopping"></i>
                                            Chưa có món nào.<br>Chọn món từ danh sách bên trái.
                                        </div>
                                    </div>
                                    <div class="cart-footer">
                                        <div class="cart-total-row">
                                            <span class="cart-total-label">Tạm tính</span>
                                            <span class="cart-total-value" id="cartTotal">0đ</span>
                                        </div>
                                        <div class="cart-note">
                                            <textarea id="preorderNote"
                                                placeholder="Ghi chú (dị ứng, yêu cầu đặc biệt...)"></textarea>
                                        </div>
                                        <button type="button" class="btn-confirm-preorder" id="btnConfirm" disabled
                                            onclick="confirmPreOrder()">
                                            <i class="fa-solid fa-check"></i> Xác nhận đặt món
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- FOOTER -->
                <footer class="footer" id="footer">
                    <div class="footer-grid">
                        <div class="footer-brand">
                            <div class="footer-logo">
                                <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                                <div class="footer-logo-text">Hương Việt<span>Nhà hàng &amp; Quán nhậu</span></div>
                            </div>
                            <p class="footer-desc">Không chỉ là nhà hàng, Hương Việt còn là phong cách sống — điểm hẹn của những khoảnh khắc đáng nhớ.</p>
                            <div class="socials">
                                <a href="#" class="social"><i class="fa-brands fa-facebook-f"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-instagram"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-tiktok"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-youtube"></i></a>
                            </div>
                        </div>
                        <div class="footer-col">
                            <h4>Khám phá</h4>
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a></li>
                                <li><a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a></li>
                                <li><a href="${pageContext.request.contextPath}/user/booking/status">Tra cứu booking</a></li>
                                <li><a href="${pageContext.request.contextPath}/user/pre-order">Đặt món trước</a></li>
                            </ul>
                        </div>
                        <div class="footer-col">
                            <h4>Về chúng tôi</h4>
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/about">Giới thiệu</a></li>
                                <li><a href="${pageContext.request.contextPath}/contact">Liên hệ</a></li>
                            </ul>
                        </div>
                        <div class="footer-col">
                            <h4>Liên hệ</h4>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-solid fa-location-dot"></i></div>
                                <div class="footer-contact-text"><strong>Địa chỉ</strong>123 Nguyễn Huệ, Quận 1, TP.HCM</div>
                            </div>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-solid fa-phone"></i></div>
                                <div class="footer-contact-text"><strong>Hotline</strong>1900 1234 (8:00 – 23:00)</div>
                            </div>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-regular fa-clock"></i></div>
                                <div class="footer-contact-text"><strong>Giờ mở cửa</strong>10:00 – 23:00 hàng ngày</div>
                            </div>
                        </div>
                    </div>
                    <div class="footer-bottom">
                        <p>© 2026 Nhà hàng Hương Việt.</p>
                        <p>Thiết kế bởi <a href="#">Đội ngũ Hương Việt Tech</a></p>
                    </div>
                </footer>

                <script>
                    const navbar = document.getElementById('navbar');
                    window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 60));
                    document.getElementById('navBurger')?.addEventListener('click', function () {
                        const l = document.querySelector('.nav-links');
                        l.style.display = l.style.display === 'flex' ? 'none' : 'flex';
                    });

                    function filterMenu() {
                        const q = document.getElementById('menuSearch').value.toLowerCase();
                        document.querySelectorAll('.menu-item').forEach(el => {
                            const name = el.dataset.name.toLowerCase();
                            el.style.display = name.includes(q) ? '' : 'none';
                        });
                    }
                    function filterCat(btn, cat) {
                        document.querySelectorAll('.cat-tab').forEach(t => t.classList.remove('active'));
                        btn.classList.add('active');
                        document.querySelectorAll('.menu-item').forEach(el => {
                            el.style.display = (!cat || el.dataset.cat === cat) ? '' : 'none';
                        });
                    }

                    /* ========== CART ========== */
                    const cart = []; // { id, name, price, category, qty }

                    function addToCart(id, name, price, category) {
                        const existing = cart.find(i => i.id === id);
                        if (existing) {
                            existing.qty++;
                        } else {
                            cart.push({ id, name, price: Number(price), category, qty: 1 });
                        }
                        renderCart();
                        // Brief highlight effect on added item
                        const row = document.querySelector('.cart-item[data-cart-id="' + id + '"]');
                        if (row) {
                            row.style.background = 'rgba(232,160,32,.12)';
                            setTimeout(() => row.style.background = '', 400);
                        }
                    }

                    function changeQty(id, delta) {
                        const item = cart.find(i => i.id === id);
                        if (!item) return;
                        item.qty += delta;
                        if (item.qty <= 0) {
                            cart.splice(cart.indexOf(item), 1);
                        }
                        renderCart();
                    }

                    function removeFromCart(id) {
                        const idx = cart.findIndex(i => i.id === id);
                        if (idx !== -1) cart.splice(idx, 1);
                        renderCart();
                    }

                    function formatVND(n) {
                        return n.toLocaleString('vi-VN') + 'đ';
                    }

                    function renderCart() {
                        const body = document.getElementById('cartBody');
                        const countEl = document.getElementById('cartCount');
                        const totalEl = document.getElementById('cartTotal');
                        const btnConfirm = document.getElementById('btnConfirm');
                        const emptyEl = document.getElementById('cartEmpty');

                        if (cart.length === 0) {
                            // Show empty state
                            body.innerHTML = '';
                            body.appendChild(emptyEl);
                            emptyEl.style.display = '';
                            countEl.style.display = 'none';
                            totalEl.textContent = '0đ';
                            btnConfirm.disabled = true;
                            return;
                        }

                        countEl.textContent = cart.length;
                        countEl.style.display = '';
                        btnConfirm.disabled = false;

                        let total = 0;
                        let html = '';
                        cart.forEach(item => {
                            const sub = item.price * item.qty;
                            total += sub;
                            html += '<div class="cart-item" data-cart-id="' + item.id + '">'
                                + '  <div class="cart-item-info">'
                                + '    <div class="cart-item-name">' + item.name + '</div>'
                                + '    <div class="cart-item-price">' + formatVND(item.price) + '</div>'
                                + '  </div>'
                                + '  <div class="qty-controls">'
                                + '    <button type="button" class="qty-btn" onclick="changeQty(\'' + item.id + '\', -1)">\u2212</button>'
                                + '    <span class="qty-val">' + item.qty + '</span>'
                                + '    <button type="button" class="qty-btn" onclick="changeQty(\'' + item.id + '\', 1)">+</button>'
                                + '  </div>'
                                + '  <button type="button" class="btn-remove" title="Xóa" onclick="removeFromCart(\'' + item.id + '\')">'
                                + '    <i class="fa-solid fa-trash"></i>'
                                + '  </button>'
                                + '</div>';
                        });
                        body.innerHTML = html;
                        totalEl.textContent = formatVND(total);
                    }

                    function confirmPreOrder() {
                        if (cart.length === 0) return;
                        const bookingCode = '${booking != null ? booking.bookingCode : ""}';
                        const note = document.getElementById('preorderNote').value;

                        // Build a hidden form and submit
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = '${pageContext.request.contextPath}/user/pre-order';
                        form.style.display = 'none';

                        function addField(name, value) {
                            const inp = document.createElement('input');
                            inp.type = 'hidden';
                            inp.name = name;
                            inp.value = value;
                            form.appendChild(inp);
                        }

                        addField('action', 'confirm');
                        addField('bookingCode', bookingCode);
                        addField('note', note);
                        addField('itemCount', cart.length);

                        cart.forEach((item, i) => {
                            addField('productId_' + i, item.id);
                            addField('quantity_' + i, item.qty);
                        });

                        document.body.appendChild(form);
                        form.submit();
                    }
                </script>

                <!-- chatbot widget include -->
                <jsp:include page="/chatbot.jsp" />

            </body>

            </html>