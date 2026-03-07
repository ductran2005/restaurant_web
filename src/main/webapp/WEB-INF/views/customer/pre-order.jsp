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
                        --bg-lift: #211f1b;
                        --text: #f0ebe3;
                        --text-muted: #9e9488;
                        --border: rgba(255, 255, 255, .08);
                        --font: 'Be Vietnam Pro', sans-serif;
                    }

                    body {
                        font-family: var(--font);
                        background: var(--bg);
                        color: var(--text);
                        min-height: 100vh;
                        line-height: 1.6;
                    }

                    a {
                        text-decoration: none;
                        color: inherit;
                    }

                    /* ─── NAVBAR ─────────────────────────────────── */
                    .po-nav {
                        background: rgba(15, 14, 12, .95);
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

                    .po-nav-logo {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        font-weight: 800;
                        font-size: 15px;
                    }

                    .po-nav-logo small {
                        font-weight: 400;
                        font-size: 11px;
                        color: var(--text-muted);
                        display: block;
                    }

                    .po-nav-logo-icon {
                        width: 34px;
                        height: 34px;
                        background: var(--primary);
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #000;
                        font-size: 15px;
                        flex-shrink: 0;
                    }

                    .po-nav-links {
                        display: flex;
                        gap: 28px;
                    }

                    .po-nav-links a {
                        font-size: 14px;
                        color: var(--text-muted);
                        display: flex;
                        align-items: center;
                        gap: 7px;
                        font-weight: 500;
                        transition: color .2s;
                    }

                    .po-nav-links a:hover {
                        color: var(--primary);
                    }

                    .po-nav-links a.active {
                        background: var(--primary);
                        color: #000 !important;
                        padding: 7px 14px;
                        border-radius: 8px;
                        font-weight: 700;
                    }

                    .po-nav-right {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                    }

                    .po-nav-right a {
                        font-size: 14px;
                        color: var(--text-muted);
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        font-weight: 500;
                    }

                    .po-nav-right a:hover {
                        color: var(--text);
                    }

                    /* ─── ALERTS ─────────────────────────────────── */
                    .po-alert-error {
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

                    .po-alert-success {
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

                    /* ─── ENTRY FORM ─────────────────────────────── */
                    .po-entry {
                        max-width: 640px;
                        margin: 0 auto;
                        padding: 64px 24px 80px;
                    }

                    .po-entry-title {
                        text-align: center;
                        margin-bottom: 36px;
                    }

                    .po-entry-title h1 {
                        font-size: 30px;
                        font-weight: 800;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 10px;
                        margin-bottom: 8px;
                    }

                    .po-entry-title h1 i {
                        color: var(--primary);
                    }

                    .po-entry-title p {
                        font-size: 14px;
                        color: var(--text-muted);
                    }

                    .po-form-card {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 32px;
                        margin-bottom: 18px;
                    }

                    .po-field-label {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                        margin-bottom: 8px;
                        display: block;
                    }

                    .po-input {
                        width: 100%;
                        background: rgba(255, 255, 255, .05);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 12px 14px;
                        font-size: 14px;
                        font-family: var(--font);
                        color: var(--text);
                        outline: none;
                        transition: border-color .2s, box-shadow .2s;
                    }

                    .po-input:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, .12);
                    }

                    .po-input::placeholder {
                        color: var(--text-muted);
                    }

                    .po-or {
                        text-align: center;
                        font-size: 13px;
                        color: var(--text-muted);
                        margin: 14px 0;
                        position: relative;
                    }

                    .po-or::before,
                    .po-or::after {
                        content: '';
                        position: absolute;
                        top: 50%;
                        width: 44%;
                        height: 1px;
                        background: var(--border);
                    }

                    .po-or::before {
                        left: 0;
                    }

                    .po-or::after {
                        right: 0;
                    }

                    .po-btn-primary {
                        width: 100%;
                        margin-top: 20px;
                        padding: 13px;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 10px;
                        font-size: 15px;
                        font-weight: 700;
                        font-family: var(--font);
                        cursor: pointer;
                        transition: background .2s;
                    }

                    .po-btn-primary:hover {
                        background: var(--primary-dk);
                    }

                    .po-info-box {
                        border-radius: 12px;
                        padding: 16px 18px;
                        margin-bottom: 14px;
                        font-size: 13px;
                    }

                    .po-info-box-header {
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        margin-bottom: 10px;
                    }

                    .po-info-box ul {
                        padding-left: 18px;
                    }

                    .po-info-box ul li {
                        margin-bottom: 4px;
                        line-height: 1.5;
                    }

                    .po-info-box.policy {
                        background: rgba(34, 197, 94, .06);
                        border: 1px solid rgba(34, 197, 94, .15);
                        color: #6ee7a0;
                    }

                    .po-info-box.policy .po-info-box-header {
                        color: #4ade80;
                    }

                    .po-info-box.note {
                        background: rgba(99, 102, 241, .06);
                        border: 1px solid rgba(99, 102, 241, .15);
                        color: #c4b5fd;
                    }

                    .po-info-box.note .po-info-box-header {
                        color: #a5b4fc;
                    }

                    /* ─── MENU STEP ──────────────────────────────── */
                    .po-menu-wrap {
                        max-width: 1200px;
                        margin: 0 auto;
                        padding: 24px 24px 80px;
                    }

                    .po-back {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        font-size: 13px;
                        color: var(--text-muted);
                        font-weight: 500;
                        cursor: pointer;
                        margin-bottom: 16px;
                        border: none;
                        background: none;
                        padding: 0;
                        font-family: var(--font);
                    }

                    .po-back:hover {
                        color: var(--primary);
                    }

                    .po-page-title {
                        font-size: 22px;
                        font-weight: 800;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        margin-bottom: 4px;
                    }

                    .po-page-title i {
                        color: var(--primary);
                    }

                    .po-booking-meta {
                        font-size: 13px;
                        color: var(--text-muted);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        flex-wrap: wrap;
                        margin-bottom: 20px;
                    }

                    .po-booking-meta strong {
                        color: var(--text);
                    }

                    .po-timer {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 6px 14px;
                        border-radius: 20px;
                        font-size: 13px;
                        font-weight: 600;
                        background: rgba(99, 102, 241, .1);
                        border: 1px solid rgba(99, 102, 241, .2);
                        color: #a5b4fc;
                        float: right;
                    }

                    .po-timer.urgent {
                        background: rgba(239, 68, 68, .08);
                        border-color: rgba(239, 68, 68, .2);
                        color: #f87171;
                    }

                    .po-layout {
                        display: grid;
                        grid-template-columns: 1fr 300px;
                        gap: 24px;
                        align-items: start;
                    }

                    @media (max-width:900px) {
                        .po-layout {
                            grid-template-columns: 1fr;
                        }
                    }

                    /* Search */
                    .po-search-wrap {
                        position: relative;
                        margin-bottom: 14px;
                    }

                    .po-search-wrap i {
                        position: absolute;
                        left: 14px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    .po-search-input {
                        width: 100%;
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 11px 14px 11px 40px;
                        font-size: 14px;
                        font-family: var(--font);
                        outline: none;
                        color: var(--text);
                        transition: border-color .2s;
                    }

                    .po-search-input:focus {
                        border-color: var(--primary);
                    }

                    .po-search-input::placeholder {
                        color: var(--text-muted);
                    }

                    /* Category pills */
                    .po-cats {
                        display: flex;
                        gap: 8px;
                        margin-bottom: 18px;
                        flex-wrap: wrap;
                    }

                    .po-cat {
                        padding: 6px 16px;
                        border-radius: 20px;
                        font-size: 13px;
                        font-weight: 600;
                        border: 1px solid var(--border);
                        background: none;
                        color: var(--text-muted);
                        cursor: pointer;
                        font-family: var(--font);
                        transition: all .15s;
                    }

                    .po-cat:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .po-cat.active {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    /* Menu cards — 2-col grid, click whole card */
                    .po-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 16px;
                    }

                    @media (max-width:640px) {
                        .po-grid {
                            grid-template-columns: 1fr;
                        }
                    }

                    .po-card {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        overflow: hidden;
                        position: relative;
                        cursor: pointer;
                        transition: box-shadow .2s, border-color .2s, transform .15s;
                    }

                    .po-card:hover {
                        box-shadow: 0 8px 32px rgba(0, 0, 0, .5);
                        border-color: rgba(232, 160, 32, .25);
                        transform: translateY(-2px);
                    }

                    .po-card.soldout {
                        opacity: .45;
                        cursor: default;
                    }

                    .po-card.soldout:hover {
                        transform: none;
                        box-shadow: none;
                    }

                    .po-card-img {
                        width: 100%;
                        height: 170px;
                        object-fit: cover;
                        display: block;
                    }

                    .po-card-img-ph {
                        width: 100%;
                        height: 170px;
                        background: var(--bg-lift);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 2.5rem;
                        color: var(--text-muted);
                    }

                    .po-soldout-badge {
                        position: absolute;
                        top: 50%;
                        left: 50%;
                        transform: translate(-50%, -50%);
                        background: rgba(239, 68, 68, .85);
                        color: #fff;
                        font-size: 13px;
                        font-weight: 700;
                        padding: 6px 16px;
                        border-radius: 8px;
                        pointer-events: none;
                    }

                    .po-card-body {
                        padding: 12px 14px 14px;
                    }

                    .po-card-name {
                        font-size: 14px;
                        font-weight: 700;
                        color: var(--text);
                        margin-bottom: 2px;
                    }

                    .po-card-cat {
                        font-size: 12px;
                        color: var(--text-muted);
                        margin-bottom: 6px;
                    }

                    .po-card-price {
                        font-size: 14px;
                        font-weight: 700;
                        color: var(--text);
                    }

                    /* Hidden submit form */
                    .po-card-form {
                        display: none;
                    }

                    /* ─── CART SIDEBAR ──────────────────────────── */
                    .po-cart {
                        background: var(--bg-card);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        position: sticky;
                        top: 72px;
                        overflow: hidden;
                    }

                    .po-cart-hd {
                        padding: 16px 20px;
                        border-bottom: 1px solid var(--border);
                        font-size: 15px;
                        font-weight: 700;
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .po-cart-hd i {
                        color: var(--primary);
                    }

                    .po-cart-body {
                        max-height: 340px;
                        overflow-y: auto;
                    }

                    .po-cart-empty {
                        padding: 36px 20px;
                        text-align: center;
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    .po-cart-empty i {
                        font-size: 2rem;
                        display: block;
                        margin-bottom: 10px;
                        opacity: .2;
                    }

                    .po-cart-empty small {
                        font-size: 12px;
                    }

                    .po-cart-row {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 11px 20px;
                        border-bottom: 1px solid var(--border);
                    }

                    .po-cart-row:last-child {
                        border-bottom: none;
                    }

                    .po-cart-row-info {
                        flex: 1;
                        min-width: 0;
                    }

                    .po-cart-row-name {
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    .po-cart-row-price {
                        font-size: 12px;
                        color: var(--text-muted);
                    }

                    .po-qty {
                        display: flex;
                        align-items: center;
                        gap: 4px;
                    }

                    .po-qty-btn {
                        width: 26px;
                        height: 26px;
                        border-radius: 6px;
                        border: 1px solid var(--border);
                        background: none;
                        color: var(--text);
                        font-size: 14px;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-family: var(--font);
                        transition: all .15s;
                    }

                    .po-qty-btn:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .po-qty-val {
                        width: 22px;
                        text-align: center;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    .po-del-btn {
                        background: none;
                        border: none;
                        color: #ef4444;
                        cursor: pointer;
                        font-size: 13px;
                        padding: 4px;
                    }

                    .po-cart-ft {
                        padding: 16px 20px;
                        border-top: 1px solid var(--border);
                    }

                    .po-cart-total-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: baseline;
                        margin-bottom: 12px;
                    }

                    .po-cart-total-lbl {
                        font-size: 14px;
                        color: var(--text-muted);
                    }

                    .po-cart-total-val {
                        font-size: 18px;
                        font-weight: 800;
                        color: var(--text);
                    }

                    .po-checkout-btn {
                        width: 100%;
                        padding: 13px;
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
                    }

                    .po-checkout-btn.ready {
                        background: rgba(255, 255, 255, .1);
                        color: var(--text);
                        border-color: rgba(255, 255, 255, .2);
                        cursor: pointer;
                    }

                    .po-checkout-btn.ready:hover {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    /* Footer */
                    .po-footer {
                        background: #000;
                        color: var(--text-muted);
                        text-align: center;
                        padding: 20px;
                        font-size: 13px;
                        border-top: 1px solid var(--border);
                    }

                    .po-footer strong {
                        color: var(--primary);
                    }
                </style>
            </head>

            <body>

                <!-- NAVBAR -->
                <nav class="po-nav">
                    <a href="${pageContext.request.contextPath}/" class="po-nav-logo">
                        <div class="po-nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div>Hương Việt<small>NHÀ HÀNG &amp; QUÁN NHẬU</small></div>
                    </a>
                    <div class="po-nav-links">
                        <a href="${pageContext.request.contextPath}/menu"><i class="fa-regular fa-book-open"></i> Thực
                            đơn</a>
                        <a href="${pageContext.request.contextPath}/booking"><i class="fa-regular fa-calendar"></i> Đặt
                            bàn</a>
                        <a href="${pageContext.request.contextPath}/booking/status"><i
                                class="fa-solid fa-magnifying-glass"></i> Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/pre-order" class="active"><i
                                class="fa-solid fa-cart-shopping"></i> Đặt món trước</a>
                    </div>
                    <div class="po-nav-right">
                        <a href="${pageContext.request.contextPath}/login"><i class="fa-regular fa-user"></i> Đăng
                            nhập</a>
                    </div>
                </nav>

                <c:choose>
                    <%-- ══════ STEP 1: ENTRY FORM ══════ --%>
                        <c:when test="${empty booking}">
                            <div class="po-entry">
                                <div class="po-entry-title">
                                    <h1><i class="fa-solid fa-cart-shopping"></i> Đặt món trước</h1>
                                    <p>Nhập mã booking để đặt món trước khi đến nhà hàng</p>
                                </div>

                                <c:if test="${not empty error}">
                                    <div class="po-alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}
                                    </div>
                                </c:if>
                                <c:if test="${not empty successMsg}">
                                    <div class="po-alert-success"><i class="fa-solid fa-circle-check"></i> ${successMsg}
                                    </div>
                                </c:if>

                                <div class="po-form-card">
                                    <form method="get" action="${pageContext.request.contextPath}/pre-order">
                                        <label class="po-field-label" for="codeInput">Mã booking</label>
                                        <input id="codeInput" type="text" name="code" class="po-input"
                                            placeholder="BK-2026-001" value="${param.code}" autocomplete="off">
                                        <div class="po-or">hoặc</div>
                                        <label class="po-field-label" for="phoneInput">Số điện thoại</label>
                                        <input id="phoneInput" type="tel" name="phone" class="po-input"
                                            placeholder="0901234567" value="${param.phone}" autocomplete="off">
                                        <button type="submit" class="po-btn-primary">Tiếp tục</button>
                                    </form>
                                </div>

                                <div class="po-info-box policy">
                                    <div class="po-info-box-header"><i class="fa-solid fa-shield-halved"></i> Chính sách
                                        cọc pre-order:</div>
                                    <ul>
                                        <li>Yêu cầu thanh toán <strong>10%</strong> giá trị món đặt trước</li>
                                        <li>Tiền cọc được trừ vào hóa đơn cuối khi thanh toán tại nhà hàng</li>
                                        <li>Hoàn trả <strong>100%</strong> nếu hủy trước giờ cutoff</li>
                                    </ul>
                                </div>
                                <div class="po-info-box note">
                                    <div class="po-info-box-header"><i class="fa-solid fa-circle-info"></i> Lưu ý:</div>
                                    <ul>
                                        <li>Chỉ booking PENDING hoặc CONFIRMED mới được đặt món trước</li>
                                        <li>Có thể sửa trước cutoff (60 phút trước giờ đặt bàn)</li>
                                        <li>Món hết hàng sẽ tự động bị loại bỏ</li>
                                    </ul>
                                </div>
                            </div>
                        </c:when>

                        <%-- ══════ STEP 2: MENU + CART ══════ --%>
                            <c:otherwise>
                                <div class="po-menu-wrap">

                                    <a href="${pageContext.request.contextPath}/pre-order" class="po-back">
                                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                                    </a>

                                    <div
                                        style="display:flex;align-items:flex-start;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-bottom:20px">
                                        <div>
                                            <div class="po-page-title"><i class="fa-solid fa-cart-shopping"></i> Đặt món
                                                trước</div>
                                            <div class="po-booking-meta">
                                                <strong>${booking.bookingCode}</strong> · ${booking.customerName} ·
                                                ${booking.bookingDate} lúc ${booking.bookingTime}
                                            </div>
                                        </div>
                                        <c:if test="${not empty cutoffDisplay}">
                                            <div class="po-timer ${cutoffOk ? '' : 'urgent'}">
                                                <i class="fa-regular fa-clock"></i> Còn ${cutoffDisplay} để sửa
                                            </div>
                                        </c:if>
                                    </div>

                                    <c:if test="${not empty error}">
                                        <div class="po-alert-error"><i class="fa-solid fa-circle-exclamation"></i>
                                            ${error}</div>
                                    </c:if>
                                    <c:if test="${not empty successMsg}">
                                        <div class="po-alert-success"><i class="fa-solid fa-circle-check"></i>
                                            ${successMsg}</div>
                                    </c:if>

                                    <div class="po-layout">
                                        <!-- LEFT: Menu -->
                                        <div>
                                            <!-- Search -->
                                            <div class="po-search-wrap">
                                                <i class="fa-solid fa-magnifying-glass"></i>
                                                <input type="text" class="po-search-input" placeholder="Tìm món..."
                                                    id="menuSearch" oninput="filterMenu()">
                                            </div>

                                            <!-- Category pills -->
                                            <div class="po-cats">
                                                <button class="po-cat active" onclick="filterCat(this,'')"
                                                    type="button">Tất cả</button>
                                                <c:forEach var="cat" items="${categories}">
                                                    <button class="po-cat"
                                                        onclick="filterCat(this,'${cat.categoryName}')"
                                                        type="button">${cat.categoryName}</button>
                                                </c:forEach>
                                            </div>

                                            <!-- 2-col grid — click card to add -->
                                            <div class="po-grid" id="menuGrid">
                                                <c:forEach var="item" items="${menuItems}">
                                                    <div class="po-card ${item.status != 'AVAILABLE' ? 'soldout' : ''}"
                                                        data-name="${item.productName}"
                                                        data-cat="${item.category.categoryName}"
                                                        onclick="addItem(this)">

                                                        <%-- Hidden add-form --%>
                                                            <c:if test="${item.status == 'AVAILABLE'}">
                                                                <form method="post"
                                                                    action="${pageContext.request.contextPath}/pre-order"
                                                                    class="po-card-form">
                                                                    <input type="hidden" name="action" value="add">
                                                                    <input type="hidden" name="bookingCode"
                                                                        value="${booking.bookingCode}">
                                                                    <input type="hidden" name="productId"
                                                                        value="${item.id}">
                                                                </form>
                                                            </c:if>

                                                            <%-- Image --%>
                                                                <%-- Image placeholder (no imageUrl field on Product)
                                                                    --%>
                                                                    <div class="po-card-img-ph"><i
                                                                            class="fa-solid fa-bowl-food"></i></div>
                                                                    <c:if test="${item.status != 'AVAILABLE'}">
                                                                        <span class="po-soldout-badge">Hết hàng</span>
                                                                    </c:if>

                                                                    <div class="po-card-body">
                                                                        <div class="po-card-name">${item.productName}
                                                                        </div>
                                                                        <div class="po-card-cat">
                                                                            ${item.category.categoryName}</div>
                                                                        <div class="po-card-price">
                                                                            <fmt:formatNumber value="${item.price}"
                                                                                pattern="#,###" /> đ
                                                                        </div>
                                                                    </div>
                                                    </div>
                                                </c:forEach>

                                                <c:if test="${empty menuItems}">
                                                    <div
                                                        style="grid-column:1/-1;text-align:center;padding:48px;color:var(--text-muted)">
                                                        <i class="fa-solid fa-bowl-food"
                                                            style="font-size:2rem;display:block;margin-bottom:12px;opacity:.2"></i>
                                                        Chưa có món nào
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>

                                        <!-- RIGHT: Cart -->
                                        <div class="po-cart">
                                            <div class="po-cart-hd">
                                                <i class="fa-solid fa-cart-shopping"></i>
                                                Giỏ món
                                                <c:choose>
                                                    <c:when test="${not empty preOrderItems}">
                                                        (${preOrderItems.size()} món)
                                                    </c:when>
                                                    <c:otherwise>(0 món)</c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="po-cart-body">
                                                <c:choose>
                                                    <c:when test="${empty preOrderItems}">
                                                        <div class="po-cart-empty">
                                                            <i class="fa-solid fa-utensils"></i>
                                                            <p>Chưa có món nào</p>
                                                            <small>Bấm vào món trong thực đơn để thêm</small>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="poi" items="${preOrderItems}">
                                                            <div class="po-cart-row">
                                                                <div class="po-cart-row-info">
                                                                    <div class="po-cart-row-name">
                                                                        ${poi.product.productName}</div>
                                                                    <div class="po-cart-row-price">
                                                                        <fmt:formatNumber value="${poi.product.price}"
                                                                            pattern="#,###" /> đ
                                                                    </div>
                                                                </div>
                                                                <div class="po-qty">
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}/pre-order"
                                                                        style="display:inline">
                                                                        <input type="hidden" name="action"
                                                                            value="updateQty">
                                                                        <input type="hidden" name="bookingCode"
                                                                            value="${booking.bookingCode}">
                                                                        <input type="hidden" name="itemId"
                                                                            value="${poi.id}">
                                                                        <input type="hidden" name="delta" value="-1">
                                                                        <button type="submit"
                                                                            class="po-qty-btn">−</button>
                                                                    </form>
                                                                    <span class="po-qty-val">${poi.quantity}</span>
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}/pre-order"
                                                                        style="display:inline">
                                                                        <input type="hidden" name="action"
                                                                            value="updateQty">
                                                                        <input type="hidden" name="bookingCode"
                                                                            value="${booking.bookingCode}">
                                                                        <input type="hidden" name="itemId"
                                                                            value="${poi.id}">
                                                                        <input type="hidden" name="delta" value="1">
                                                                        <button type="submit"
                                                                            class="po-qty-btn">+</button>
                                                                    </form>
                                                                </div>
                                                                <form method="post"
                                                                    action="${pageContext.request.contextPath}/pre-order"
                                                                    style="display:inline">
                                                                    <input type="hidden" name="action" value="remove">
                                                                    <input type="hidden" name="bookingCode"
                                                                        value="${booking.bookingCode}">
                                                                    <input type="hidden" name="itemId"
                                                                        value="${poi.id}">
                                                                    <button type="submit" class="po-del-btn"
                                                                        title="Xóa"><i
                                                                            class="fa-solid fa-trash"></i></button>
                                                                </form>
                                                            </div>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="po-cart-ft">
                                                <div class="po-cart-total-row">
                                                    <span class="po-cart-total-lbl">Tạm tính:</span>
                                                    <span class="po-cart-total-val">
                                                        <fmt:formatNumber value="${cartTotal != null ? cartTotal : 0}"
                                                            pattern="#,###" /> đ
                                                    </span>
                                                </div>
                                                <form method="post"
                                                    action="${pageContext.request.contextPath}/pre-order">
                                                    <input type="hidden" name="action" value="confirm">
                                                    <input type="hidden" name="bookingCode"
                                                        value="${booking.bookingCode}">
                                                    <button type="submit"
                                                        class="po-checkout-btn ${empty preOrderItems ? '' : 'ready'}"
                                                        ${empty preOrderItems ? 'disabled' : '' }>
                                                        <i class="fa-solid fa-credit-card"></i> Tiếp tục thanh toán cọc
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                </c:choose>

                <footer class="po-footer">
                    Nhà hàng Hương Việt &nbsp;·&nbsp; 123 Nguyễn Huệ, Q.1, TP.HCM &nbsp;·&nbsp; Hotline: <strong>1900
                        1234</strong>
                </footer>

                <script>
                    // Click card → submit hidden form
                    function addItem(card) {
                        if (card.classList.contains('soldout')) return;
                        const form = card.querySelector('.po-card-form');
                        if (form) form.submit();
                    }

                    // Search filter
                    function filterMenu() {
                        const q = document.getElementById('menuSearch').value.toLowerCase();
                        document.querySelectorAll('.po-card').forEach(el => {
                            el.style.display = (el.dataset.name || '').toLowerCase().includes(q) ? '' : 'none';
                        });
                    }

                    // Category filter
                    function filterCat(btn, cat) {
                        document.querySelectorAll('.po-cat').forEach(t => t.classList.remove('active'));
                        btn.classList.add('active');
                        document.querySelectorAll('.po-card').forEach(el => {
                            el.style.display = (!cat || el.dataset.cat === cat) ? '' : 'none';
                        });
                    }
                </script>

                <!-- chatbot widget include -->
                <jsp:include page="/chatbot.jsp" />
            </body>

            </html>