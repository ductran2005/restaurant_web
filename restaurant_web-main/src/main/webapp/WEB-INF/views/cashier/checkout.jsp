<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="checkout" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thanh toán — Thu ngân</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <style>
                    /* ===== QR Payment Styles ===== */
                    .payment-methods {
                        display: flex;
                        gap: 10px;
                        margin-bottom: 20px;
                    }

                    .method-btn {
                        flex: 1;
                        padding: 14px 12px;
                        border: 2px solid var(--border);
                        border-radius: 12px;
                        background: var(--card);
                        cursor: pointer;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 8px;
                        transition: all 0.3s ease;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                    }

                    .method-btn i {
                        font-size: 1.5rem;
                    }

                    .method-btn:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                    }

                    .method-btn.active {
                        border-color: var(--primary);
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.08), rgba(99, 102, 241, 0.15));
                        color: var(--primary);
                        box-shadow: 0 4px 16px rgba(99, 102, 241, 0.2);
                    }

                    .method-btn.active i {
                        color: var(--primary);
                    }

                    /* QR Container */
                    .qr-payment-container {
                        display: none;
                        animation: fadeInUp 0.4s ease;
                    }

                    .qr-payment-container.show {
                        display: block;
                    }

                    @keyframes fadeInUp {
                        from {
                            opacity: 0;
                            transform: translateY(20px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .qr-card {
                        background: linear-gradient(145deg, #1a1a2e, #16213e);
                        border-radius: 16px;
                        padding: 28px 24px;
                        text-align: center;
                        color: #fff;
                        position: relative;
                        overflow: hidden;
                    }

                    .qr-card::before {
                        content: '';
                        position: absolute;
                        top: -50%;
                        left: -50%;
                        width: 200%;
                        height: 200%;
                        background: radial-gradient(circle at 30% 50%, rgba(99, 102, 241, 0.15), transparent 50%);
                        pointer-events: none;
                    }

                    .qr-card .bank-info {
                        margin-bottom: 16px;
                        position: relative;
                        z-index: 1;
                    }

                    .qr-card .bank-name {
                        font-size: 18px;
                        font-weight: 700;
                        background: linear-gradient(90deg, #818cf8, #a78bfa);
                        -webkit-background-clip: text;
                        -webkit-text-fill-color: transparent;
                        margin-bottom: 4px;
                    }

                    .qr-card .account-info {
                        font-size: 13px;
                        color: rgba(255, 255, 255, 0.6);
                    }

                    .qr-card .account-number {
                        font-size: 16px;
                        font-weight: 700;
                        letter-spacing: 2px;
                        color: #e2e8f0;
                        margin: 4px 0;
                    }

                    .qr-image-wrapper {
                        background: #fff;
                        border-radius: 12px;
                        padding: 12px;
                        display: inline-block;
                        margin: 16px 0;
                        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
                        position: relative;
                        z-index: 1;
                    }

                    .qr-image-wrapper img {
                        width: 220px;
                        height: 220px;
                        object-fit: contain;
                    }

                    .transfer-content-box {
                        background: rgba(255, 255, 255, 0.08);
                        border: 1px dashed rgba(255, 255, 255, 0.2);
                        border-radius: 10px;
                        padding: 14px;
                        margin: 16px 0 8px;
                        position: relative;
                        z-index: 1;
                    }

                    .transfer-content-label {
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: rgba(255, 255, 255, 0.5);
                        margin-bottom: 6px;
                    }

                    .transfer-content-value {
                        font-size: 20px;
                        font-weight: 800;
                        color: #fbbf24;
                        letter-spacing: 3px;
                    }

                    .transfer-amount-box {
                        background: linear-gradient(135deg, rgba(99, 102, 241, 0.3), rgba(139, 92, 246, 0.3));
                        border-radius: 10px;
                        padding: 14px;
                        margin-top: 12px;
                        position: relative;
                        z-index: 1;
                    }

                    .transfer-amount-label {
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: rgba(255, 255, 255, 0.6);
                        margin-bottom: 4px;
                    }

                    .transfer-amount-value {
                        font-size: 26px;
                        font-weight: 800;
                        color: #34d399;
                    }

                    /* Status polling */
                    .payment-status-checking {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 10px;
                        margin-top: 16px;
                        padding: 12px;
                        background: rgba(251, 191, 36, 0.1);
                        border-radius: 10px;
                        color: #fbbf24;
                        font-size: 13px;
                        font-weight: 600;
                        position: relative;
                        z-index: 1;
                    }

                    .payment-status-checking .spinner {
                        width: 18px;
                        height: 18px;
                        border: 2px solid rgba(251, 191, 36, 0.3);
                        border-top-color: #fbbf24;
                        border-radius: 50%;
                        animation: spin 1s linear infinite;
                    }

                    @keyframes spin {
                        to {
                            transform: rotate(360deg);
                        }
                    }

                    .payment-success-banner {
                        display: none;
                        animation: fadeInUp 0.5s ease;
                        background: linear-gradient(135deg, rgba(52, 211, 153, 0.15), rgba(16, 185, 129, 0.15));
                        border: 1px solid rgba(52, 211, 153, 0.3);
                        border-radius: 12px;
                        padding: 24px;
                        text-align: center;
                        margin-top: 16px;
                    }

                    .payment-success-banner.show {
                        display: block;
                    }

                    .payment-success-banner i {
                        font-size: 3rem;
                        color: #34d399;
                        margin-bottom: 8px;
                    }

                    .payment-success-banner h3 {
                        color: #34d399;
                        font-size: 18px;
                        margin-bottom: 4px;
                    }

                    .payment-success-banner p {
                        color: var(--text-muted);
                        font-size: 13px;
                    }

                    /* Traditional Payment */
                    .traditional-payment {
                        display: none;
                        animation: fadeInUp 0.3s ease;
                    }

                    .traditional-payment.show {
                        display: block;
                    }

                    /* Money breakdown */
                    .money-breakdown {
                        margin-bottom: 16px;
                    }

                    .breakdown-row {
                        display: flex;
                        justify-content: space-between;
                        padding: 8px 0;
                        font-size: 14px;
                        color: var(--text-muted);
                    }

                    .breakdown-row.total {
                        border-top: 2px solid var(--border);
                        padding-top: 12px;
                        margin-top: 8px;
                        font-size: 16px;
                        font-weight: 700;
                        color: var(--text);
                    }

                    /* Responsive */
                    @media (max-width: 768px) {
                        .payment-grid {
                            grid-template-columns: 1fr !important;
                        }

                        .payment-methods {
                            flex-wrap: wrap;
                        }

                        .method-btn {
                            min-width: calc(50% - 5px);
                        }
                    }
                </style>
            </head>

            <body>
                <div class="shell">
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="main">
                            <header class="topbar">
                                <button class="burger" onclick="openSidebar()"><i class="fa-solid fa-bars"></i></button>
                                <h1 class="topbar-title"><i class="fa-solid fa-cash-register"></i> Thanh toán —
                                    ${order.table.tableName}</h1>
                                <div class="topbar-right">
                                    <a href="${ctx}/cashier" class="btn btn-ghost btn-sm"><i
                                            class="fa-solid fa-arrow-left"></i> Quay lại</a>
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <div class="payment-grid"
                                    style="display:grid;grid-template-columns:1fr 1fr;gap:20px;max-width:1000px">
                                    <!-- Order items -->
                                    <div class="table-card">
                                        <div class="table-card-header">
                                            <span style="font-weight:700"><i class="fa-solid fa-utensils"></i> Danh sách
                                                món — Order #${order.id}</span>
                                        </div>
                                        <table class="admin-table">
                                            <thead>
                                                <tr>
                                                    <th>Món</th>
                                                    <th style="text-align:right">SL</th>
                                                    <th style="text-align:right">Giá</th>
                                                    <th style="text-align:right">T.Tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="d" items="${order.orderDetails}">
                                                    <c:if test="${d.itemStatus == 'ORDERED'}">
                                                        <tr>
                                                            <td style="font-weight:600">
                                                                <c:out value="${d.product.productName}" />
                                                            </td>
                                                            <td style="text-align:right">${d.quantity}</td>
                                                            <td style="text-align:right;color:var(--text-muted)">
                                                                <fmt:formatNumber value="${d.unitPrice}"
                                                                    pattern="#,###" />
                                                            </td>
                                                            <td style="text-align:right;font-weight:700">
                                                                <fmt:formatNumber value="${d.lineTotal}"
                                                                    pattern="#,###" />
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Payment panel -->
                                    <div class="table-card" style="padding:24px">
                                        <h3
                                            style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                            <i class="fa-solid fa-file-invoice-dollar" style="color:var(--primary)"></i>
                                            Thanh toán
                                        </h3>

                                        <!-- Money Breakdown -->
                                        <div class="money-breakdown">
                                            <div class="breakdown-row">
                                                <span>Tạm tính:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.subtotal}" pattern="#,###" /> đ
                                                </span>
                                            </div>
                                            <div class="breakdown-row">
                                                <span>Giảm giá:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.discountAmount}" pattern="#,###" />
                                                    đ
                                                </span>
                                            </div>
                                            <div class="breakdown-row">
                                                <span>Tổng cộng:</span>
                                                <span>
                                                    <fmt:formatNumber value="${order.totalAmount}" pattern="#,###" /> đ
                                                </span>
                                            </div>
                                            <c:if test="${depositAmount != null && depositAmount > 0}">
                                                <div class="breakdown-row" style="color: var(--success);">
                                                    <span><i class="fa-solid fa-circle-check"></i> Tiền đã cọc:</span>
                                                    <span>
                                                        - <fmt:formatNumber value="${depositAmount}" pattern="#,###" /> đ
                                                    </span>
                                                </div>
                                            </c:if>
                                            <div class="breakdown-row total">
                                                <span>Cần thanh toán:</span>
                                                <span id="totalAmountDisplay">
                                                    <fmt:formatNumber value="${finalAmountToPay}" pattern="#,###" /> đ
                                                </span>
                                            </div>
                                        </div>

                                        <c:if test="${order.status != 'PAID'}">
                                            <!-- Payment Method Selection -->
                                            <div class="payment-methods">
                                                <div class="method-btn" data-method="CASH" onclick="selectMethod(this)">
                                                    <i class="fa-solid fa-money-bill-wave"></i>
                                                    Tiền mặt
                                                </div>
                                                <div class="method-btn" data-method="CARD" onclick="selectMethod(this)">
                                                    <i class="fa-solid fa-credit-card"></i>
                                                    Thẻ
                                                </div>
                                                <c:if test="${sepayEnabled}">
                                                    <div class="method-btn" data-method="TRANSFER"
                                                        onclick="selectMethod(this)">
                                                        <i class="fa-solid fa-qrcode"></i>
                                                        QR Code
                                                    </div>
                                                </c:if>
                                                <c:if test="${!sepayEnabled}">
                                                    <div class="method-btn" data-method="TRANSFER"
                                                        onclick="selectMethod(this)">
                                                        <i class="fa-solid fa-building-columns"></i>
                                                        Chuyển khoản
                                                    </div>
                                                </c:if>
                                            </div>

                                            <!-- Traditional pay (CASH/CARD/TRANSFER without SePay) -->
                                            <div class="traditional-payment" id="traditionalPayment">
                                                <form method="post" id="payForm">
                                                    <input type="hidden" name="action" value="pay">
                                                    <input type="hidden" name="orderId" value="${order.id}">
                                                    <input type="hidden" name="paymentMethod" id="paymentMethodInput"
                                                        value="">
                                                    <button type="submit" class="btn btn-primary" id="payBtn"
                                                        style="width:100%;padding:14px;font-size:14px;justify-content:center;border-radius:12px">
                                                        <i class="fa-solid fa-check-circle"></i> Xác nhận thanh toán
                                                    </button>
                                                </form>
                                            </div>

                                            <!-- QR Code Payment (SePay) -->
                                            <c:if test="${sepayEnabled}">
                                                <div class="qr-payment-container" id="qrPaymentContainer">
                                                    <div class="qr-card">
                                                        <div class="bank-info">
                                                            <div class="bank-name">${sepayBankName}</div>
                                                            <div class="account-number">${sepayBankAccount}</div>
                                                            <div class="account-info">${sepayAccountName}</div>
                                                        </div>

                                                        <div class="qr-image-wrapper">
                                                            <img id="qrImage"
                                                                src="https://qr.sepay.vn/img?acc=${sepayBankAccount}&bank=${sepayBankName}&amount=${finalAmountToPay.longValue()}&des=${sepayContentPrefix}${order.id}"
                                                                alt="QR Thanh toán">
                                                        </div>

                                                        <div class="transfer-content-box">
                                                            <div class="transfer-content-label">Nội dung chuyển khoản
                                                            </div>
                                                            <div class="transfer-content-value">
                                                                ${sepayContentPrefix}${order.id}</div>
                                                        </div>

                                                        <div class="transfer-amount-box">
                                                            <div class="transfer-amount-label">Số tiền</div>
                                                            <div class="transfer-amount-value">
                                                                <fmt:formatNumber value="${finalAmountToPay}"
                                                                    pattern="#,###" /> đ
                                                            </div>
                                                        </div>

                                                        <div class="payment-status-checking" id="statusChecking">
                                                            <div class="spinner"></div>
                                                            Đang chờ thanh toán...
                                                        </div>
                                                    </div>

                                                    <div class="payment-success-banner" id="paymentSuccessBanner">
                                                        <i class="fa-solid fa-circle-check"></i>
                                                        <h3>Thanh toán thành công!</h3>
                                                        <p>Giao dịch đã được xác nhận tự động</p>
                                                        <a href="${ctx}/cashier" class="btn btn-primary"
                                                            style="margin-top:12px;border-radius:10px">
                                                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                                                        </a>
                                                    </div>

                                                    <!-- Fallback: Manual confirm for TRANSFER -->
                                                    <div style="margin-top:12px;text-align:center">
                                                        <form method="post" style="display:inline">
                                                            <input type="hidden" name="action" value="pay">
                                                            <input type="hidden" name="orderId" value="${order.id}">
                                                            <input type="hidden" name="paymentMethod" value="TRANSFER">
                                                            <button type="submit" class="btn btn-ghost btn-sm"
                                                                style="font-size:12px">
                                                                <i class="fa-solid fa-hand-pointer"></i> Xác nhận thủ
                                                                công
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:if>

                                        <!-- Already Paid -->
                                        <c:if test="${order.status == 'PAID'}">
                                            <div
                                                style="margin-top:20px;text-align:center;color:var(--success);padding:20px">
                                                <i class="fa-solid fa-circle-check" style="font-size:2.5rem"></i>
                                                <p style="margin-top:8px;font-weight:700;font-size:16px">Đã thanh toán
                                                </p>
                                                <c:if test="${not empty payment}">
                                                    <p style="color:var(--text-muted);font-size:13px;margin-top:4px">
                                                        PTTT: ${payment.method} | Mã TT: #${payment.id}</p>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                </div>

                <script>
                    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }

                    // Payment method selection
                    let selectedMethod = '';
                    let pollingInterval = null;
                    const sepayEnabled = ${ sepayEnabled != null ? sepayEnabled : false};

                    function selectMethod(btn) {
                        // Remove active from all
                        document.querySelectorAll('.method-btn').forEach(b => b.classList.remove('active'));
                        btn.classList.add('active');
                        selectedMethod = btn.dataset.method;

                        const traditionalPayment = document.getElementById('traditionalPayment');
                        const qrContainer = document.getElementById('qrPaymentContainer');
                        const methodInput = document.getElementById('paymentMethodInput');

                        // Stop previous polling
                        if (pollingInterval) {
                            clearInterval(pollingInterval);
                            pollingInterval = null;
                        }

                        if (selectedMethod === 'TRANSFER' && sepayEnabled && qrContainer) {
                            // Show QR payment
                            traditionalPayment.classList.remove('show');
                            qrContainer.classList.add('show');
                            startPolling();
                        } else {
                            // Show traditional payment
                            if (qrContainer) qrContainer.classList.remove('show');
                            traditionalPayment.classList.add('show');
                            methodInput.value = selectedMethod;
                        }
                    }

                    // Poll payment status
                    function startPolling() {
                        const orderId = '${order.id}';
                        const ctx = '${ctx}';

                        pollingInterval = setInterval(function () {
                            fetch(ctx + '/api/payment/status?orderId=' + orderId)
                                .then(r => r.json())
                                .then(data => {
                                    if (data.status === 'PAID') {
                                        clearInterval(pollingInterval);
                                        // Show success
                                        document.getElementById('statusChecking').style.display = 'none';
                                        document.getElementById('paymentSuccessBanner').classList.add('show');

                                        // Play a subtle sound effect (optional)
                                        try {
                                            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                                            const oscillator = audioCtx.createOscillator();
                                            const gainNode = audioCtx.createGain();
                                            oscillator.connect(gainNode);
                                            gainNode.connect(audioCtx.destination);
                                            oscillator.frequency.setValueAtTime(800, audioCtx.currentTime);
                                            oscillator.frequency.setValueAtTime(1200, audioCtx.currentTime + 0.1);
                                            gainNode.gain.setValueAtTime(0.3, audioCtx.currentTime);
                                            gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.5);
                                            oscillator.start(audioCtx.currentTime);
                                            oscillator.stop(audioCtx.currentTime + 0.5);
                                        } catch (e) { }
                                    }
                                })
                                .catch(err => console.error('Polling error:', err));
                        }, 3000); // Check every 3 seconds
                    }

                    // Cleanup on page unload
                    window.addEventListener('beforeunload', function () {
                        if (pollingInterval) clearInterval(pollingInterval);
                    });
                </script>
            </body>

            </html>