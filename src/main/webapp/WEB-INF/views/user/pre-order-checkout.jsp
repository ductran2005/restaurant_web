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
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
        :root {
            --primary:#e8a020; --primary-dk:#c07c0a;
            --bg:#0f0e0c; --bg-card:#1a1814; --bg-lift:#232019;
            --text:#f0ebe3; --text-muted:#9e9488;
            --border:rgba(255,255,255,.09);
            --font:'Be Vietnam Pro',sans-serif;
        }
        body { font-family:var(--font); background:var(--bg); color:var(--text); min-height:100vh; }
        a { text-decoration:none; color:inherit; }

        /* ── NAV ── */
        .nav { background:rgba(15,14,12,.96); border-bottom:1px solid var(--border); backdrop-filter:blur(14px); position:sticky; top:0; z-index:100; padding:0 32px; height:60px; display:flex; align-items:center; justify-content:space-between; }
        .nav-logo { display:flex; align-items:center; gap:10px; font-weight:800; font-size:15px; }
        .nav-logo small { font-weight:400; font-size:11px; color:var(--text-muted); display:block; }
        .nav-logo-icon { width:34px; height:34px; background:var(--primary); border-radius:8px; display:flex; align-items:center; justify-content:center; color:#000; font-size:15px; }
        .nav-links { display:flex; gap:24px; }
        .nav-links a { font-size:14px; color:var(--text-muted); display:flex; align-items:center; gap:6px; font-weight:500; transition:color .2s; }
        .nav-links a:hover { color:var(--primary); }
        .nav-links a.active { background:var(--primary); color:#000 !important; padding:7px 14px; border-radius:8px; font-weight:700; }

        /* User Dropdown */
        .user-dropdown { position:relative; }
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

        /* ── PAGE ── */
        .page { max-width:960px; margin:0 auto; padding:28px 24px 80px; }
        .back-link { display:inline-flex; align-items:center; gap:6px; font-size:13px; color:var(--text-muted); font-weight:500; margin-bottom:14px; transition:color .2s; }
        .back-link:hover { color:var(--primary); }
        .page-title { font-size:22px; font-weight:800; display:flex; align-items:center; gap:10px; margin-bottom:4px; }
        .page-title i { color:var(--primary); }
        .page-sub { font-size:13px; color:var(--text-muted); margin-bottom:20px; }

        /* ── BOOKING BANNER ── */
        .booking-banner { background:var(--bg-card); border:1px solid var(--border); border-radius:12px; padding:14px 20px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; margin-bottom:24px; }
        .bb-left { display:flex; align-items:center; gap:14px; }
        .bb-icon { width:36px; height:36px; background:rgba(232,160,32,.1); border-radius:8px; display:flex; align-items:center; justify-content:center; color:var(--primary); flex-shrink:0; }
        .bb-code { font-size:15px; font-weight:700; color:var(--primary); }
        .bb-name { font-size:13px; font-weight:600; color:var(--text); }
        .bb-meta { font-size:12px; color:var(--text-muted); }
        .bb-badge { display:inline-flex; align-items:center; gap:6px; padding:5px 12px; border-radius:20px; font-size:12px; font-weight:700; background:rgba(34,197,94,.12); border:1px solid rgba(34,197,94,.2); color:#4ade80; }

        /* ── GRID LAYOUT ── */
        .grid { display:grid; grid-template-columns:1fr 300px; gap:20px; align-items:start; }
        @media(max-width:760px){ .grid{ grid-template-columns:1fr; } }

        /* ── CARD ── */
        .card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; overflow:hidden; margin-bottom:14px; }
        .card:last-child { margin-bottom:0; }
        .card-hd { padding:13px 18px; border-bottom:1px solid var(--border); font-size:13px; font-weight:700; color:var(--text); display:flex; align-items:center; gap:8px; }
        .card-hd i { color:var(--primary); font-size:13px; }

        /* ── ITEM ROWS ── */
        .item-row { display:flex; align-items:center; gap:12px; padding:13px 18px; border-bottom:1px solid var(--border); }
        .item-thumb { width:44px; height:44px; border-radius:8px; background:var(--bg-lift); display:flex; align-items:center; justify-content:center; color:var(--text-muted); font-size:18px; flex-shrink:0; }
        .item-info { flex:1; min-width:0; }
        .item-name { font-size:13px; font-weight:600; color:var(--text); margin-bottom:2px; }
        .item-unit { font-size:12px; color:var(--text-muted); }
        .item-total { font-size:13px; font-weight:700; color:var(--text); white-space:nowrap; }

        /* ── TOTALS ── */
        .totals { padding:14px 18px; }
        .total-row { display:flex; justify-content:space-between; font-size:13px; margin-bottom:7px; }
        .total-row .lbl { color:var(--text-muted); }
        .total-row .val { color:var(--text); font-weight:600; }
        .total-div { border:none; border-top:1px solid var(--border); margin:10px 0; }
        .grand-row { display:flex; justify-content:space-between; font-size:15px; font-weight:800; color:var(--text); }

        /* ── DEPOSIT ── */
        .deposit-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; padding:20px; text-align:center; margin-bottom:14px; }
        .deposit-icon { font-size:1.8rem; color:var(--primary); margin-bottom:8px; }
        .deposit-label { font-size:12px; color:var(--text-muted); margin-bottom:6px; }
        .deposit-amount { font-size:28px; font-weight:900; color:var(--primary); margin-bottom:4px; }
        .deposit-base { font-size:12px; color:var(--text-muted); }

        /* Payment methods */
        .method-wrap { padding:12px 14px; display:flex; flex-direction:column; gap:8px; }
        .method-opt { display:none; }
        .method-label { display:flex; align-items:center; gap:12px; padding:11px 14px; border:1.5px solid var(--border); border-radius:10px; cursor:pointer; transition:all .15s; background:var(--bg-lift); }
        .method-opt:checked+.method-label { border-color:var(--primary); background:rgba(232,160,32,.07); }
        .method-icon { width:34px; height:34px; border-radius:8px; display:flex; align-items:center; justify-content:center; flex-shrink:0; font-size:15px; }
        .method-icon.bank { background:rgba(99,102,241,.12); color:#a5b4fc; }
        .method-icon.momo { background:rgba(209,53,145,.12); color:#f0abdc; }
        .method-icon.zalo { background:rgba(0,120,255,.12); color:#60a5fa; }
        .m-name { font-size:13px; font-weight:700; color:var(--text); }
        .m-sub { font-size:11px; color:var(--text-muted); }
        .m-radio { width:18px; height:18px; border-radius:50%; border:2px solid var(--border); flex-shrink:0; margin-left:auto; display:flex; align-items:center; justify-content:center; transition:all .15s; }
        .method-opt:checked+.method-label .m-radio { border-color:var(--primary); background:var(--primary); box-shadow:0 0 0 3px rgba(232,160,32,.2); }
        .method-opt:checked+.method-label .m-radio::after { content:''; width:6px; height:6px; border-radius:50%; background:#000; }

        /* Payment info panel */
        .pay-info { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; margin-bottom:14px; overflow:hidden; display:none; }
        .pay-info.active { display:block; }
        .pay-info-hd { padding:12px 16px; border-bottom:1px solid var(--border); font-size:13px; font-weight:700; color:var(--text); display:flex; align-items:center; gap:8px; }
        .pay-info-hd i { color:var(--primary); font-size:12px; }
        .pay-info-body { padding:14px 16px; }
        .pi-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; font-size:13px; }
        .pi-key { color:var(--text-muted); }
        .pi-val { color:var(--text); font-weight:600; display:flex; align-items:center; gap:6px; }
        .pi-val.gold { color:var(--primary); }
        .copy-btn { background:none; border:none; color:var(--text-muted); cursor:pointer; font-size:12px; padding:2px 4px; border-radius:4px; transition:color .15s; }
        .copy-btn:hover { color:var(--primary); }
        .qr-box { margin-top:12px; border-radius:10px; background:#fff; padding:12px; text-align:center; }
        .qr-box img { width:100%; height:auto; display:block; border-radius:6px; }
        .qr-lbl { font-size:11px; color:var(--text-muted); margin-top:6px; text-align:center; }

        /* Confirm button */
        .btn-confirm { width:100%; padding:14px; background:rgba(255,255,255,.06); color:var(--text-muted); border:1px solid var(--border); border-radius:10px; font-size:14px; font-weight:700; font-family:var(--font); cursor:not-allowed; display:flex; align-items:center; justify-content:center; gap:8px; transition:all .2s; margin-bottom:14px; }
        .btn-confirm.ready { background:var(--primary); color:#000; border-color:var(--primary); cursor:pointer; }
        .btn-confirm.ready:hover { background:var(--primary-dk); }

        /* Notes */
        .notes-box { background:rgba(232,160,32,.07); border:1px solid rgba(232,160,32,.2); border-radius:10px; padding:12px 14px; font-size:12px; }
        .notes-hd { font-weight:700; color:var(--primary); display:flex; align-items:center; gap:6px; margin-bottom:8px; }
        .notes-box ul { padding-left:16px; }
        .notes-box ul li { color:var(--text-muted); margin-bottom:4px; line-height:1.5; }

        .empty-msg { padding:28px; text-align:center; color:var(--text-muted); font-size:13px; }
        .empty-msg i { font-size:2rem; display:block; margin-bottom:10px; opacity:.2; }

        footer { background:#000; color:var(--text-muted); text-align:center; padding:18px; font-size:13px; border-top:1px solid var(--border); }
        footer strong { color:var(--primary); }
    </style>
</head>
<body>

    <!-- NAV -->
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div>Hương Việt<small>NHÀ HÀNG &amp; QUÁN NHẬU</small></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/menu"><i class="fa-regular fa-book-open"></i> Thực đơn</a>
            <a href="${pageContext.request.contextPath}/user/booking/create"><i class="fa-regular fa-calendar"></i> Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/user/booking/status"><i class="fa-solid fa-magnifying-glass"></i> Tra cứu</a>
            <a href="${pageContext.request.contextPath}/user/pre-order" class="active"><i class="fa-solid fa-cart-shopping"></i> Đặt món trước</a>
        </div>
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
                <a href="${pageContext.request.contextPath}/user/pre-order" style="color:#fff;text-decoration:underline">Quay lại</a>
            </div>
        </c:if>

        <c:if test="${not empty booking}">

        <!-- Back -->
        <a href="${pageContext.request.contextPath}/user/pre-order?code=${booking.bookingCode}" class="back-link">
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
                        <c:if test="${not empty booking.partySize}"> &bull; ${booking.partySize} khách</c:if>
                    </div>
                </div>
            </div>
            <div class="bb-badge"><i class="fa-solid fa-circle-check"></i> Đã xác nhận</div>
        </div>

        <!-- 2-col grid -->
        <div class="grid">

            <!-- LEFT: Order detail -->
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
                                        <div class="item-thumb">
                                            <c:choose>
                                                <c:when test="${not empty poi.product.imageUrl}">
                                                    <img src="${poi.product.imageUrl}" alt="${poi.product.productName}" style="width:100%;height:100%;object-fit:cover;border-radius:inherit;">
                                                </c:when>
                                                <c:otherwise><i class="fa-solid fa-bowl-food"></i></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="item-info">
                                            <div class="item-name">${poi.product.productName}</div>
                                            <div class="item-unit">
                                                <fmt:formatNumber value="${poi.product.price}" pattern="#,###" /> đ
                                                &times; ${poi.quantity}
                                            </div>
                                        </div>
                                        <div class="item-total">
                                            <fmt:formatNumber value="${poi.product.price * poi.quantity}" pattern="#,###" /> đ
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                    <div class="totals">
                        <div class="total-row">
                            <span class="lbl">Tạm tính:</span>
                            <span class="val"><fmt:formatNumber value="${subtotal}" pattern="#,###" /> đ</span>
                        </div>
                        <div class="total-row">
                            <span class="lbl">VAT (10%):</span>
                            <span class="val"><fmt:formatNumber value="${vat}" pattern="#,###" /> đ</span>
                        </div>
                        <div class="total-row">
                            <span class="lbl">Phí dịch vụ (5%):</span>
                            <span class="val"><fmt:formatNumber value="${serviceFee}" pattern="#,###" /> đ</span>
                        </div>
                        <hr class="total-div">
                        <div class="grand-row">
                            <span>Tổng dự kiến:</span>
                            <span><fmt:formatNumber value="${grandTotal}" pattern="#,###" /> đ</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- RIGHT: Payment -->
            <div>
                <!-- Deposit amount -->
                <div class="deposit-card">
                    <div class="deposit-icon"><i class="fa-solid fa-circle-dollar-to-slot"></i></div>
                    <div class="deposit-label">Số tiền cọc (10%)</div>
                    <div class="deposit-amount"><fmt:formatNumber value="${deposit}" pattern="#,###" /> đ</div>
                    <div class="deposit-base">trên tổng <fmt:formatNumber value="${subtotal}" pattern="#,###" /> đ</div>
                </div>

                <c:choose>
                <%-- Already paid --%>
                <c:when test="${booking.depositStatus == 'PAID'}">
                    <div style="background:rgba(52,211,153,.08);border:1px solid rgba(52,211,153,.25);border-radius:14px;padding:24px;text-align:center;">
                        <i class="fa-solid fa-circle-check" style="font-size:2.5rem;color:#34d399;margin-bottom:10px;display:block"></i>
                        <div style="font-size:16px;font-weight:800;color:#34d399;margin-bottom:4px">Đã thanh toán cọc!</div>
                        <div style="font-size:13px;color:var(--text-muted)">Nhà hàng sẽ xác nhận booking của bạn sớm nhất.</div>
                    </div>
                </c:when>
                <c:otherwise>

                <c:if test="${sepayEnabled}">
                <!-- SePay QR Payment -->
                <div class="card" style="overflow:hidden">
                    <div class="card-hd"><i class="fa-solid fa-qrcode"></i> Thanh toán qua QR</div>
                    <div style="background:linear-gradient(145deg,#1a1a2e,#16213e);padding:24px;text-align:center;color:#fff;position:relative;">
                        <!-- Bank info -->
                        <div style="margin-bottom:14px">
                            <div style="font-size:17px;font-weight:700;background:linear-gradient(90deg,#818cf8,#a78bfa);-webkit-background-clip:text;-webkit-text-fill-color:transparent;">${sepayBankName}</div>
                            <div style="font-size:15px;font-weight:700;letter-spacing:2px;color:#e2e8f0;margin:4px 0">${sepayBankAccount}</div>
                            <div style="font-size:12px;color:rgba(255,255,255,.6)">${sepayAccountName}</div>
                        </div>
                        <!-- QR image -->
                        <div style="background:#fff;border-radius:12px;padding:10px;display:inline-block;margin:0 0 14px;box-shadow:0 8px 32px rgba(0,0,0,.3)">
                            <img src="https://qr.sepay.vn/img?acc=${sepayBankAccount}&bank=${sepayBankName}&amount=${deposit}&des=${booking.bookingCode}%20COC"
                                 alt="QR Thanh toán" style="width:200px;height:200px;object-fit:contain;display:block">
                        </div>
                        <!-- Transfer content -->
                        <div style="background:rgba(255,255,255,.08);border:1px dashed rgba(255,255,255,.2);border-radius:10px;padding:12px;margin-bottom:10px">
                            <div style="font-size:10px;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,.5);margin-bottom:5px">Nội dung chuyển khoản</div>
                            <div style="font-size:18px;font-weight:800;color:#fbbf24;letter-spacing:2px">
                                ${booking.bookingCode} COC
                                <button type="button" onclick="cp('${booking.bookingCode} COC')" style="background:none;border:none;cursor:pointer;color:#fbbf24;font-size:13px;margin-left:6px;vertical-align:middle">
                                    <i class="fa-solid fa-copy"></i>
                                </button>
                            </div>
                        </div>
                        <!-- Amount -->
                        <div style="background:linear-gradient(135deg,rgba(99,102,241,.3),rgba(139,92,246,.3));border-radius:10px;padding:12px">
                            <div style="font-size:10px;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,.6);margin-bottom:3px">Số tiền</div>
                            <div style="font-size:24px;font-weight:800;color:#34d399"><fmt:formatNumber value="${deposit}" pattern="#,###" /> đ</div>
                        </div>
                        <!-- Polling status -->
                        <div id="statusChecking" style="display:flex;align-items:center;justify-content:center;gap:10px;margin-top:14px;padding:11px;background:rgba(251,191,36,.1);border-radius:10px;color:#fbbf24;font-size:13px;font-weight:600">
                            <div style="width:16px;height:16px;border:2px solid rgba(251,191,36,.3);border-top-color:#fbbf24;border-radius:50%;animation:spin 1s linear infinite;flex-shrink:0"></div>
                            Đang chờ thanh toán...
                        </div>
                        <div id="paymentSuccessBanner" style="display:none;margin-top:14px;background:linear-gradient(135deg,rgba(52,211,153,.15),rgba(16,185,129,.15));border:1px solid rgba(52,211,153,.3);border-radius:12px;padding:20px;text-align:center">
                            <i class="fa-solid fa-circle-check" style="font-size:2.5rem;color:#34d399;display:block;margin-bottom:8px"></i>
                            <div style="color:#34d399;font-size:17px;font-weight:800;margin-bottom:4px">Thanh toán thành công!</div>
                            <div style="color:rgba(255,255,255,.6);font-size:13px;margin-bottom:14px">Giao dịch đã được xác nhận tự động</div>
                            <a href="${pageContext.request.contextPath}/user/booking/status" style="display:inline-flex;align-items:center;gap:8px;padding:10px 20px;background:#34d399;color:#000;border-radius:10px;font-weight:700;font-size:13px;text-decoration:none">
                                <i class="fa-solid fa-arrow-left"></i> Xem lịch sử booking
                            </a>
                        </div>
                    </div>
                </div>
                </c:if>

                <c:if test="${!sepayEnabled}">
                <!-- Fallback: manual payment info -->
                <div class="card">
                    <div class="card-hd"><i class="fa-solid fa-building-columns"></i> Thông tin chuyển khoản</div>
                    <form id="payForm" method="post" action="${pageContext.request.contextPath}/user/pre-order/checkout">
                        <input type="hidden" name="bookingCode" value="${booking.bookingCode}">
                        <input type="hidden" name="amount" value="${deposit}">
                        <input type="hidden" name="method" value="BANK_TRANSFER">
                        <div class="pay-info-body" style="padding:16px">
                            <div class="pi-row"><span class="pi-key">Ngân hàng</span><span class="pi-val">Vietcombank</span></div>
                            <div class="pi-row"><span class="pi-key">Số tài khoản</span><span class="pi-val gold">1234567890</span></div>
                            <div class="pi-row"><span class="pi-key">Nội dung</span><span class="pi-val gold">${booking.bookingCode} COC</span></div>
                            <div class="pi-row"><span class="pi-key">Số tiền</span><span class="pi-val gold"><fmt:formatNumber value="${deposit}" pattern="#,###" /> đ</span></div>
                        </div>
                        <div style="padding:0 16px 16px">
                            <button type="submit" class="btn-confirm ready">
                                <i class="fa-solid fa-circle-check"></i> Xác nhận đã chuyển khoản
                            </button>
                        </div>
                    </form>
                </div>
                </c:if>

                </c:otherwise>
                </c:choose>

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
        // Spin animation for polling spinner
        const styleEl = document.createElement('style');
        styleEl.textContent = '@keyframes spin { to { transform: rotate(360deg); } }';
        document.head.appendChild(styleEl);

        function cp(txt) {
            navigator.clipboard.writeText(txt).then(() => {
                const el = event.currentTarget;
                const orig = el.innerHTML;
                el.innerHTML = '<i class="fa-solid fa-check" style="color:#4ade80"></i>';
                setTimeout(() => el.innerHTML = orig, 1500);
            });
        }

        // Close dropdown on outside click
        document.addEventListener('click', function(e) {
            const dd = document.getElementById('userDropdown');
            if (dd && !dd.contains(e.target)) dd.classList.remove('open');
        });

        // SePay deposit polling
        const sepayEnabled = ${sepayEnabled != null ? sepayEnabled : false};
        const bookingCode = '${booking.bookingCode}';
        const ctx = '${pageContext.request.contextPath}';

        if (sepayEnabled && bookingCode && '${booking.depositStatus}' !== 'PAID') {
            let pollingInterval = setInterval(function() {
                fetch(ctx + '/api/deposit/status?code=' + bookingCode)
                    .then(r => r.json())
                    .then(data => {
                        if (data.status === 'PAID') {
                            clearInterval(pollingInterval);
                            document.getElementById('statusChecking').style.display = 'none';
                            document.getElementById('paymentSuccessBanner').style.display = 'block';
                            try {
                                const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                                const osc = audioCtx.createOscillator();
                                const gain = audioCtx.createGain();
                                osc.connect(gain); gain.connect(audioCtx.destination);
                                osc.frequency.setValueAtTime(800, audioCtx.currentTime);
                                osc.frequency.setValueAtTime(1200, audioCtx.currentTime + 0.1);
                                gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
                                gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.5);
                                osc.start(audioCtx.currentTime); osc.stop(audioCtx.currentTime + 0.5);
                            } catch(e) {}
                        }
                    })
                    .catch(err => console.error('Polling error:', err));
            }, 3000);
            window.addEventListener('beforeunload', () => clearInterval(pollingInterval));
        }
    </script>
</body>
</html>
