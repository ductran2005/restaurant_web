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
                <!-- intl-tel-input styles -->
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/css/intlTelInput.css">
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
                        <a href="${pageContext.request.contextPath}/booking" class="active">Đặt bàn</a>
                        <a href="${pageContext.request.contextPath}/booking/status">Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/pre-order">Đặt món trước</a>
                    </div>
                    <div class="nav-actions">
                        <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
                        <a href="${pageContext.request.contextPath}/booking" class="btn-book">
                            <i class="fa-solid fa-calendar-check"></i> Đặt bàn
                        </a>
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
                                    <a href="${pageContext.request.contextPath}/booking/status?code=${bookingCode}"
                                        class="btn-outline-light">
                                        <i class="fa-solid fa-search"></i> Xem trạng thái
                                    </a>
                                    <a href="${pageContext.request.contextPath}/pre-order?code=${bookingCode}"
                                        class="btn-outline-light">
                                        <i class="fa-solid fa-utensils"></i> Đặt món trước
                                    </a>
                                    <a href="${pageContext.request.contextPath}/booking"
                                        class="btn-outline-light">
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

                                <form method="post" action="${pageContext.request.contextPath}/booking"
                                    id="bookingForm">
                                    <!-- Họ tên + SĐT -->
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">Họ và tên <span class="required">*</span></label>
                                            <input type="text" name="customerName"
                                                class="form-control ${not empty errors.customerName ? 'error' : ''}"
                                                value="${not empty param.customerName ? param.customerName : customerName}" placeholder="Nguyễn Văn A" required>
                                            <c:if test="${not empty errors.customerName}">
                                                <div class="form-error">${errors.customerName}</div>
                                            </c:if>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">Số điện thoại <span
                                                    class="required">*</span></label>
                                            <input type="tel" id="phoneInput" name="customerPhone"
                                                class="form-control ${not empty errors.customerPhone ? 'error' : ''}"
                                                value="${not empty param.customerPhone ? param.customerPhone : customerPhone}" placeholder="0901234567"
                                                pattern="\+[1-9][0-9]{7,14}"
                                                title="Nhập số theo định dạng quốc tế, ví dụ +84901234567" required>
                                            <c:if test="${not empty errors.customerPhone}">
                                                <div class="form-error">${errors.customerPhone}</div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Ngày + Giờ -->
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label class="form-label">Ngày <span class="required">*</span></label>
                                            <input type="date" name="bookingDate"
                                                class="form-control ${not empty errors.bookingDate ? 'error' : ''}"
                                                value="${not empty param.bookingDate ? param.bookingDate : bookingDate}" required>
                                            <c:if test="${not empty errors.bookingDate}">
                                                <div class="form-error">${errors.bookingDate}</div>
                                            </c:if>
                                        </div>
                                        <div class="form-group">
                                            <label class="form-label">Giờ <span class="required">*</span></label>
                                            <input type="time" name="bookingTime"
                                                class="form-control ${not empty errors.bookingTime ? 'error' : ''}"
                                                value="${param.bookingTime}" required>
                                            <c:if test="${not empty errors.bookingTime}">
                                                <div class="form-error">${errors.bookingTime}</div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Số người -->
                                    <div class="form-group">
                                        <label class="form-label">Số lượng khách <span class="required">*</span></label>
                                        <select name="partySize" class="form-control" required>
                                            <option value="">-- Chọn số khách --</option>
                                            <c:forEach begin="1" end="20" var="i">
                                                <option value="${i}" ${param.partySize==i ? 'selected' : '' }>${i} người
                                                </option>
                                            </c:forEach>
                                        </select>
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
                <footer class="footer">
                    <div class="footer-grid">
                        <div class="footer-brand">
                            <div class="footer-logo">
                                <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                                <div class="footer-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                            </div>
                            <p class="footer-desc">Điểm hẹn của hương vị Việt Nam đích thực.</p>
                        </div>
                        <div class="footer-col">
                            <h4>Khám phá</h4>
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/menu">Thực đơn</a></li>
                                <li><a href="${pageContext.request.contextPath}/booking">Đặt bàn</a></li>
                                <li><a href="${pageContext.request.contextPath}/booking/status">Tra cứu booking</a></li>
                            </ul>
                        </div>
                        <div class="footer-col">
                            <h4>Liên hệ</h4>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-solid fa-phone"></i></div>
                                <div class="footer-contact-text"><strong>Hotline</strong>1900 1234</div>
                            </div>
                        </div>
                    </div>
                    <div class="footer-bottom">
                        <p>© 2026 Nhà hàng Hương Việt.</p>
                    </div>
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

                    // Copy booking code
                    function copyCode() {
                        const code = document.getElementById('bookingCode').textContent;
                        navigator.clipboard.writeText(code).then(() => {
                            const btn = document.querySelector('.btn-copy');
                            btn.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
                            setTimeout(() => btn.innerHTML = '<i class="fa-solid fa-copy"></i> Copy', 2000);
                        });
                    }

                    // Set default date to tomorrow
                    const dateInput = document.querySelector('input[name="bookingDate"]');
                    if (dateInput && !dateInput.value) {
                        const tomorrow = new Date();
                        tomorrow.setDate(tomorrow.getDate() + 1);
                        dateInput.value = tomorrow.toISOString().split('T')[0];
                        dateInput.min = new Date().toISOString().split('T')[0];
                    }
                <!-- intl-tel-input script -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/intlTelInput.min.js"></script>
        <script>
            const phoneInput = document.querySelector('#phoneInput');
            if (phoneInput) {
                const iti = window.intlTelInput(phoneInput, {
                    initialCountry: 'auto',
                    geoIpLookup: function(callback) {
                        fetch('https://ipapi.co/json')
                            .then(res => res.json())
                            .then(data => callback(data.country_code))
                            .catch(() => callback('us'));
                    },
                    utilsScript: 'https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/18.2.1/js/utils.js',
                });
                // on submit ensure E.164 value
                const form = document.getElementById('bookingForm');
                form.addEventListener('submit', () => {
                    phoneInput.value = iti.getNumber();
                });
            }
        </script>
            </body>

            </html>