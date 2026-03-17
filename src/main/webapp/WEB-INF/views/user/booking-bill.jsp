<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill Đặt Cọc — ${booking.bookingCode}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
        :root {
            --primary:#e8a020; --primary-dk:#c07c0a;
            --bg:#0f0e0c; --bg-card:#1a1814; --bg-lift:#232019;
            --text:#f0ebe3; --text-muted:#9e9488;
            --border:rgba(255,255,255,.09);
            --success:#34d399;
            --font:'Be Vietnam Pro',sans-serif;
        }
        body { font-family:var(--font); background:var(--bg); color:var(--text); min-height:100vh; padding:28px 16px 60px; }

        /* ── TOP BAR (hide on print) ── */
        .topbar { max-width:480px; margin:0 auto 16px; display:flex; align-items:center; justify-content:space-between; }
        .topbar-title { font-size:15px; font-weight:700; display:flex; align-items:center; gap:8px; }
        .topbar-title i { color:var(--primary); }
        .btn-group { display:flex; gap:8px; }
        .btn { display:inline-flex; align-items:center; gap:6px; padding:9px 16px; border-radius:9px;
               font-size:13px; font-weight:700; cursor:pointer; font-family:var(--font); border:none; transition:all .15s; }
        .btn-primary { background:var(--primary); color:#000; }
        .btn-primary:hover { background:var(--primary-dk); }
        .btn-ghost { background:rgba(255,255,255,.07); color:var(--text); border:1px solid var(--border); }
        .btn-ghost:hover { background:rgba(255,255,255,.12); }

        /* ── BILL CARD ── */
        .bill-wrap { max-width:480px; margin:0 auto; }
        .bill-card { background:var(--bg-card); border:1px solid var(--border); border-radius:16px; overflow:hidden; box-shadow:0 4px 24px rgba(0,0,0,.2); }

        /* Header gradient */
        .bill-header { background:linear-gradient(135deg,#1a1a2e,#16213e); padding:24px; text-align:center; }
        .bill-restaurant { font-size:20px; font-weight:900; letter-spacing:1px; color:#fff; margin-bottom:3px; }
        .bill-restaurant-sub { font-size:11px; color:rgba(255,255,255,.5); letter-spacing:2px; text-transform:uppercase; margin-bottom:16px; }
        .bill-type-badge { display:inline-flex; align-items:center; gap:6px; background:rgba(232,160,32,.15); border:1px solid rgba(232,160,32,.3); color:#e8a020; font-size:12px; font-weight:700; padding:5px 14px; border-radius:20px; }

        /* Ticket punch */
        .punch { display:flex; align-items:center; position:relative; overflow:hidden; }
        .punch::before,.punch::after { content:''; width:22px; height:22px; border-radius:50%; background:var(--bg); position:absolute; flex-shrink:0; }
        .punch::before { left:-11px; } .punch::after { right:-11px; }
        .punch-line { flex:1; border:none; border-top:2px dashed var(--border); margin:0 16px; }

        /* Body */
        .bill-body { padding:20px 24px; }

        /* Booking info */
        .info-grid { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:16px; }
        .info-item { background:var(--bg-lift); border-radius:8px; padding:10px 12px; }
        .info-label { font-size:10px; text-transform:uppercase; letter-spacing:1px; color:var(--text-muted); margin-bottom:3px; }
        .info-value { font-size:13px; font-weight:700; color:var(--text); }

        /* Items */
        .section-title { font-size:11px; text-transform:uppercase; letter-spacing:1px; color:var(--text-muted); margin-bottom:8px; display:flex; align-items:center; gap:6px; }
        .item-row { display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid var(--border); font-size:13px; }
        .item-row:last-child { border-bottom:none; }
        .item-name { color:var(--text); font-weight:500; }
        .item-qty { color:var(--text-muted); font-size:12px; margin-top:1px; }
        .item-price { font-weight:700; color:var(--text); white-space:nowrap; }

        /* Totals */
        .totals { background:var(--bg-lift); border-radius:10px; padding:14px; margin-top:14px; }
        .total-row { display:flex; justify-content:space-between; font-size:13px; margin-bottom:6px; }
        .total-row .lbl { color:var(--text-muted); }
        .total-row .val { color:var(--text); font-weight:600; }
        .total-div { border:none; border-top:1px solid var(--border); margin:10px 0; }
        .grand-row { display:flex; justify-content:space-between; font-size:16px; font-weight:900; color:var(--text); margin-bottom:10px; }

        /* Deposit section */
        .deposit-section { margin-top:14px; }
        .deposit-paid { display:flex; justify-content:space-between; font-size:13px; padding:8px 12px; background:rgba(52,211,153,.08); border:1px solid rgba(52,211,153,.2); border-radius:8px; margin-bottom:6px; }
        .deposit-paid .lbl { color:var(--success); font-weight:600; display:flex; align-items:center; gap:6px; }
        .deposit-paid .val { color:var(--success); font-weight:700; }
        .amount-due { display:flex; justify-content:space-between; padding:10px 12px; background:rgba(232,160,32,.1); border:1px solid rgba(232,160,32,.3); border-radius:8px; }
        .amount-due .lbl { color:var(--primary); font-size:14px; font-weight:700; }
        .amount-due .val { color:var(--primary); font-size:16px; font-weight:900; }

        /* Status */
        .status-ok { text-align:center; padding:16px; }
        .status-ok i { font-size:2rem; color:var(--success); display:block; margin-bottom:6px; }
        .status-text { font-size:13px; font-weight:700; color:var(--success); }
        .status-sub { font-size:12px; color:var(--text-muted); margin-top:3px; }

        /* Footer note */
        .bill-note { font-size:11px; color:var(--text-muted); text-align:center; padding:14px 20px 20px; border-top:1px solid var(--border); }

        /* ── PRINT ── */
        @media print {
            body { background:#fff !important; color:#000 !important; padding:0 !important; }
            .topbar,.btn-group { display:none !important; }
            .bill-card { box-shadow:none !important; border:none !important; border-radius:0 !important; background:#fff !important; }
            .bill-header { background:#f5f5f5 !important; }
            .bill-restaurant,.info-value,.grand-row,.item-name,.item-price { color:#000 !important; }
            .info-item,.totals,.deposit-paid,.amount-due { background:#f9f9f9 !important; border-color:#ccc !important; }
            .bill-body { padding:12px 16px !important; }
            --bg-card:#fff; --bg-lift:#f5f5f5; --text:#000; --text-muted:#555; --border:#ddd;
        }
    </style>
</head>
<body>

    <!-- Top bar (hidden on print) -->
    <div class="topbar">
        <div class="topbar-title"><i class="fa-solid fa-receipt"></i> Bill đặt cọc</div>
        <div class="btn-group">
            <button class="btn btn-primary" onclick="window.print()">
                <i class="fa-solid fa-print"></i> In bill
            </button>
            <a href="${pageContext.request.contextPath}/user/pre-order" class="btn btn-ghost">
                <i class="fa-solid fa-arrow-left"></i> Trang chủ
            </a>
        </div>
    </div>

    <div class="bill-wrap">
        <c:if test="${empty booking}">
            <div style="text-align:center;padding:60px 20px;color:var(--text-muted)">
                <i class="fa-solid fa-triangle-exclamation" style="font-size:2.5rem;color:#ef4444;display:block;margin-bottom:12px"></i>
                <p>Không tìm thấy booking.</p>
                <a href="${pageContext.request.contextPath}/user/pre-order" class="btn btn-ghost" style="margin-top:12px">Quay lại</a>
            </div>
        </c:if>

        <c:if test="${not empty booking}">
        <div class="bill-card">

            <!-- Header -->
            <div class="bill-header">
                <div class="bill-restaurant">HƯƠNG VIỆT</div>
                <div class="bill-restaurant-sub">Nhà hàng & Quán nhậu</div>
                <div class="bill-type-badge">
                    <i class="fa-solid fa-circle-check"></i> XÁC NHẬN ĐẶT CỌC
                </div>
            </div>

            <!-- Punch hole effect -->
            <div class="punch"><hr class="punch-line"></div>

            <!-- Body -->
            <div class="bill-body">

                <!-- Booking info -->
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Mã booking</div>
                        <div class="info-value" style="color:var(--primary)">${booking.bookingCode}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Trạng thái</div>
                        <div class="info-value" style="color:var(--success)">
                            <i class="fa-solid fa-circle-check" style="font-size:11px"></i>
                            Đã cọc
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Khách hàng</div>
                        <div class="info-value">${booking.customerName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">SĐT</div>
                        <div class="info-value">${booking.customerPhone}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Ngày đặt bàn</div>
                        <div class="info-value">${booking.bookingDate}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Giờ</div>
                        <div class="info-value">${booking.bookingTime}</div>
                    </div>
                </div>

                <!-- Pre-order items -->
                <c:if test="${not empty items}">
                <div class="section-title"><i class="fa-solid fa-utensils"></i> Món đặt trước</div>
                <c:forEach var="poi" items="${items}">
                    <c:if test="${not empty poi.product}">
                    <div class="item-row">
                        <div>
                            <div class="item-name">${poi.product.productName}</div>
                            <div class="item-qty"><fmt:formatNumber value="${poi.product.price}" pattern="#,###"/> đ × ${poi.quantity}</div>
                        </div>
                        <div class="item-price"><fmt:formatNumber value="${poi.product.price * poi.quantity}" pattern="#,###"/> đ</div>
                    </div>
                    </c:if>
                </c:forEach>
                </c:if>

                <!-- Totals -->
                <div class="totals">
                    <div class="total-row">
                        <span class="lbl">Tạm tính:</span>
                        <span class="val"><fmt:formatNumber value="${subtotal}" pattern="#,###"/> đ</span>
                    </div>
                    <c:if test="${vatRate > 0}">
                    <div class="total-row">
                        <span class="lbl">VAT (<fmt:formatNumber value="${vatRate}" pattern="#,##0.##"/>%):</span>
                        <span class="val"><fmt:formatNumber value="${vatAmount}" pattern="#,###"/> đ</span>
                    </div>
                    </c:if>
                    <c:if test="${serviceFeeRate > 0}">
                    <div class="total-row">
                        <span class="lbl">Phí dịch vụ (<fmt:formatNumber value="${serviceFeeRate}" pattern="#,##0.##"/>%):</span>
                        <span class="val"><fmt:formatNumber value="${serviceFeeAmount}" pattern="#,###"/> đ</span>
                    </div>
                    </c:if>
                    <hr class="total-div">
                    <div class="grand-row">
                        <span>Tổng dự kiến:</span>
                        <span><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> đ</span>
                    </div>
                </div>

                <!-- Deposit & Amount due -->
                <div class="deposit-section">
                    <div class="deposit-paid">
                        <span class="lbl"><i class="fa-solid fa-circle-check"></i> Đã đặt cọc:</span>
                        <span class="val">- <fmt:formatNumber value="${deposit}" pattern="#,###"/> đ</span>
                    </div>
                    <div class="amount-due">
                        <span class="lbl">Thanh toán khi đến:</span>
                        <span class="val"><fmt:formatNumber value="${amountDue}" pattern="#,###"/> đ</span>
                    </div>
                </div>

                <!-- Status -->
                <div class="status-ok">
                    <i class="fa-solid fa-circle-check"></i>
                    <div class="status-text">Đặt cọc đã được xác nhận!</div>
                    <div class="status-sub">Vui lòng mang bill này khi đến nhà hàng</div>
                </div>

            </div><!-- end bill-body -->

            <!-- Footer note -->
            <div class="bill-note">
                Nhà hàng Hương Việt &bull; 123 Nguyễn Huệ, Q.1, TP.HCM<br>
                Hotline: <strong>1900 1234</strong> &bull; Cảm ơn quý khách!
            </div>

        </div><!-- end bill-card -->
        </c:if>
    </div><!-- end bill-wrap -->

</body>
</html>
