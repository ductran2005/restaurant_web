<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Thanh toán cọc — Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link
                    href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800;900&display=swap"
                    rel="stylesheet">
                <style>
                    *,
                    *::before,
                    *::after {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    :root {
                        --primary: #e8a020;
                        --primary-dk: #c07c0a;
                        --bg: #0f0e0c;
                        --bg-card: #1a1814;
                        --bg-lift: #232019;
                        --text: #f0ebe3;
                        --text-muted: #9e9488;
                        --border: rgba(255, 255, 255, .09);
                        --font: 'Be Vietnam Pro', sans-serif;
                    }

                    body {
                        font-family: var(--font);
                        background: var(--bg);
                        color: var(--text);
                        min-height: 100vh;
                    }

                    a {
                        text-decoration: none;
                        color: inherit;
                    }

                    /* ── NAV ── */
                    .nav {
                        background: rgba(15, 14, 12, .96);
                        border-bottom: 1px solid var(--border);
                        backdrop-filter: blur(14px);
                        position: sticky;
                        top: 0;
                        z-index: 100;
                        padding: 0 32px;
                        height: 60px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                    }

                    .nav-logo {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        font-weight: 800;
                        font-size: 15px;
                    }

                    .nav-logo small {
                        font-weight: 400;
                        font-size: 11px;
                        color: var(--text-muted);
                        display: block;
                    }

                    .nav-logo-icon {
                        width: 34px;
                        height: 34px;
                        background: var(--primary);
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #000;
                        font-size: 15px;
                    }

                    .nav-links {
                        display: flex;
                        gap: 24px;
                    }

                    .nav-links a {
                        font-size: 14px;
                        color: var(--text-muted);
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        font-weight: 500;
                        transition: color .2s;
                    }

                    .nav-links a:hover {
                        color: var(--primary);
                    }

                    .nav-links a.active {
                        background: var(--primary);
                        color: #000 !important;
                        padding: 7px 14px;
                        border-radius: 8px;
                        font-weight: 700;
                    }

                    /* ── PAGE ── */
                    .page {
                        max-width: 960px;
                        margin: 0 auto;
                        padding: 28px 24px 80px;
                    }

                    .back-link {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        font-size: 13px;
                        color: var(--text-muted);
                        font-weight: 500;
                        margin-bottom: 14px;
                        transition: color .2s;
                    }

                    .back-link:hover {
                        color: var(--primary);
                    }

                    .page-title {
                        font-size: 22px;
                        font-weight: 800;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        margin-bottom: 4px;
                    }

                    .page-title i {
                        color: var(--primary);
                    }

                    .page-sub {
                        font-size: 13px;
                        color: var(--text-muted);
                        margin-bottom: 20px;
                    }

                    /* ── BOOKING BANNER ── */
                    .booking-banner {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 12px;
                        padding: 14px 20px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin-bottom: 24px;
                    }

                    .bb-left {
                        display: flex;
                        align-items: center;
                        gap: 14px;
                    }

                    .bb-icon {
                        width: 36px;
                        height: 36px;
                        background: rgba(232, 160, 32, .1);
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--primary);
                        flex-shrink: 0;
                    }

                    .bb-code {
                        font-size: 15px;
                        font-weight: 700;
                        color: var(--primary);
                    }

                    .bb-name {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    .bb-meta {
                        font-size: 12px;
                        color: var(--text-muted);
                    }

                    .bb-badge {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 5px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 700;
                        background: rgba(34, 197, 94, .12);
                        border: 1px solid rgba(34, 197, 94, .2);
                        color: #4ade80;
                    }

                    /* ── GRID LAYOUT ── */
                    .grid {
                        display: grid;
                        grid-template-columns: 1fr 300px;
                        gap: 20px;
                        align-items: start;
                    }

                    @media (max-width: 760px) {
                        .grid {
                            grid-template-columns: 1fr;
                        }
                    }

                    /* ── CARD ── */
                    .card {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        overflow: hidden;
                        margin-bottom: 14px;
                    }

                    .card:last-child {
                        margin-bottom: 0;
                    }

                    .card-hd {
                        padding: 13px 18px;
                        border-bottom: 1px solid var(--border);
                        font-size: 13px;
                        font-weight: 700;
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .card-hd i {
                        color: var(--primary);
                        font-size: 13px;
                    }

                    /* ── ITEM ROWS ── */
                    .item-row {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        padding: 13px 18px;
                        border-bottom: 1px solid var(--border);
                    }

                    .item-thumb {
                        width: 44px;
                        height: 44px;
                        border-radius: 8px;
                        background: var(--bg-lift);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--text-muted);
                        font-size: 18px;
                        flex-shrink: 0;
                    }

                    .item-info {
                        flex: 1;
                        min-width: 0;
                    }

                    .item-name {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                        margin-bottom: 2px;
                    }

                    .item-unit {
                        font-size: 12px;
                        color: var(--text-muted);
                    }

                    .item-total {
                        font-size: 13px;
                        font-weight: 700;
                        color: var(--text);
                        white-space: nowrap;
                    }

                    /* ── TOTALS ── */
                    .totals {
                        padding: 14px 18px;
                    }

                    .total-row {
                        display: flex;
                        justify-content: space-between;
                        font-size: 13px;
                        margin-bottom: 7px;
                    }

                    .total-row .lbl {
                        color: var(--text-muted);
                    }

                    .total-row .val {
                        color: var(--text);
                        font-weight: 600;
                    }

                    .total-div {
                        border: none;
                        border-top: 1px solid var(--border);
                        margin: 10px 0;
                    }

                    .grand-row {
                        display: flex;
                        justify-content: space-between;
                        font-size: 15px;
                        font-weight: 800;
                        color: var(--text);
                    }

                    /* ── RIGHT COLUMN ── */
                    /* Deposit card */
                    .deposit-card {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        padding: 20px;
                        text-align: center;
                        margin-bottom: 14px;
                    }

                    .deposit-icon {
                        font-size: 1.8rem;
                        color: var(--primary);
                        margin-bottom: 8px;
                    }

                    .deposit-label {
                        font-size: 12px;
                        color: var(--text-muted);
                        margin-bottom: 6px;
                    }

                    .deposit-amount {
                        font-size: 28px;
                        font-weight: 900;
                        color: var(--primary);
                        margin-bottom: 4px;
                    }

                    .deposit-base {
                        font-size: 12px;
                        color: var(--text-muted);
                    }

                    /* Payment methods */
                    .method-wrap {
                        padding: 12px 14px;
                        display: flex;
                        flex-direction: column;
                        gap: 8px;
                    }

                    .method-opt {
                        display: none;
                    }

                    .method-label {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        padding: 11px 14px;
                        border: 1.5px solid var(--border);
                        border-radius: 10px;
                        cursor: pointer;
                        transition: all .15s;
                        background: var(--bg-lift);
                    }

                    .method-opt:checked+.method-label {
                        border-color: var(--primary);
                        background: rgba(232, 160, 32, .07);
                    }

                    .method-icon {
                        width: 34px;
                        height: 34px;
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        flex-shrink: 0;
                        font-size: 15px;
                    }

                    .method-icon.bank {
                        background: rgba(99, 102, 241, .12);
                        color: #a5b4fc;
                    }

                    .method-icon.momo {
                        background: rgba(209, 53, 145, .12);
                        color: #f0abdc;
                    }

                    .method-icon.zalo {
                        background: rgba(0, 120, 255, .12);
                        color: #60a5fa;
                    }

                    .m-name {
                        font-size: 13px;
                        font-weight: 700;
                        color: var(--text);
                    }

                    .m-sub {
                        font-size: 11px;
                        color: var(--text-muted);
                    }

                    .m-radio {
                        width: 18px;
                        height: 18px;
                        border-radius: 50%;
                        border: 2px solid var(--border);
                        flex-shrink: 0;
                        margin-left: auto;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all .15s;
                    }

                    .method-opt:checked+.method-label .m-radio {
                        border-color: var(--primary);
                        background: var(--primary);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, .2);
                    }

                    .method-opt:checked+.method-label .m-radio::after {
                        content: '';
                        width: 6px;
                        height: 6px;
                        border-radius: 50%;
                        background: #000;
                    }

                    /* Payment info panel */
                    .pay-info {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        margin-bottom: 14px;
                        overflow: hidden;
                        display: none;
                    }

                    .pay-info.active {
                        display: block;
                    }

                    .pay-info-hd {
                        padding: 12px 16px;
                        border-bottom: 1px solid var(--border);
                        font-size: 13px;
                        font-weight: 700;
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .pay-info-hd i {
                        color: var(--primary);
                        font-size: 12px;
                    }

                    .pay-info-body {
                        padding: 14px 16px;
                    }

                    .pi-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 8px;
                        font-size: 13px;
                    }

                    .pi-key {
                        color: var(--text-muted);
                    }

                    .pi-val {
                        color: var(--text);
                        font-weight: 600;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .pi-val.gold {
                        color: var(--primary);
                    }

                    .copy-btn {
                        background: none;
                        border: none;
                        color: var(--text-muted);
                        cursor: pointer;
                        font-size: 12px;
                        padding: 2px 4px;
                        border-radius: 4px;
                        transition: color .15s;
                    }

                    .copy-btn:hover {
                        color: var(--primary);
                    }

                    .qr-box {
                        margin-top: 12px;
                        border-radius: 10px;
                        background: #fff;
                        padding: 12px;
                        text-align: center;
                    }

                    .qr-box img {
                        width: 100%;
                        height: auto;
                        display: block;
                        border-radius: 6px;
                    }

                    .qr-lbl {
                        font-size: 11px;
                        color: var(--text-muted);
                        margin-top: 6px;
                        text-align: center;
                    }

                    /* Confirm button */
                    .btn-confirm {
                        width: 100%;
                        padding: 14px;
                        background: rgba(255, 255, 255, .06);
                        color: var(--text-muted);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        font-size: 14px;
                        font-weight: 700;
                        font-family: var(--font);
                        cursor: not-allowed;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                        transition: all .2s;
                        margin-bottom: 14px;
                    }

                    .btn-confirm.ready {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                        cursor: pointer;
                    }

                    .btn-confirm.ready:hover {
                        background: var(--primary-dk);
                    }

                    /* Notes */
                    .notes-box {
                        background: rgba(232, 160, 32, .07);
                        border: 1px solid rgba(232, 160, 32, .2);
                        border-radius: 10px;
                        padding: 12px 14px;
                        font-size: 12px;
                    }

                    .notes-hd {
                        font-weight: 700;
                        color: var(--primary);
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        margin-bottom: 8px;
                    }

                    .notes-box ul {
                        padding-left: 16px;
                    }

                    .notes-box ul li {
                        color: var(--text-muted);
                        margin-bottom: 4px;
                        line-height: 1.5;
                    }

                    /* Empty cart state */
                    .empty-msg {
                        padding: 28px;
                        text-align: center;
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    .empty-msg i {
                        font-size: 2rem;
                        display: block;
                        margin-bottom: 10px;
                        opacity: .2;
                    }

                    footer {
                        background: #000;
                        color: var(--text-muted);
                        text-align: center;
                        padding: 18px;
                        font-size: 13px;
                        border-top: 1px solid var(--border);
                    }

                    footer strong {
                        color: var(--primary);
                    }
                </style>
            </head>

            <body>

                <!-- NAV -->
                <nav class="nav">
                    <a href="${pageContext.request.contextPath}/" class="nav-logo">
                        <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div>Hương Việt<small>NHÀ HÀNG &amp; QUÁN NHẬU</small></div>
                    </a>
                    <div class="nav-links">
                        <a href="${pageContext.request.contextPath}/menu"><i class="fa-regular fa-book-open"></i> Thực
                            đơn</a>
                        <a href="${pageContext.request.contextPath}/booking"><i class="fa-regular fa-calendar"></i> Đặt
                            bàn</a>
                        <a href="${pageContext.request.contextPath}/booking/status"><i
                                class="fa-solid fa-magnifying-glass"></i> Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/pre-order" class="active">
                            <i class="fa-solid fa-cart-shopping"></i> Đặt món trước</a>
                    </div>
                    <a href="${pageContext.request.contextPath}/login"
                        style="font-size:13px;color:var(--text-muted);display:flex;align-items:center;gap:6px">
                        <i class="fa-solid fa-arrow-right-to-bracket"></i> Đăng nhập
                    </a>
                </nav>

                <div class="page">

                    <!-- Debug info (remove in production) -->
                    <c:if test="${param.debug == 'true'}">
                        <div style="background:#1a1814;border:1px solid #e8a020;padding:12px;margin-bottom:20px;font-size:12px;color:#f0ebe3">
                            <strong>Debug Info:</strong><br>
                            Booking: ${booking != null ? booking.bookingCode : 'NULL'}<br>
                            Items count: ${items != null ? items.size() : 'NULL'}<br>
                            Subtotal: ${subtotal}<br>
                            Deposit: ${deposit}<br>
                        </div>
                    </c:if>

                    <!-- Check if booking exists -->
                    <c:if test="${empty booking}">
                        <div style="background:#ef4444;color:#fff;padding:20px;border-radius:10px;text-align:center">
                            <i class="fa-solid fa-triangle-exclamation" style="font-size:2rem;margin-bottom:10px"></i>
                            <p>Không tìm thấy thông tin booking</p>
                            <a href="${pageContext.request.contextPath}/pre-order" style="color:#fff;text-decoration:underline">Quay lại</a>
                        </div>
                    </c:if>

                    <c:if test="${not empty booking}">

                    <!-- Back -->
                    <a href="${pageContext.request.contextPath}/pre-order?code=${booking.bookingCode}"
                        class="back-link">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại chọn món
                    </a>

                    <!-- Title -->
                    <div class="page-title"><i class="fa-solid fa-credit-card"></i> Thanh toán cọc</div>
                    <div class="page-sub">Yêu cầu thanh toán 10% giá trị món đặt trước để xác nhận pre-order</div>

                    <!-- Booking banner -->
                    <div class="booking-banner">
                        <div class="bb-left">
                            <div class="bb-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                            <div>
                                <div style="display:flex;align-items:center;gap:8px;margin-bottom:3px">
                                    <span class="bb-code">${booking.bookingCode}</span>
                                    <span style="color:var(--text-muted)">—</span>
                                    <span class="bb-name">${booking.customerName}</span>
                                </div>
                                <div class="bb-meta">
                                    ${booking.bookingDate} lúc ${booking.bookingTime}
                                    <c:if test="${not empty booking.partySize}"> &bull; ${booking.partySize} khách
                                    </c:if>
                                </div>
                            </div>
                        </div>
                        <div class="bb-badge"><i class="fa-solid fa-circle-check"></i> Đã xác nhận</div>
                    </div>

                    <!-- 2-col grid -->
                    <div class="grid">

                        <!-- ── LEFT: Order detail ── -->
                        <div>
                            <div class="card">
                                <div class="card-hd">
                                    <i class="fa-solid fa-receipt"></i>
                                    Chi tiết đơn đặt trước
                                    <c:if test="${not empty items}">(${items.size()} món)</c:if>
                                </div>

                                <c:choose>
                                    <c:when test="${empty items}">
                                        <div class="empty-msg">
                                            <i class="fa-solid fa-bowl-food"></i>
                                            Chưa có món nào trong đơn
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="poi" items="${items}">
                                            <c:if test="${not empty poi.product}">
                                                <div class="item-row">
                                                    <div class="item-thumb"><i class="fa-solid fa-bowl-food"></i></div>
                                                    <div class="item-info">
                                                        <div class="item-name">${poi.product.productName}</div>
                                                        <div class="item-unit">
                                                            <fmt:formatNumber value="${poi.product.price}"
                                                                pattern="#,###" /> đ
                                                            &times; ${poi.quantity}
                                                        </div>
                                                    </div>
                                                    <div class="item-total">
                                                        <fmt:formatNumber value="${poi.product.price * poi.quantity}"
                                                            pattern="#,###" /> đ
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>

                                <div class="totals">
                                    <div class="total-row">
                                        <span class="lbl">Tạm tính:</span>
                                        <span class="val">
                                            <fmt:formatNumber value="${subtotal}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <div class="total-row">
                                        <span class="lbl">VAT (10%):</span>
                                        <span class="val">
                                            <fmt:formatNumber value="${vat}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <div class="total-row">
                                        <span class="lbl">Phí dịch vụ (5%):</span>
                                        <span class="val">
                                            <fmt:formatNumber value="${serviceFee}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <hr class="total-div">
                                    <div class="grand-row">
                                        <span>Tổng dự kiến:</span>
                                        <span>
                                            <fmt:formatNumber value="${grandTotal}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- ── RIGHT: Payment ── -->
                        <div>

                            <!-- Deposit amount -->
                            <div class="deposit-card">
                                <div class="deposit-icon"><i class="fa-solid fa-circle-dollar-to-slot"></i></div>
                                <div class="deposit-label">Số tiền cọc (10%)</div>
                                <div class="deposit-amount">
                                    <fmt:formatNumber value="${deposit}" pattern="#,###" /> đ
                                </div>
                                <div class="deposit-base">trên tổng
                                    <fmt:formatNumber value="${subtotal}" pattern="#,###" /> đ
                                </div>
                            </div>

                            <!-- Payment methods -->
                            <div class="card">
                                <div class="card-hd"><i class="fa-solid fa-money-bill-wave"></i> Phương thức thanh toán
                                </div>
                                <form id="payForm" method="post"
                                    action="${pageContext.request.contextPath}/pre-order/checkout">
                                    <input type="hidden" name="bookingCode" value="${booking.bookingCode}">
                                    <input type="hidden" name="amount" value="${deposit}">
                                    <div class="method-wrap">
                                        <!-- Bank transfer -->
                                        <input type="radio" id="m_bank" name="method" value="BANK_TRANSFER"
                                            class="method-opt" onchange="onMethod()" checked>
                                        <label for="m_bank" class="method-label">
                                            <div class="method-icon bank"><i class="fa-solid fa-building-columns"></i>
                                            </div>
                                            <div>
                                                <div class="m-name">Chuyển khoản ngân hàng</div>
                                                <div class="m-sub">Vietcombank - 12345...</div>
                                            </div>
                                            <div class="m-radio"></div>
                                        </label>

                                        <!-- MoMo -->
                                        <input type="radio" id="m_momo" name="method" value="MOMO" class="method-opt"
                                            onchange="onMethod()">
                                        <label for="m_momo" class="method-label">
                                            <div class="method-icon momo"><i class="fa-solid fa-mobile-screen"></i>
                                            </div>
                                            <div>
                                                <div class="m-name">Ví MoMo</div>
                                                <div class="m-sub">SDT MoMo: 0901234...</div>
                                            </div>
                                            <div class="m-radio"></div>
                                        </label>

                                        <!-- ZaloPay -->
                                        <input type="radio" id="m_zalo" name="method" value="ZALO_PAY"
                                            class="method-opt" onchange="onMethod()">
                                        <label for="m_zalo" class="method-label">
                                            <div class="method-icon zalo"><i class="fa-brands fa-z"></i></div>
                                            <div>
                                                <div class="m-name">ZaloPay</div>
                                                <div class="m-sub">SDT ZaloPay: 0901234...</div>
                                            </div>
                                            <div class="m-radio"></div>
                                        </label>
                                    </div>
                                </form>
                            </div>

                            <!-- Bank info -->
                            <div class="pay-info" id="info_BANK_TRANSFER">
                                <div class="pay-info-hd"><i class="fa-solid fa-building-columns"></i> Thông tin chuyển
                                    khoản</div>
                                <div class="pay-info-body">
                                    <div class="pi-row">
                                        <span class="pi-key">Ngân hàng</span>
                                        <span class="pi-val">Vietcombank</span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Số tài khoản</span>
                                        <span class="pi-val gold">1234567890
                                            <button class="copy-btn" onclick="cp('1234567890')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Nội dung</span>
                                        <span class="pi-val gold">${booking.bookingCode} COC
                                            <button class="copy-btn" onclick="cp('${booking.bookingCode} COC')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Số tiền</span>
                                        <span class="pi-val gold">
                                            <fmt:formatNumber value="${deposit}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <div class="qr-box">
                                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=Vietcombank+1234567890+${booking.bookingCode}+COC"
                                            alt="QR">
                                    </div>
                                    <div class="qr-lbl">QR Chuyển khoản</div>
                                </div>
                            </div>

                            <!-- MoMo info -->
                            <div class="pay-info" id="info_MOMO">
                                <div class="pay-info-hd"><i class="fa-solid fa-mobile-screen"></i> Thông tin MoMo</div>
                                <div class="pay-info-body">
                                    <div class="pi-row">
                                        <span class="pi-key">SDT MoMo</span>
                                        <span class="pi-val gold">0901234567
                                            <button class="copy-btn" onclick="cp('0901234567')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Nội dung</span>
                                        <span class="pi-val gold">${booking.bookingCode} COC
                                            <button class="copy-btn" onclick="cp('${booking.bookingCode} COC')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Số tiền</span>
                                        <span class="pi-val gold">
                                            <fmt:formatNumber value="${deposit}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <div class="qr-box">
                                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=MoMo+0901234567+${booking.bookingCode}+COC"
                                            alt="QR MoMo">
                                    </div>
                                    <div class="qr-lbl">QR MoMo</div>
                                </div>
                            </div>

                            <!-- ZaloPay info -->
                            <div class="pay-info" id="info_ZALO_PAY">
                                <div class="pay-info-hd"><i class="fa-brands fa-z"></i> Thông tin ZaloPay</div>
                                <div class="pay-info-body">
                                    <div class="pi-row">
                                        <span class="pi-key">SDT ZaloPay</span>
                                        <span class="pi-val gold">0901234567
                                            <button class="copy-btn" onclick="cp('0901234567')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Nội dung</span>
                                        <span class="pi-val gold">${booking.bookingCode} COC
                                            <button class="copy-btn" onclick="cp('${booking.bookingCode} COC')"><i
                                                    class="fa-solid fa-copy"></i></button>
                                        </span>
                                    </div>
                                    <div class="pi-row">
                                        <span class="pi-key">Số tiền</span>
                                        <span class="pi-val gold">
                                            <fmt:formatNumber value="${deposit}" pattern="#,###" /> đ
                                        </span>
                                    </div>
                                    <div class="qr-box">
                                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=ZaloPay+0901234567+${booking.bookingCode}+COC"
                                            alt="QR ZaloPay">
                                    </div>
                                    <div class="qr-lbl">QR ZaloPay</div>
                                </div>
                            </div>

                            <!-- Confirm button -->
                            <button type="submit" form="payForm" class="btn-confirm ready" id="confirmBtn">
                                <i class="fa-solid fa-circle-check"></i>
                                Xác nhận đã thanh toán
                                <fmt:formatNumber value="${deposit}" pattern="#,###" /> đ
                            </button>

                            <!-- Notes -->
                            <div class="notes-box">
                                <div class="notes-hd"><i class="fa-solid fa-triangle-exclamation"></i> Lưu ý:</div>
                                <ul>
                                    <li>Tiền cọc sẽ được trừ vào hóa đơn cuối</li>
                                    <li>Hoàn trả 100% nếu hủy trước 60 phút</li>
                                    <li>Không hoàn cọc nếu khách NO SHOW</li>
                                </ul>
                            </div>

                        </div><!-- end RIGHT -->
                    </div><!-- end grid -->
                    
                    </c:if><!-- end booking check -->
                    
                </div><!-- end page -->

                <footer>
                    Nhà hàng Hương Việt &nbsp;·&nbsp; 123 Nguyễn Huệ, Q.1, TP.HCM &nbsp;·&nbsp;
                    Hotline: <strong>1900 1234</strong>
                </footer>

                <script>
                    function onMethod() {
                        const sel = document.querySelector('input[name="method"]:checked');
                        document.querySelectorAll('.pay-info').forEach(el => el.classList.remove('active'));
                        const btn = document.getElementById('confirmBtn');
                        if (!sel) { btn.disabled = true; btn.classList.remove('ready'); return; }
                        btn.disabled = false; btn.classList.add('ready');
                        const box = document.getElementById('info_' + sel.value);
                        if (box) box.classList.add('active');
                    }

                    function cp(txt) {
                        navigator.clipboard.writeText(txt).then(() => {
                            const el = event.currentTarget;
                            const orig = el.innerHTML;
                            el.innerHTML = '<i class="fa-solid fa-check" style="color:#4ade80"></i>';
                            setTimeout(() => el.innerHTML = orig, 1500);
                        });
                    }

                    // Show bank info on page load (default selected)
                    window.addEventListener('DOMContentLoaded', function () { onMethod(); });
                </script>
            </body>

            </html>