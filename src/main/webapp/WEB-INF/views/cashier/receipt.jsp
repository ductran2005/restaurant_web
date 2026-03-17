<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>In hóa đơn — Thu ngân</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            padding: 28px 16px 48px;
            background: var(--bg);
        }

        .receipt-wrapper {
            width: 100%;
            max-width: 460px;
        }

        /* ── Top bar ── */
        .receipt-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .receipt-topbar h1 {
            font-size: 15px;
            font-weight: 700;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0;
        }

        .receipt-topbar h1 i {
            color: var(--primary);
        }

        /* ── Card ── */
        .receipt-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 24px rgba(0,0,0,.1);
            margin-bottom: 16px;
        }

        /* Gradient header strip */
        .receipt-card-top {
            background: linear-gradient(135deg, var(--primary, #6366f1), #8b5cf6);
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .receipt-card-top-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .receipt-icon-circle {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background: rgba(255,255,255,.18);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 18px;
            flex-shrink: 0;
        }

        .receipt-card-top-title {
            font-size: 15px;
            font-weight: 700;
            color: #fff;
        }

        .receipt-card-top-sub {
            font-size: 11px;
            color: rgba(255,255,255,.7);
            margin-top: 2px;
        }

        .receipt-status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(52,211,153,.2);
            border: 1px solid rgba(52,211,153,.4);
            color: #34d399;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 20px;
        }

        /* Dashed boder separator (ticket punch) */
        .receipt-punch {
            display: flex;
            align-items: center;
            padding: 0;
            position: relative;
        }

        .receipt-punch::before,
        .receipt-punch::after {
            content: '';
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--bg);
            flex-shrink: 0;
            position: absolute;
        }

        .receipt-punch::before { left: -10px; }
        .receipt-punch::after  { right: -10px; }

        .receipt-punch-line {
            flex: 1;
            border: none;
            border-top: 2px dashed var(--border);
            margin: 0 14px;
        }

        /* Receipt content */
        .receipt-content {
            padding: 20px 24px 24px;
        }

        /* Loading */
        .receipt-loading {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 14px;
            padding: 48px 24px;
        }

        .spinner {
            width: 32px;
            height: 32px;
            border: 3px solid var(--border);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin .8s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        .receipt-loading p {
            color: var(--text-muted);
            font-size: 13px;
            margin: 0;
        }

        /* Error */
        .receipt-error {
            text-align: center;
            padding: 40px 24px;
        }

        .receipt-error i {
            font-size: 2.5rem;
            color: #ef4444;
            margin-bottom: 12px;
            display: block;
        }

        .receipt-error p {
            color: var(--text-muted);
            font-size: 13px;
        }

        /* The actual pre receipt text */
        #receiptPre {
            font-family: 'Courier New', 'Courier', monospace;
            font-size: 12.5px;
            line-height: 1.65;
            white-space: pre;
            overflow-x: auto;
            color: var(--text);
            margin: 0;
            background: transparent;
            -webkit-overflow-scrolling: touch;
        }

        /* Action buttons */
        .receipt-actions {
            display: flex;
            gap: 10px;
        }

        .receipt-actions .btn {
            flex: 1;
            justify-content: center;
            padding: 13px;
            font-size: 13px;
            border-radius: 10px;
        }

        /* ──────── PRINT ──────── */
        @media print {
            /* Ẩn tất cả — chỉ hiện pre text */
            body {
                background: #fff !important;
                padding: 0 !important;
                margin: 0 !important;
                display: block !important;
            }

            .no-print,
            .receipt-topbar,
            .receipt-actions,
            .receipt-card-top,
            .receipt-punch { display: none !important; }

            .receipt-wrapper {
                max-width: 100%;
            }

            .receipt-card {
                box-shadow: none !important;
                border: none !important;
                border-radius: 0 !important;
                background: #fff !important;
            }

            .receipt-content {
                padding: 0 !important;
            }

            #receiptPre {
                font-family: 'Courier New', monospace;
                font-size: 11px;
                line-height: 1.4;
                color: #000 !important;
                white-space: pre;
            }
        }

        @media (max-width: 480px) {
            .receipt-actions {
                flex-direction: column;
            }

            .receipt-card-top {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }
        }
    </style>
</head>
<body>
    <div class="receipt-wrapper">

        <!-- top bar -->
        <div class="receipt-topbar no-print">
            <h1><i class="fa-solid fa-receipt"></i> Hóa đơn thanh toán</h1>
        </div>

        <!-- card -->
        <div class="receipt-card">

            <!-- gradient header -->
            <div class="receipt-card-top">
                <div class="receipt-card-top-left">
                    <div class="receipt-icon-circle">
                        <i class="fa-solid fa-file-invoice-dollar"></i>
                    </div>
                    <div>
                        <div class="receipt-card-top-title">HÓA ĐƠN BÁN HÀNG</div>
                        <div class="receipt-card-top-sub">
                            <i class="fa-solid fa-hashtag" style="font-size:9px"></i>
                            Order #<span id="orderIdDisplay">...</span>
                        </div>
                    </div>
                </div>
                <div class="receipt-status-badge">
                    <i class="fa-solid fa-circle-check"></i> ĐÃ THANH TOÁN
                </div>
            </div>

            <!-- ticket punch effect -->
            <div class="receipt-punch">
                <hr class="receipt-punch-line">
            </div>

            <!-- content area -->
            <div class="receipt-content">
                <!-- loading -->
                <div class="receipt-loading" id="loadingState">
                    <div class="spinner"></div>
                    <p>Đang tải hóa đơn...</p>
                </div>

                <!-- receipt text -->
                <pre id="receiptPre" style="display:none"></pre>

                <!-- error -->
                <div class="receipt-error" id="errorState" style="display:none">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <p id="errorMsg">Không thể tải hóa đơn</p>
                </div>
            </div>
        </div>

        <!-- action buttons -->
        <div class="receipt-actions no-print">
            <button id="printBtn" class="btn btn-primary" onclick="window.print()" style="display:none">
                <i class="fa-solid fa-print"></i> In hóa đơn
            </button>
            <button class="btn btn-ghost" onclick="goBack()">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </button>
        </div>

    </div>

    <script>
        const ctx = '${pageContext.request.contextPath}';
        const params = new URLSearchParams(window.location.search);
        const orderId = params.get('orderId');

        function goBack() {
            window.location.href = ctx + '/cashier';
        }

        if (orderId) {
            document.getElementById('orderIdDisplay').textContent = orderId;

            fetch(ctx + '/cashier/receipt?orderId=' + orderId)
                .then(function(res) {
                    if (!res.ok) throw new Error('Lỗi HTTP ' + res.status + ' — không thể tải hóa đơn');
                    return res.text();
                })
                .then(function(text) {
                    document.getElementById('loadingState').style.display = 'none';

                    var pre = document.getElementById('receiptPre');
                    pre.textContent = text;
                    pre.style.display = 'block';

                    document.getElementById('printBtn').style.display = 'flex';
                })
                .catch(function(err) {
                    document.getElementById('loadingState').style.display = 'none';
                    document.getElementById('errorState').style.display = 'block';
                    document.getElementById('errorMsg').textContent = err.message;
                });
        } else {
            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('errorState').style.display = 'block';
            document.getElementById('errorMsg').textContent = 'Không tìm thấy mã đơn hàng trong URL';
        }
    </script>
</body>
</html>
