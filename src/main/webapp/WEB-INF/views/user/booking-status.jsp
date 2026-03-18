<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đặt bàn — Nhà hàng Hương Việt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/mobile.css">
    <style>
        html, body { height:100%; margin:0; }
        body { display:flex; flex-direction:column; min-height:100vh; }

        .history-hero { padding:140px 48px 40px; text-align:center; position:relative; }
        .history-hero::before { content:''; position:absolute; inset:0; background:radial-gradient(ellipse at 50% 0%,rgba(232,160,32,.08) 0%,transparent 60%); pointer-events:none; }
        .history-hero h1 { font-family:var(--font-serif); font-size:clamp(28px,4vw,44px); color:var(--text); margin-bottom:10px; }
        .history-hero h1 em { color:var(--primary); font-style:italic; }
        .history-hero p { font-size:15px; color:var(--text-muted); max-width:480px; margin:0 auto; }

        .history-section { max-width:800px; margin:0 auto; padding:0 24px 80px; flex:1; }

        /* Stats bar */
        .stats-bar { display:flex; gap:12px; margin-bottom:24px; flex-wrap:wrap; }
        .stat-chip { flex:1; min-width:120px; background:rgba(26,24,20,.8); border:1px solid var(--border); border-radius:12px; padding:16px; text-align:center; backdrop-filter:blur(12px); }
        .stat-chip .stat-num { font-size:24px; font-weight:800; color:var(--primary); }
        .stat-chip .stat-label { font-size:11px; color:var(--text-muted); text-transform:uppercase; letter-spacing:.06em; margin-top:4px; }

        /* Booking card */
        .booking-card { background:rgba(26,24,20,.8); border:1px solid var(--border); border-radius:16px; overflow:hidden; backdrop-filter:blur(12px); margin-bottom:16px; transition:border-color .2s; }
        .booking-card:hover { border-color:rgba(232,160,32,.3); }
        .booking-card-header { padding:16px 20px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .booking-card-header h3 { font-size:15px; color:var(--text); display:flex; align-items:center; gap:8px; }
        .booking-card-header h3 i { color:var(--primary); }
        .booking-card-body { padding:16px 20px; }
        .booking-card-info { display:flex; flex-wrap:wrap; gap:20px; }
        .booking-card-field { display:flex; align-items:center; gap:8px; font-size:13px; }
        .booking-card-field i { color:var(--primary); width:16px; text-align:center; }
        .booking-card-field .field-label { color:var(--text-muted); }
        .booking-card-field .field-value { color:var(--text); font-weight:600; }
        .booking-card-note { margin-top:12px; font-size:13px; color:var(--text-muted); padding:8px 12px; background:rgba(255,255,255,.03); border-radius:8px; border:1px solid var(--border); }
        .booking-card-note strong { color:var(--text); }
        .booking-card-actions { padding:12px 20px; border-top:1px solid var(--border); display:flex; gap:8px; flex-wrap:wrap; }
        .btn-card { padding:8px 16px; border:1px solid var(--border); border-radius:8px; color:var(--text); background:none; font-size:12px; font-weight:600; cursor:pointer; font-family:inherit; display:flex; align-items:center; gap:6px; transition:all .2s; text-decoration:none; }
        .btn-card:hover { border-color:var(--primary); color:var(--primary); }
        .btn-card.primary { background:var(--primary); color:#000; border-color:var(--primary); }
        .btn-card.primary:hover { background:#cfa730; }

        /* Cancel reason */
        .cancel-reason { font-size:12px; color:#f87171; margin-top:8px; padding:8px 12px; background:rgba(239,68,68,.06); border:1px solid rgba(239,68,68,.15); border-radius:8px; }
        .cancel-reason i { margin-right:4px; }

        /* Badge */
        .badge { padding:4px 12px; border-radius:99px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.04em; }
        .badge-pending { background:rgba(245,158,11,.15); color:#fbbf24; }
        .badge-confirmed { background:rgba(34,197,94,.15); color:#4ade80; }
        .badge-checked_in { background:rgba(59,130,246,.15); color:#60a5fa; }
        .badge-cancelled { background:rgba(239,68,68,.15); color:#f87171; }
        .badge-completed { background:rgba(99,102,241,.15); color:#a5b4fc; }
        .badge-no_show { background:rgba(156,163,175,.15); color:#9ca3af; }
        .badge-seated { background:rgba(16,185,129,.15); color:#34d399; }

        /* Detail view */
        .detail-card { background:rgba(26,24,20,.8); border:1px solid var(--border); border-radius:16px; overflow:hidden; backdrop-filter:blur(12px); }
        .detail-header { padding:20px 24px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; }
        .detail-header h3 { font-size:18px; color:var(--text); display:flex; align-items:center; gap:10px; }
        .detail-header h3 i { color:var(--primary); }
        .detail-body { padding:24px; }
        .status-banner { padding:16px 20px; border-radius:12px; margin-bottom:20px; display:flex; align-items:center; gap:12px; font-size:14px; }
        .status-banner i { font-size:20px; }
        .status-banner .s-title { font-weight:700; }
        .status-banner .s-desc { font-size:13px; opacity:.85; }
        .sb-pending { background:rgba(245,158,11,.1); border:1px solid rgba(245,158,11,.2); color:#fbbf24; }
        .sb-confirmed { background:rgba(34,197,94,.1); border:1px solid rgba(34,197,94,.2); color:#4ade80; }
        .sb-checked_in { background:rgba(59,130,246,.1); border:1px solid rgba(59,130,246,.2); color:#60a5fa; }
        .sb-cancelled { background:rgba(239,68,68,.1); border:1px solid rgba(239,68,68,.2); color:#f87171; }
        .sb-completed { background:rgba(99,102,241,.1); border:1px solid rgba(99,102,241,.2); color:#a5b4fc; }
        .sb-no_show { background:rgba(156,163,175,.1); border:1px solid rgba(156,163,175,.2); color:#9ca3af; }
        .sb-seated { background:rgba(16,185,129,.1); border:1px solid rgba(16,185,129,.2); color:#34d399; }
        .info-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:16px; margin-bottom:24px; }
        .info-item { background:rgba(255,255,255,.03); border:1px solid var(--border); border-radius:10px; padding:14px 16px; }
        .info-item .info-label { font-size:11px; color:var(--text-muted); text-transform:uppercase; letter-spacing:.06em; margin-bottom:4px; display:flex; align-items:center; gap:6px; }
        .info-item .info-value { font-size:15px; font-weight:600; color:var(--text); }
        .preorder-section h4 { font-size:14px; color:var(--text); margin-bottom:12px; display:flex; align-items:center; gap:8px; }
        .preorder-item { display:flex; align-items:center; justify-content:space-between; padding:10px 0; border-bottom:1px solid var(--border); font-size:13px; }
        .preorder-item:last-child { border-bottom:none; }
        .preorder-item .item-name { color:var(--text); font-weight:500; }
        .preorder-item .item-qty { color:var(--text-muted); }
        .preorder-item .item-price { color:var(--primary); font-weight:600; }
        .detail-actions { display:flex; gap:10px; flex-wrap:wrap; padding:16px 24px; border-top:1px solid var(--border); }

        /* Print styles */
        .btn-print { padding:10px 18px; border:1px solid var(--border); border-radius:10px; color:var(--text); background:none; font-size:13px; font-weight:600; cursor:pointer; font-family:inherit; display:flex; align-items:center; gap:6px; transition:all .25s; text-decoration:none; }
        .btn-print:hover { border-color:var(--primary); color:var(--primary); }

        @media print {
            body { background:#fff !important; color:#000 !important; }
            .navbar, .history-hero, .booking-card-actions, .detail-actions, footer, .stats-bar, .btn-print { display:none !important; }
            .history-section, .detail-card, .booking-card { max-width:100%; border:1px solid #ddd !important; background:#fff !important; }
            .info-item { background:#f9f9f9 !important; border:1px solid #ddd !important; }
            .info-item .info-label { color:#666 !important; }
            .info-item .info-value { color:#000 !important; }
            .detail-header h3 { color:#000 !important; }
            .badge { border:1px solid #999 !important; }
            .status-banner { border:1px solid #ddd !important; }
            .preorder-item { border-color:#ddd !important; }
            .preorder-item .item-name { color:#000 !important; }
            .preorder-item .item-price { color:#c87a00 !important; }
            * { color:#000 !important; }
            .badge-pending { background:#fff8e1 !important; color:#f59e0b !important; }
            .badge-confirmed { background:#e8f5e9 !important; color:#22c55e !important; }
            .badge-cancelled { background:#fce4ec !important; color:#ef4444 !important; }
            .badge-completed { background:#e8eaf6 !important; color:#6366f1 !important; }
        }

        /* Alerts */
        .alert-success { background:rgba(34,197,94,.08); border:1px solid rgba(34,197,94,.2); color:#4ade80; padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
        .alert-error { background:rgba(239,68,68,.08); border:1px solid rgba(239,68,68,.2); color:#f87171; padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px; }

        /* Cancel button */
        .btn-cancel { padding:8px 16px; border:1px solid rgba(239,68,68,.3); border-radius:8px; color:#f87171; background:rgba(239,68,68,.06); font-size:12px; font-weight:600; cursor:pointer; font-family:inherit; display:flex; align-items:center; gap:6px; transition:all .2s; text-decoration:none; }
        .btn-cancel:hover { background:rgba(239,68,68,.15); border-color:rgba(239,68,68,.5); }

        /* Cancel Modal */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.7); z-index:1000; align-items:center; justify-content:center; backdrop-filter:blur(4px); }
        .modal-overlay.active { display:flex; }
        .modal-box { background:#1a1814; border:1px solid rgba(232,160,32,.2); border-radius:16px; padding:28px; max-width:420px; width:90%; box-shadow:0 20px 60px rgba(0,0,0,.6); }
        .modal-box h3 { color:var(--text); font-size:17px; margin-bottom:8px; display:flex; align-items:center; gap:8px; }
        .modal-box h3 i { color:#f87171; }
        .modal-box p { color:var(--text-muted); font-size:13px; margin-bottom:16px; }
        .modal-box textarea { width:100%; background:rgba(255,255,255,.05); border:1px solid var(--border); border-radius:10px; padding:12px; color:var(--text); font-size:14px; font-family:inherit; resize:none; outline:none; box-sizing:border-box; min-height:80px; }
        .modal-box textarea:focus { border-color:var(--primary); }
        .modal-btns { display:flex; gap:10px; margin-top:16px; justify-content:flex-end; }
        .modal-btns .btn-modal { padding:10px 20px; border-radius:10px; font-size:13px; font-weight:600; cursor:pointer; font-family:inherit; border:none; transition:all .2s; }
        .modal-btns .btn-modal-cancel { background:rgba(255,255,255,.08); color:var(--text-muted); }
        .modal-btns .btn-modal-cancel:hover { background:rgba(255,255,255,.12); }
        .modal-btns .btn-modal-confirm { background:#ef4444; color:#fff; }
        .modal-btns .btn-modal-confirm:hover { background:#dc2626; }

        /* Empty state */
        .empty-state { text-align:center; padding:60px 24px; color:var(--text-muted); }
        .empty-state i { font-size:3rem; opacity:.3; margin-bottom:16px; display:block; }
        .empty-state h3 { font-size:16px; color:var(--text); margin-bottom:8px; }
        .empty-state p { font-size:14px; margin-bottom:20px; }
        .btn-empty { display:inline-flex; align-items:center; gap:8px; padding:12px 24px; background:var(--primary); color:#000; border-radius:10px; font-weight:700; font-size:14px; text-decoration:none; transition:background .2s; }
        .btn-empty:hover { background:#cfa730; }

        /* Back link */
        .back-link { display:inline-flex; align-items:center; gap:6px; color:var(--text-muted); font-size:13px; text-decoration:none; margin-bottom:16px; transition:color .2s; }
        .back-link:hover { color:var(--primary); }

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

        @media(max-width:640px){
            .history-hero { padding:120px 20px 32px; }
            .history-section { padding:0 16px 60px; }
            .booking-card-info { gap:12px; }
        }
    </style>
</head>
<body>

    <!-- ── USER NAVBAR ── -->
    <nav class="navbar" id="navbar" style="background:rgba(15,14,12,0.95); backdrop-filter:blur(12px);">
        <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div class="nav-logo-text">Hương Việt<span>Nhà hàng &amp; Quán nhậu</span></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/menu">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/user/booking/status" class="active">Lịch sử booking</a>
            <a href="${pageContext.request.contextPath}/user/pre-order">Đặt món trước</a>
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
                    <a href="${pageContext.request.contextPath}/user/booking/status" class="dd-item">
                        <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử đặt bàn
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

    <c:choose>
        <%-- ═══ DETAIL VIEW: Single Booking Found ═══ --%>
        <c:when test="${viewMode == 'detail' && not empty booking}">
            <section class="history-hero">
                <div class="section-label"><i class="fa-solid fa-ticket"></i> Chi tiết booking</div>
                <h1>Booking <em>${booking.bookingCode}</em></h1>
                <p>Thông tin chi tiết đặt bàn của bạn</p>
            </section>

            <div class="history-section">
                <a href="${pageContext.request.contextPath}/user/booking/status" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại lịch sử
                </a>

                <c:if test="${msg == 'confirmed'}">
                    <div class="alert-success"><i class="fa-solid fa-circle-check"></i> Đã xác nhận booking thành công!</div>
                </c:if>

                <div class="detail-card">
                    <div class="detail-header">
                        <h3><i class="fa-solid fa-ticket"></i> ${booking.bookingCode}</h3>
                        <span class="badge badge-${booking.status.toLowerCase()}">${booking.status}</span>
                    </div>
                    <div class="detail-body">
                        <!-- Status Banner -->
                        <c:choose>
                            <c:when test="${booking.status == 'PENDING'}">
                                <div class="status-banner sb-pending"><i class="fa-solid fa-clock"></i>
                                    <div><div class="s-title">Đang chờ xác nhận</div><div class="s-desc">Nhà hàng sẽ xác nhận booking của bạn sớm nhất có thể.</div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'CONFIRMED'}">
                                <div class="status-banner sb-confirmed"><i class="fa-solid fa-circle-check"></i>
                                    <div><div class="s-title">Đã xác nhận</div><div class="s-desc">Booking đã được xác nhận. Vui lòng đến đúng giờ!</div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'CHECKED_IN'}">
                                <div class="status-banner sb-checked_in"><i class="fa-solid fa-right-to-bracket"></i>
                                    <div><div class="s-title">Đã check-in</div><div class="s-desc">Chào mừng bạn! Chúc bạn có bữa tối vui vẻ.</div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'SEATED'}">
                                <div class="status-banner sb-seated"><i class="fa-solid fa-chair"></i>
                                    <div><div class="s-title">Đã ngồi bàn</div><div class="s-desc">Bạn đã được xếp bàn. Chúc ngon miệng!</div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'CANCELLED'}">
                                <div class="status-banner sb-cancelled"><i class="fa-solid fa-circle-xmark"></i>
                                    <div><div class="s-title">Đã hủy</div><div class="s-desc">
                                        <c:choose>
                                            <c:when test="${not empty booking.cancelReason}">Lý do: <strong>${booking.cancelReason}</strong></c:when>
                                            <c:otherwise>Booking đã bị hủy. Vui lòng đặt lại nếu cần.</c:otherwise>
                                        </c:choose>
                                    </div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'COMPLETED'}">
                                <div class="status-banner sb-completed"><i class="fa-solid fa-flag-checkered"></i>
                                    <div><div class="s-title">Hoàn thành</div><div class="s-desc">Cảm ơn bạn đã sử dụng dịch vụ! Hẹn gặp lại.</div></div>
                                </div>
                            </c:when>
                            <c:when test="${booking.status == 'NO_SHOW'}">
                                <div class="status-banner sb-no_show"><i class="fa-solid fa-user-xmark"></i>
                                    <div><div class="s-title">Không đến</div><div class="s-desc">Bạn đã không đến theo lịch hẹn.</div></div>
                                </div>
                            </c:when>
                        </c:choose>

                        <!-- Info Grid -->
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label"><i class="fa-solid fa-user"></i> Khách hàng</div>
                                <div class="info-value">${booking.customerName}</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label"><i class="fa-solid fa-phone"></i> Điện thoại</div>
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
                                <div class="info-label"><i class="fa-solid fa-sticky-note"></i> Ghi chú</div>
                                <div class="info-value" style="font-size:14px;font-weight:400">${booking.note}</div>
                            </div>
                        </c:if>

                        <!-- Pre-order Items -->
                        <c:if test="${not empty booking.preOrderItems}">
                            <div class="preorder-section">
                                <h4><i class="fa-solid fa-utensils" style="color:var(--primary)"></i> Món đã đặt trước</h4>
                                <c:forEach var="item" items="${booking.preOrderItems}">
                                    <div class="preorder-item">
                                        <span class="item-name">${item.product.productName}</span>
                                        <span class="item-qty">×${item.quantity}</span>
                                        <span class="item-price"><fmt:formatNumber value="${item.product.price * item.quantity}" pattern="#,###" />đ</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                    <!-- Actions -->
                    <div class="detail-actions">
                        <c:if test="${booking.status == 'CONFIRMED' || booking.status == 'PENDING'}">
                            <a href="${pageContext.request.contextPath}/user/pre-order?code=${booking.bookingCode}" class="btn-card primary">
                                <i class="fa-solid fa-utensils"></i> Đặt món trước
                            </a>
                        </c:if>
                        <button type="button" class="btn-print" onclick="window.print()">
                            <i class="fa-solid fa-print"></i> In phiếu booking
                        </button>
                        <a href="${pageContext.request.contextPath}/user/booking/create" class="btn-card">
                            <i class="fa-solid fa-plus"></i> Đặt bàn mới
                        </a>
                        <c:if test="${booking.status == 'PENDING' || booking.status == 'CONFIRMED'}">
                            <button type="button" class="btn-cancel" onclick="openCancelModal(${booking.id}, '${booking.bookingCode}')">
                                <i class="fa-solid fa-ban"></i> Hủy đặt bàn
                            </button>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:when>

        <%-- ═══ DETAIL VIEW: Booking NOT FOUND ═══ --%>
        <c:when test="${viewMode == 'detail' && empty booking}">
            <section class="history-hero">
                <div class="section-label"><i class="fa-solid fa-ticket"></i> Tra cứu booking</div>
                <h1>Không tìm thấy <em>booking</em></h1>
                <p>Mã đặt bàn không tồn tại hoặc đã bị xóa.</p>
            </section>
            <div class="history-section">
                <a href="${pageContext.request.contextPath}/user/booking/status" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại lịch sử
                </a>
                <div class="detail-card">
                    <div class="empty-state">
                        <i class="fa-solid fa-circle-exclamation" style="color:#f87171;opacity:0.6"></i>
                        <h3>Không tìm thấy booking</h3>
                        <p>Mã booking không hợp lệ hoặc không tồn tại trong hệ thống.<br>Vui lòng kiểm tra lại mã đặt bàn.</p>
                        <a href="${pageContext.request.contextPath}/user/booking/create" class="btn-empty">
                            <i class="fa-solid fa-plus"></i> Đặt bàn mới
                        </a>
                    </div>
                </div>
            </div>
        </c:when>

        <%-- ═══ HISTORY VIEW: All Bookings ═══ --%>
        <c:otherwise>
            <section class="history-hero">
                <div class="section-label"><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử đặt bàn</div>
                <h1>Booking của <em><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'bạn'}" /></em></h1>
                <p>Xem lại tất cả đặt bàn của bạn tại Nhà hàng Hương Việt.</p>
            </section>

            <div class="history-section">
                <c:if test="${not empty error}">
                    <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i> ${error}</div>
                </c:if>
                <c:if test="${msg == 'confirmed'}">
                    <div class="alert-success"><i class="fa-solid fa-circle-check"></i> Đã xác nhận booking thành công!</div>
                </c:if>
                <c:if test="${msg == 'cancelled'}">
                    <div class="alert-success"><i class="fa-solid fa-circle-check"></i> Đã hủy booking thành công.</div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty bookings && bookings.size() > 0}">
                        <!-- Stats -->
                        <div class="stats-bar">
                            <div class="stat-chip">
                                <div class="stat-num">${bookings.size()}</div>
                                <div class="stat-label">Tổng booking</div>
                            </div>
                            <div class="stat-chip">
                                <div class="stat-num" id="activeCount">0</div>
                                <div class="stat-label">Đang hoạt động</div>
                            </div>
                            <div class="stat-chip">
                                <div class="stat-num" id="completedCount">0</div>
                                <div class="stat-label">Đã hoàn thành</div>
                            </div>
                        </div>

                        <!-- Booking list -->
                        <c:forEach var="b" items="${bookings}">
                            <div class="booking-card" data-status="${b.status}">
                                <div class="booking-card-header">
                                    <h3><i class="fa-solid fa-ticket"></i> ${b.bookingCode}</h3>
                                    <span class="badge badge-${b.status.toLowerCase()}">${b.status}</span>
                                </div>
                                <div class="booking-card-body">
                                    <div class="booking-card-info">
                                        <div class="booking-card-field">
                                            <i class="fa-solid fa-calendar"></i>
                                            <span class="field-label">Ngày:</span>
                                            <span class="field-value">${b.bookingDate}</span>
                                        </div>
                                        <div class="booking-card-field">
                                            <i class="fa-solid fa-clock"></i>
                                            <span class="field-label">Giờ:</span>
                                            <span class="field-value">${b.bookingTime}</span>
                                        </div>
                                        <div class="booking-card-field">
                                            <i class="fa-solid fa-users"></i>
                                            <span class="field-label">Số khách:</span>
                                            <span class="field-value">${b.partySize} người</span>
                                        </div>
                                        <c:if test="${not empty b.tableName}">
                                            <div class="booking-card-field">
                                                <i class="fa-solid fa-chair"></i>
                                                <span class="field-label">Bàn:</span>
                                                <span class="field-value">${b.tableName}</span>
                                            </div>
                                        </c:if>
                                    </div>
                                    <c:if test="${b.status == 'CANCELLED' && not empty b.cancelReason}">
                                        <div class="cancel-reason"><i class="fa-solid fa-circle-xmark"></i> <strong>Lý do hủy:</strong> ${b.cancelReason}</div>
                                    </c:if>
                                </div>
                                <div class="booking-card-actions">
                                    <a href="${pageContext.request.contextPath}/user/booking/status?code=${b.bookingCode}" class="btn-card primary">
                                        <i class="fa-solid fa-eye"></i> Xem chi tiết
                                    </a>
                                    <c:if test="${b.status == 'CONFIRMED' || b.status == 'PENDING'}">
                                        <a href="${pageContext.request.contextPath}/user/pre-order?code=${b.bookingCode}" class="btn-card">
                                            <i class="fa-solid fa-utensils"></i> Đặt món trước
                                        </a>
                                        <button type="button" class="btn-cancel" onclick="openCancelModal(${b.id}, '${b.bookingCode}')">
                                            <i class="fa-solid fa-ban"></i> Hủy
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="detail-card">
                            <div class="empty-state">
                                <i class="fa-solid fa-calendar-xmark"></i>
                                <h3>Chưa có booking nào</h3>
                                <p>Bạn chưa đặt bàn lần nào. Hãy đặt bàn ngay để trải nghiệm nhà hàng!</p>
                                <a href="${pageContext.request.contextPath}/user/booking/create" class="btn-empty">
                                    <i class="fa-solid fa-plus"></i> Đặt bàn ngay
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- ── FOOTER ── -->
    <footer style="background:#0a0908; border-top:1px solid rgba(255,255,255,0.06); padding:24px 40px; display:flex; align-items:center; justify-content:space-between; font-size:13px; color:#9e9488;">
        <p>© 2026 Nhà hàng Hương Việt. 123 Nguyễn Huệ, Q.1, TP.HCM</p>
        <p>Hotline: <strong style="color:#e8a020;">1900 1234</strong> (8:00 – 23:00)</p>
    </footer>

    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 60));
        document.getElementById('navBurger')?.addEventListener('click', function() {
            const l = document.querySelector('.nav-links');
            l.style.display = l.style.display === 'flex' ? 'none' : 'flex';
        });
        document.addEventListener('click', function(e) {
            const dd = document.getElementById('userDropdown');
            if (dd && !dd.contains(e.target)) dd.classList.remove('open');
        });

        // Count stats
        const cards = document.querySelectorAll('.booking-card');
        let active = 0, completed = 0;
        cards.forEach(c => {
            const s = c.dataset.status;
            if (s === 'PENDING' || s === 'CONFIRMED' || s === 'CHECKED_IN' || s === 'SEATED') active++;
            if (s === 'COMPLETED') completed++;
        });
        const activeEl = document.getElementById('activeCount');
        const completedEl = document.getElementById('completedCount');
        if (activeEl) activeEl.textContent = active;
        if (completedEl) completedEl.textContent = completed;

        // Cancel modal
        function openCancelModal(bookingId, bookingCode) {
            document.getElementById('cancelBookingId').value = bookingId;
            document.getElementById('cancelBookingCode').textContent = bookingCode;
            document.getElementById('cancelReason').value = '';
            document.getElementById('cancelModal').classList.add('active');
        }
        function closeCancelModal() {
            document.getElementById('cancelModal').classList.remove('active');
        }
        document.getElementById('cancelModal')?.addEventListener('click', function(e) {
            if (e.target === this) closeCancelModal();
        });
    </script>

    <!-- Cancel Confirmation Modal -->
    <div class="modal-overlay" id="cancelModal">
        <div class="modal-box">
            <h3><i class="fa-solid fa-triangle-exclamation"></i> Hủy đặt bàn</h3>
            <p>Bạn có chắc muốn hủy booking <strong id="cancelBookingCode" style="color:var(--primary)"></strong>?</p>
            <form method="post" action="${pageContext.request.contextPath}/user/booking/status">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="bookingId" id="cancelBookingId">
                <textarea name="reason" id="cancelReason" placeholder="Lý do hủy (không bắt buộc)..."></textarea>
                <div class="modal-btns">
                    <button type="button" class="btn-modal btn-modal-cancel" onclick="closeCancelModal()">Quay lại</button>
                    <button type="submit" class="btn-modal btn-modal-confirm"><i class="fa-solid fa-ban"></i> Xác nhận hủy</button>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="/chatbot.jsp" />
</body>
</html>