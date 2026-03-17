<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>In hóa đơn</title>
    <style>
        @media print {
            .no-print {
                display: none;
            }
            body {
                margin: 0;
                padding: 10px;
            }
        }
        
        body {
            font-family: 'Courier New', monospace;
            max-width: 400px;
            margin: 20px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        
        .receipt-container {
            background: white;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        pre {
            margin: 0;
            white-space: pre-wrap;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            line-height: 1.4;
        }
        
        .button-container {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px dashed #ccc;
        }
        
        button {
            padding: 10px 30px;
            font-size: 16px;
            cursor: pointer;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            margin: 0 5px;
        }
        
        button:hover {
            background: #45a049;
        }
        
        .btn-secondary {
            background: #2196F3;
        }
        
        .btn-secondary:hover {
            background: #0b7dda;
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <pre id="receiptContent"></pre>
        
        <div class="button-container no-print">
            <button onclick="window.print()">🖨️ In hóa đơn</button>
            <button class="btn-secondary" onclick="window.close()">Đóng</button>
        </div>
    </div>

    <script>
        // Get orderId from URL parameter
        const urlParams = new URLSearchParams(window.location.search);
        const orderId = urlParams.get('orderId');
        
        if (!orderId) {
            document.getElementById('receiptContent').textContent = 'Lỗi: Không tìm thấy mã đơn hàng';
        } else {
            // Fetch receipt content
            fetch('${pageContext.request.contextPath}/cashier/receipt?orderId=' + orderId)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Không thể tải hóa đơn');
                    }
                    return response.text();
                })
                .then(data => {
                    document.getElementById('receiptContent').textContent = data;
                })
                .catch(error => {
                    document.getElementById('receiptContent').textContent = 'Lỗi: ' + error.message;
                });
        }
        
        // Auto-print option (can be enabled if needed)
        // window.onload = function() { window.print(); }
    </script>
</body>
</html>
