<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta name="description"
                    content="Đặt bàn tại nhà hàng Hương Việt — Đảm bảo chỗ ngồi cho buổi họp mặt của bạn.">
                <title>Đặt bàn — Nhà hàng Hương Việt</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/mobile.css">
                <!-- intl-tel-input styles -->
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/css/intlTelInput.css">
                <style>
                    .booking-hero {
                        padding: 140px 48px 40px;
                        text-align: center;
                        position: relative;
                    }

                    .booking-hero::before {
                        content: '';
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, 0.08) 0%, transparent 60%);
                        pointer-events: none;
                    }

                    .booking-hero h1 {
                        font-family: var(--font-serif);
                        font-size: clamp(28px, 4vw, 44px);
                        color: var(--text);
                        margin-bottom: 10px;
                    }

                    .booking-hero h1 em {
                        color: var(--primary);
                        font-style: italic;
                    }

                    .booking-hero p {
                        font-size: 15px;
                        color: var(--text-muted);
                        max-width: 480px;
                        margin: 0 auto;
                    }

                    /* ── Form Section ── */
                    .booking-form-section {
                        max-width: 620px;
                        margin: 0 auto;
                        padding: 0 24px 80px;
                    }

                    .booking-card {
                        background: rgba(26, 24, 20, 0.8);
                        border: 1px solid var(--border);
                        border-radius: 16px;
                        padding: 32px;
                        backdrop-filter: blur(12px);
                    }

                    .booking-card h2 {
                        font-size: 18px;
                        font-weight: 700;
                        color: var(--text);
                        margin-bottom: 24px;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                    }

                    .booking-card h2 i {
                        color: var(--primary);
                    }

                    .form-group {
                        margin-bottom: 20px;
                    }

                    .form-label {
                        display: block;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text);
                        margin-bottom: 6px;
                    }

                    .form-label .required {
                        color: #ef4444;
                    }

                    .form-control {
                        width: 100%;
                        background: rgba(255, 255, 255, 0.05);
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        padding: 12px 14px;
                        color: var(--text);
                        font-size: 14px;
                        font-family: inherit;
                        outline: none;
                        transition: all .25s;
                    }

                    /* intl-tel-input dark theme override */
                    .iti {
                        width: 100%;
                    }

                    .iti--separate-dial-code .iti__selected-flag,
                    .iti__country-list {
                        background: #1a1814;
                        border-color: var(--border);
                    }

                    .iti__country-list li {
                        color: var(--text);
                    }

                    .iti__country-list .iti__country.iti__highlight,
                    .iti__country-list .iti__country:hover {
                        background: rgba(232, 160, 32, .12);
                    }

                    .iti__selected-dial-code {
                        color: var(--text-muted);
                    }

                    .form-control::placeholder {
                        color: var(--text-muted);
                    }

                    .form-control:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, 0.1);
                    }

                    .form-control.error {
                        border-color: #ef4444;
                    }

                    .form-error {
                        font-size: 12px;
                        color: #ef4444;
                        margin-top: 4px;
                    }

                    .form-row {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 16px;
                    }

                    textarea.form-control {
                        resize: vertical;
                        min-height: 80px;
                    }

                    select.form-control {
                        appearance: none;
                        -webkit-appearance: none;
                        -moz-appearance: none;
                        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%239e9488' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
                        background-repeat: no-repeat;
                        background-position: right 14px center;
                        padding-right: 40px;
                        cursor: pointer;
                    }

                    select.form-control option {
                        background: #1a1814;
                        color: var(--text);
                        padding: 8px 14px;
                    }

                    /* ── Combined DateTime Picker ── */
                    .datetime-wrapper {
                        position: relative;
                    }

                    .datetime-wrapper .form-control {
                        padding-right: 42px;
                        font-variant-numeric: tabular-nums;
                        letter-spacing: 0.03em;
                        font-weight: 600;
                    }

                    .datetime-wrapper .dt-icon {
                        position: absolute;
                        right: 14px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: var(--text-muted);
                        font-size: 15px;
                        cursor: pointer;
                        transition: all .25s;
                        width: 30px;
                        height: 30px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border-radius: 6px;
                    }

                    .datetime-wrapper .dt-icon:hover {
                        color: var(--primary);
                        background: rgba(232, 160, 32, 0.1);
                    }

                    .datetime-wrapper .form-control:focus ~ .dt-icon {
                        color: var(--primary);
                    }

                    /* Dropdown */
                    .dt-dropdown {
                        position: absolute;
                        top: calc(100% + 6px);
                        left: 0;
                        right: 0;
                        background: #1a1814;
                        border: 1px solid rgba(232, 160, 32, 0.2);
                        border-radius: 12px;
                        padding: 0;
                        z-index: 100;
                        display: none;
                        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5);
                        overflow: hidden;
                    }

                    .dt-dropdown.open {
                        display: block;
                        animation: dropIn .15s ease-out;
                    }

                    @keyframes dropIn {
                        from { opacity: 0; transform: translateY(-6px); }
                        to   { opacity: 1; transform: translateY(0); }
                    }

                    .dt-columns {
                        display: flex;
                    }

                    .dt-col {
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                        min-width: 0;
                    }

                    .dt-col + .dt-col {
                        border-left: 1px solid rgba(232, 160, 32, 0.08);
                    }

                    .dt-col.dt-separator {
                        border-left: 2px solid rgba(232, 160, 32, 0.25);
                    }

                    .dt-col-label {
                        text-align: center;
                        font-size: 9px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: var(--primary);
                        padding: 10px 0 6px;
                        border-bottom: 1px solid rgba(232, 160, 32, 0.08);
                        white-space: nowrap;
                    }

                    .dt-col-list {
                        max-height: 200px;
                        overflow-y: auto;
                        padding: 4px;
                    }

                    .dt-slot {
                        padding: 7px 2px;
                        text-align: center;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                        border-radius: 6px;
                        cursor: pointer;
                        transition: all .15s;
                        font-variant-numeric: tabular-nums;
                        letter-spacing: 0.02em;
                        margin-bottom: 1px;
                    }

                    .dt-slot:hover {
                        background: rgba(232, 160, 32, 0.12);
                        color: var(--primary);
                    }

                    .dt-slot.active {
                        background: var(--primary);
                        color: #000;
                        font-weight: 700;
                    }

                    .dt-slot.disabled {
                        opacity: 0.25;
                        pointer-events: none;
                    }

                    /* Scrollbar */
                    .dt-col-list::-webkit-scrollbar {
                        width: 3px;
                    }
                    .dt-col-list::-webkit-scrollbar-thumb {
                        background: rgba(232, 160, 32, 0.25);
                        border-radius: 2px;
                    }

                    .btn-submit {
                        width: 100%;
                        padding: 14px 24px;
                        font-size: 15px;
                        font-weight: 700;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 12px;
                        cursor: pointer;
                        font-family: inherit;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                        margin-top: 28px;
                        transition: all .25s;
                    }

                    .btn-submit:hover {
                        background: #cfa730;
                        transform: translateY(-1px);
                    }

                    /* ── Success Card ── */
                    .success-card {
                        background: rgba(34, 197, 94, 0.08);
                        border: 1px solid rgba(34, 197, 94, 0.2);
                        border-radius: 16px;
                        padding: 40px 32px;
                        text-align: center;
                    }

                    .success-card .icon-circle {
                        width: 64px;
                        height: 64px;
                        border-radius: 50%;
                        background: rgba(34, 197, 94, 0.15);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        margin: 0 auto 16px;
                        color: #22c55e;
                        font-size: 28px;
                    }

                    .success-card h2 {
                        font-size: 20px;
                        color: var(--text);
                        margin-bottom: 8px;
                    }

                    .success-card p {
                        color: var(--text-muted);
                        font-size: 14px;
                        margin-bottom: 24px;
                    }

                    .booking-code-display {
                        display: inline-flex;
                        align-items: center;
                        gap: 12px;
                        padding: 16px 24px;
                        background: rgba(232, 160, 32, 0.08);
                        border: 2px dashed var(--primary);
                        border-radius: 12px;
                        margin-bottom: 24px;
                    }

                    .booking-code-display .code {
                        font-size: 24px;
                        font-weight: 800;
                        color: var(--primary);
                        letter-spacing: 0.04em;
                        font-family: 'Be Vietnam Pro', monospace;
                    }

                    .btn-copy {
                        padding: 8px 12px;
                        background: var(--primary);
                        color: #000;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-family: inherit;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .success-actions {
                        display: flex;
                        gap: 12px;
                        justify-content: center;
                        flex-wrap: wrap;
                    }

                    .btn-outline-light {
                        padding: 10px 20px;
                        border: 1px solid var(--border);
                        border-radius: 10px;
                        color: var(--text);
                        background: none;
                        font-family: inherit;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        transition: all .25s;
                        text-decoration: none;
                    }

                    .btn-outline-light:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .alert-info {
                        background: rgba(59, 130, 246, 0.08);
                        border: 1px solid rgba(59, 130, 246, 0.2);
                        color: #60a5fa;
                        padding: 12px 16px;
                        border-radius: 10px;
                        font-size: 13px;
                        margin-bottom: 20px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
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
                        .booking-hero {
                            padding: 120px 20px 32px;
                        }

                        .booking-form-section {
                            padding: 0 16px 60px;
                        }

                        .booking-card {
                            padding: 24px 20px;
                        }

                        .form-row {
                            grid-template-columns: 1fr;
                        }
                    }

                    /* ─── User Dropdown ─── */
                    .user-dropdown { position: relative; }
                    .user-dropdown-btn { display:flex; align-items:center; gap:10px; background:rgba(232,160,32,0.1); border:1px solid rgba(232,160,32,0.25); border-radius:50px; padding:8px 16px 8px 10px; color:#e8a020; font-size:14px; font-weight:500; cursor:pointer; transition:all 0.3s; font-family:inherit; }
                    .user-dropdown-btn:hover { background:rgba(232,160,32,0.18); border-color:rgba(232,160,32,0.4); }
                    .user-avatar { width:32px; height:32px; border-radius:50%; background:linear-gradient(135deg,#e8a020,#d4911c); display:flex; align-items:center; justify-content:center; color:#fff; font-size:14px; }
                    .dd-arrow { font-size:10px; transition:transform 0.3s; color:rgba(232,160,32,0.6); }
                    .user-dropdown.open .dd-arrow { transform:rotate(180deg); }
                    .user-dropdown-menu { position:absolute; top:calc(100% + 8px); right:0; min-width:220px; background:#1a1710; border:1px solid rgba(232,160,32,0.2); border-radius:12px; padding:6px; box-shadow:0 12px 40px rgba(0,0,0,0.5); opacity:0; visibility:hidden; transform:translateY(-8px); transition:all 0.25s ease; z-index:100; }
                    .user-dropdown.open .user-dropdown-menu { opacity:1; visibility:visible; transform:translateY(0); }
                    .dd-item { display:flex; align-items:center; gap:10px; padding:10px 14px; border-radius:8px; font-size:14px; color:rgba(255,255,255,0.75); text-decoration:none; transition:all 0.2s; }
                    .dd-item:hover { background:rgba(232,160,32,0.1); color:#e8a020; }
                    .dd-item i { width:18px; text-align:center; font-size:13px; }
                    .dd-divider { height:1px; background:rgba(255,255,255,0.08); margin:4px 8px; }
                    .dd-logout:hover { color:#f87171; background:rgba(248,113,113,0.08); }
                </style>
            </head>

            <body>

                <!-- ── USER NAVBAR ── -->
                <nav class="navbar" id="navbar" style="background:rgba(15,14,12,0.95); backdrop-filter:blur(12px);">
                    <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
                        <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                    </a>
                    <div class="nav-links">
                        <a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a>
                        <a href="${pageContext.request.contextPath}/user/booking/create" class="active">Đặt bàn</a>
                        <a href="${pageContext.request.contextPath}/user/booking/status">Tra cứu booking</a>
                    </div>
                    <div class="nav-actions">
                        <div class="user-dropdown" id="userDropdown">
                            <button class="user-dropdown-btn" onclick="document.getElementById('userDropdown').classList.toggle('open')">
                                <div class="user-avatar"><i class="fa-solid fa-user"></i></div>
                                <span>${sessionScope.user.fullName}</span>
                                <i class="fa-solid fa-chevron-down dd-arrow"></i>
                            </button>
                            <div class="user-dropdown-menu">
                                <a href="${pageContext.request.contextPath}/user/profile" class="dd-item">
                                    <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa thông tin
                                </a>
                                <div class="dd-divider"></div>
                                <a href="${pageContext.request.contextPath}/logout" class="dd-item dd-logout">
                                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="nav-burger" id="navBurger"><span></span><span></span><span></span></div>
                </nav>

                <!-- ── HERO ── -->
                <section class="booking-hero">
                    <div class="section-label"><i class="fa-solid fa-calendar-check"></i> Đặt bàn trực tuyến</div>
                    <h1>Đảm bảo chỗ ngồi <em>hoàn hảo</em></h1>
                    <p>Đặt bàn trước để có trải nghiệm tốt nhất. Chúng tôi sẽ xác nhận ngay trong vòng 15 phút.</p>
                </section>

                <!-- ── BOOKING FORM ── -->
                <div class="booking-form-section">

                    <c:choose>
                        <c:when test="${not empty bookingCode}">
                            <!-- SUCCESS STATE -->
                            <div class="success-card">
                                <div class="icon-circle"><i class="fa-solid fa-check"></i></div>
                                <h2>Đặt bàn thành công!</h2>
                                <p>Vui lòng lưu lại mã đặt bàn để tra cứu trạng thái.</p>
                                <div class="booking-code-display">
                                    <span class="code" id="bookingCode">${bookingCode}</span>
                                    <button class="btn-copy" onclick="copyCode()"><i class="fa-solid fa-copy"></i>
                                        Copy</button>
                                </div>
                                <div class="success-actions">
                                    <a href="${pageContext.request.contextPath}/user/booking/status?code=${bookingCode}"
                                        class="btn-outline-light">
                                        <i class="fa-solid fa-search"></i> Xem trạng thái
                                    </a>

                                    <a href="${pageContext.request.contextPath}/user/booking/create" class="btn-outline-light">
                                        <i class="fa-solid fa-plus"></i> Đặt bàn mới
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- FORM STATE -->
                            <div class="booking-card">
                                <h2><i class="fa-solid fa-pen-to-square"></i> Thông tin đặt bàn</h2>

                                <c:if test="${not empty error}">
                                    <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}
                                    </div>
                                </c:if>

                                <div class="alert-info">
                                    <i class="fa-solid fa-circle-info"></i>
                                    Giờ hoạt động: 10:00 – 22:00 hàng ngày. Đặt trước ít nhất 1 giờ.
                                </div>

                                <form method="post" action="${pageContext.request.contextPath}/user/booking/create"
                                    id="bookingForm">
                                    <!-- Họ tên + SĐT -->
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">Họ và tên <span class="required">*</span></label>
                                            <input type="text" name="customerName"
                                                class="form-control ${not empty errors.customerName ? 'error' : ''}"
                                                value="${not empty param.customerName ? param.customerName : customerName}"
                                                placeholder="Nguyễn Văn A" required>
                                            <c:if test="${not empty errors.customerName}">
                                                <div class="form-error">${errors.customerName}</div>
                                            </c:if>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">Số điện thoại <span
                                                    class="required">*</span></label>
                                            <input type="tel" id="phoneInput" name="customerPhone"
                                                class="form-control ${not empty errors.customerPhone ? 'error' : ''}"
                                                value="${not empty param.customerPhone ? param.customerPhone : customerPhone}"
                                                placeholder="0901234567" required>
                                            <c:if test="${not empty errors.customerPhone}">
                                                <div class="form-error">${errors.customerPhone}</div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Ngày + Giờ -->
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">Ngày <span class="required">*</span></label>
                                            <input type="hidden" name="bookingDate" id="bookingDateHidden"
                                                value="${not empty param.bookingDate ? param.bookingDate : bookingDate}">
                                            <div class="datetime-wrapper" id="dateWrapper">
                                                <input type="text" id="dateDisplayInput"
                                                    class="form-control ${not empty errors.bookingDate ? 'error' : ''}"
                                                    placeholder="Chọn ngày"
                                                    autocomplete="off"
                                                    required readonly>
                                                <i class="fa-regular fa-calendar dt-icon" id="dateToggle"></i>
                                                <div class="dt-dropdown" id="dateDropdown">
                                                    <div class="dt-columns">
                                                        <div class="dt-col">
                                                            <div class="dt-col-label">Ngày</div>
                                                            <div class="dt-col-list" id="daySlots"></div>
                                                        </div>
                                                        <div class="dt-col">
                                                            <div class="dt-col-label">Tháng</div>
                                                            <div class="dt-col-list" id="monthSlots"></div>
                                                        </div>
                                                        <div class="dt-col">
                                                            <div class="dt-col-label">Năm</div>
                                                            <div class="dt-col-list" id="yearSlots"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <c:if test="${not empty errors.bookingDate}">
                                                <div class="form-error">${errors.bookingDate}</div>
                                            </c:if>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">Giờ <span class="required">*</span></label>
                                            <input type="hidden" name="bookingTime" id="bookingTimeHidden"
                                                value="${param.bookingTime}">
                                            <div class="datetime-wrapper" id="timeWrapper">
                                                <input type="text" id="timeDisplayInput"
                                                    class="form-control ${not empty errors.bookingTime ? 'error' : ''}"
                                                    placeholder="Chọn giờ"
                                                    autocomplete="off"
                                                    required readonly>
                                                <i class="fa-regular fa-clock dt-icon" id="timeToggle"></i>
                                                <div class="dt-dropdown" id="timeDropdown">
                                                    <div class="dt-columns">
                                                        <div class="dt-col">
                                                            <div class="dt-col-label">Giờ</div>
                                                            <div class="dt-col-list" id="hourSlots"></div>
                                                        </div>
                                                        <div class="dt-col">
                                                            <div class="dt-col-label">Phút</div>
                                                            <div class="dt-col-list" id="minuteSlots"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <c:if test="${not empty errors.bookingTime}">
                                                <div class="form-error">${errors.bookingTime}</div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Số người -->
                                    <div class="form-group">
                                        <label class="form-label">Số lượng khách <span class="required">*</span></label>
                                        <input type="hidden" name="partySize" id="partySizeHidden"
                                            value="${param.partySize}">
                                        <div class="datetime-wrapper" id="partyWrapper">
                                            <input type="text" id="partyDisplayInput"
                                                class="form-control"
                                                placeholder="Chọn số khách"
                                                autocomplete="off"
                                                required readonly>
                                            <i class="fa-solid fa-users dt-icon" id="partyToggle"></i>
                                            <div class="dt-dropdown" id="partyDropdown">
                                                <div class="dt-columns">
                                                    <div class="dt-col">
                                                        <div class="dt-col-label">Số khách</div>
                                                        <div class="dt-col-list" id="partySlots"></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Ghi chú -->
                                    <div class="form-group">
                                        <label class="form-label">Ghi chú</label>
                                        <textarea name="note" class="form-control"
                                            placeholder="Sinh nhật, dị ứng thực phẩm, yêu cầu đặc biệt...">${param.note}</textarea>
                                    </div>

                                    <button type="submit" class="btn-submit">
                                        <i class="fa-solid fa-calendar-check"></i> Xác nhận đặt bàn
                                    </button>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- ── FOOTER ── -->
                <footer style="background:#0a0908; border-top:1px solid rgba(255,255,255,0.06); padding:24px 40px; display:flex; align-items:center; justify-content:space-between; font-size:13px; color:#9e9488;">
                    <p>© 2026 Nhà hàng Hương Việt. 123 Nguyễn Huệ, Q.1, TP.HCM</p>
                    <p>Hotline: <strong style="color:#e8a020;">1900 1234</strong> (8:00 – 23:00)</p>
                </footer>

                <script>
                    // Navbar scroll
                    const navbar = document.getElementById('navbar');
                    window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 60));

                    // Burger menu
                    document.getElementById('navBurger').addEventListener('click', function () {
                        const links = document.querySelector('.nav-links');
                        links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
                    });

                    // Close dropdown on outside click
                    document.addEventListener('click', function(e) {
                        const dd = document.getElementById('userDropdown');
                        if (dd && !dd.contains(e.target)) dd.classList.remove('open');
                    });

                    // Copy booking code
                    function copyCode() {
                        const code = document.getElementById('bookingCode').textContent;
                        navigator.clipboard.writeText(code).then(() => {
                            const btn = document.querySelector('.btn-copy');
                            btn.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
                            setTimeout(() => btn.innerHTML = '<i class="fa-solid fa-copy"></i> Copy', 2000);
                        });
                    }

                    // ── Date Picker (3 columns) ──
                    (function () {
                        const displayInput = document.getElementById('dateDisplayInput');
                        const hiddenInput = document.getElementById('bookingDateHidden');
                        const dropdown = document.getElementById('dateDropdown');
                        const toggle = document.getElementById('dateToggle');
                        const dayC = document.getElementById('daySlots');
                        const monthC = document.getElementById('monthSlots');
                        const yearC = document.getElementById('yearSlots');
                        const wrapper = document.getElementById('dateWrapper');
                        if (!displayInput || !dropdown) return;

                        const now = new Date();
                        const todayD = now.getDate(), todayM = now.getMonth() + 1, todayY = now.getFullYear();
                        let sDay = null, sMonth = null, sYear = null;

                        const initVal = hiddenInput ? hiddenInput.value.trim() : '';
                        if (initVal && initVal.includes('-')) {
                            const p = initVal.split('-');
                            sYear = parseInt(p[0]); sMonth = parseInt(p[1]); sDay = parseInt(p[2]);
                        } else {
                            const tmr = new Date(); tmr.setDate(tmr.getDate() + 1);
                            sDay = tmr.getDate(); sMonth = tmr.getMonth() + 1; sYear = tmr.getFullYear();
                        }

                        function pad(n) { return String(n).padStart(2, '0'); }
                        function daysInMonth(m, y) { return new Date(y, m, 0).getDate(); }
                        function isDatePast(d, m, y) { return new Date(y, m - 1, d) < new Date(todayY, todayM - 1, todayD); }

                        function sync() {
                            if (sDay && sMonth && sYear) {
                                displayInput.value = pad(sDay) + '/' + pad(sMonth) + '/' + sYear;
                                hiddenInput.value = sYear + '-' + pad(sMonth) + '-' + pad(sDay);
                            }
                        }

                        for (let m = 1; m <= 12; m++) {
                            const el = document.createElement('div');
                            el.className = 'dt-slot'; el.textContent = pad(m); el.dataset.val = m;
                            el.addEventListener('click', function (e) {
                                e.stopPropagation(); sMonth = parseInt(this.dataset.val);
                                rebuildDays(); sync(); highlight();
                            });
                            monthC.appendChild(el);
                        }

                        for (let y = todayY; y <= todayY + 2; y++) {
                            const el = document.createElement('div');
                            el.className = 'dt-slot'; el.textContent = y; el.dataset.val = y;
                            el.addEventListener('click', function (e) {
                                e.stopPropagation(); sYear = parseInt(this.dataset.val);
                                rebuildDays(); sync(); highlight();
                            });
                            yearC.appendChild(el);
                        }

                        function rebuildDays() {
                            const max = daysInMonth(sMonth || todayM, sYear || todayY);
                            if (sDay > max) sDay = max;
                            dayC.innerHTML = '';
                            for (let d = 1; d <= max; d++) {
                                const el = document.createElement('div');
                                el.className = 'dt-slot'; el.textContent = pad(d); el.dataset.val = d;
                                if (isDatePast(d, sMonth || todayM, sYear || todayY)) el.classList.add('disabled');
                                el.addEventListener('click', function (e) {
                                    e.stopPropagation(); sDay = parseInt(this.dataset.val);
                                    sync(); highlight();
                                });
                                dayC.appendChild(el);
                            }
                        }

                        function highlight() {
                            dayC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === sDay));
                            monthC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === sMonth));
                            yearC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === sYear));
                        }

                        function scrollActive() {
                            [dayC, monthC, yearC].forEach(c => {
                                const a = c.querySelector('.dt-slot.active');
                                if (a) a.scrollIntoView({ block: 'center', behavior: 'smooth' });
                            });
                        }

                        function open() { dropdown.classList.add('open'); highlight(); setTimeout(scrollActive, 50); }
                        function close() { dropdown.classList.remove('open'); }

                        toggle.addEventListener('click', function (e) { e.stopPropagation(); dropdown.classList.contains('open') ? close() : open(); });
                        displayInput.addEventListener('click', function (e) { e.stopPropagation(); open(); });
                        document.addEventListener('click', function (e) { if (!wrapper.contains(e.target)) close(); });

                        rebuildDays(); sync(); highlight();
                    })();

                    // ── Time Picker (2 columns) ──
                    (function () {
                        const displayInput = document.getElementById('timeDisplayInput');
                        const hiddenInput = document.getElementById('bookingTimeHidden');
                        const dropdown = document.getElementById('timeDropdown');
                        const toggle = document.getElementById('timeToggle');
                        const hourC = document.getElementById('hourSlots');
                        const minuteC = document.getElementById('minuteSlots');
                        const wrapper = document.getElementById('timeWrapper');
                        if (!displayInput || !dropdown) return;

                        let sHour = null, sMinute = null;

                        const initVal = hiddenInput ? hiddenInput.value.trim() : '';
                        if (initVal && initVal.includes(':')) {
                            const p = initVal.split(':');
                            sHour = parseInt(p[0]); sMinute = parseInt(p[1]);
                        } else {
                            sHour = 18; sMinute = 0;
                        }

                        function pad(n) { return String(n).padStart(2, '0'); }

                        function sync() {
                            if (sHour !== null && sMinute !== null) {
                                displayInput.value = pad(sHour) + ':' + pad(sMinute);
                                hiddenInput.value = pad(sHour) + ':' + pad(sMinute);
                            }
                        }

                        for (let h = 10; h <= 21; h++) {
                            const el = document.createElement('div');
                            el.className = 'dt-slot'; el.textContent = pad(h); el.dataset.val = h;
                            el.addEventListener('click', function (e) {
                                e.stopPropagation(); sHour = parseInt(this.dataset.val);
                                if (sMinute === null) sMinute = 0;
                                sync(); highlight();
                            });
                            hourC.appendChild(el);
                        }

                        for (let m = 0; m <= 59; m++) {
                            const el = document.createElement('div');
                            el.className = 'dt-slot'; el.textContent = pad(m); el.dataset.val = m;
                            el.addEventListener('click', function (e) {
                                e.stopPropagation(); sMinute = parseInt(this.dataset.val);
                                if (sHour === null) sHour = 10;
                                sync(); highlight();
                            });
                            minuteC.appendChild(el);
                        }

                        function highlight() {
                            hourC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === sHour));
                            minuteC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === sMinute));
                        }

                        function scrollActive() {
                            [hourC, minuteC].forEach(c => {
                                const a = c.querySelector('.dt-slot.active');
                                if (a) a.scrollIntoView({ block: 'center', behavior: 'smooth' });
                            });
                        }

                        function open() { dropdown.classList.add('open'); highlight(); setTimeout(scrollActive, 50); }
                        function close() { dropdown.classList.remove('open'); }

                        toggle.addEventListener('click', function (e) { e.stopPropagation(); dropdown.classList.contains('open') ? close() : open(); });
                        displayInput.addEventListener('click', function (e) { e.stopPropagation(); open(); });
                        document.addEventListener('click', function (e) { if (!wrapper.contains(e.target)) close(); });

                        sync(); highlight();
                    })();

                    // ── Party Size Picker (1 column) ──
                    (function () {
                        const displayInput = document.getElementById('partyDisplayInput');
                        const hiddenInput = document.getElementById('partySizeHidden');
                        const dropdown = document.getElementById('partyDropdown');
                        const toggle = document.getElementById('partyToggle');
                        const slotC = document.getElementById('partySlots');
                        const wrapper = document.getElementById('partyWrapper');
                        if (!displayInput || !dropdown) return;

                        let selected = hiddenInput && hiddenInput.value ? parseInt(hiddenInput.value) : null;

                        function sync() {
                            if (selected) {
                                displayInput.value = selected + ' người';
                                hiddenInput.value = selected;
                            }
                        }

                        for (let i = 1; i <= 20; i++) {
                            const el = document.createElement('div');
                            el.className = 'dt-slot';
                            el.textContent = i + ' người';
                            el.dataset.val = i;
                            el.addEventListener('click', function (e) {
                                e.stopPropagation();
                                selected = parseInt(this.dataset.val);
                                sync(); highlight();
                            });
                            slotC.appendChild(el);
                        }

                        function highlight() {
                            slotC.querySelectorAll('.dt-slot').forEach(s => s.classList.toggle('active', parseInt(s.dataset.val) === selected));
                        }

                        function scrollActive() {
                            const a = slotC.querySelector('.dt-slot.active');
                            if (a) a.scrollIntoView({ block: 'center', behavior: 'smooth' });
                        }

                        function open() { dropdown.classList.add('open'); highlight(); setTimeout(scrollActive, 50); }
                        function close() { dropdown.classList.remove('open'); }

                        toggle.addEventListener('click', function (e) { e.stopPropagation(); dropdown.classList.contains('open') ? close() : open(); });
                        displayInput.addEventListener('click', function (e) { e.stopPropagation(); open(); });
                        document.addEventListener('click', function (e) { if (!wrapper.contains(e.target)) close(); });

                        sync(); highlight();
                    })();
                </script>
                <script
                    src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/intlTelInput.min.js"></script>
                <script>
                    const phoneInput = document.querySelector('#phoneInput');
                    if (phoneInput) {
                        const iti = window.intlTelInput(phoneInput, {
                            initialCountry: 'vn',
                            separateDialCode: true,
                            utilsScript: 'https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/utils.js',
                        });
                        document.getElementById('bookingForm').addEventListener('submit', function () {
                            // If user typed local VN number (0xxx...), keep as-is
                            // Otherwise send full international number
                            const raw = phoneInput.value.trim();
                            if (raw.startsWith('0')) return;
                            phoneInput.value = iti.getNumber();
                        });
                    }
                </script>

                <!-- chatbot widget include -->
                <jsp:include page="/chatbot.jsp" />
            </body>

            </html>