<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <title>Quản lý bàn - Restaurant POS</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: 'Segoe UI', sans-serif;
                        background: #f0f2f5;
                    }

                    .header {
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                        padding: 20px 30px;
                    }

                    .header h1 {
                        font-size: 24px;
                    }

                    .nav {
                        margin-top: 10px;
                    }

                    .nav a {
                        color: rgba(255, 255, 255, 0.8);
                        text-decoration: none;
                        margin-right: 20px;
                        font-size: 14px;
                    }

                    .nav a:hover,
                    .nav a.active {
                        color: white;
                        border-bottom: 2px solid white;
                        padding-bottom: 4px;
                    }

                    .container {
                        max-width: 1200px;
                        margin: 20px auto;
                        padding: 0 20px;
                    }

                    .area-section {
                        margin-bottom: 30px;
                    }

                    .area-title {
                        font-size: 18px;
                        color: #333;
                        margin-bottom: 15px;
                        padding-left: 10px;
                        border-left: 4px solid #667eea;
                    }

                    .tables-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
                        gap: 15px;
                    }

                    .table-card {
                        background: white;
                        border-radius: 12px;
                        padding: 20px;
                        text-align: center;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                        transition: transform 0.2s, box-shadow 0.2s;
                        cursor: pointer;
                    }

                    .table-card:hover {
                        transform: translateY(-3px);
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
                    }

                    .table-card.available {
                        border-top: 4px solid #4CAF50;
                    }

                    .table-card.in-use {
                        border-top: 4px solid #FF9800;
                    }

                    .table-name {
                        font-size: 20px;
                        font-weight: bold;
                        color: #333;
                    }

                    .table-capacity {
                        color: #888;
                        font-size: 13px;
                        margin: 5px 0;
                    }

                    .table-status {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: bold;
                        margin-top: 8px;
                    }

                    .status-available {
                        background: #E8F5E9;
                        color: #2E7D32;
                    }

                    .status-in-use {
                        background: #FFF3E0;
                        color: #E65100;
                    }

                    .btn-open {
                        display: inline-block;
                        margin-top: 10px;
                        background: #667eea;
                        color: white;
                        border: none;
                        padding: 8px 20px;
                        border-radius: 6px;
                        cursor: pointer;
                        font-size: 13px;
                    }

                    .btn-open:hover {
                        background: #5a6fd6;
                    }

                    .error {
                        background: #ffebee;
                        color: #c62828;
                        padding: 12px;
                        border-radius: 8px;
                        margin-bottom: 15px;
                    }
                </style>
            </head>

            <body>
                <div class="header">
                    <h1>🍽️ Restaurant POS</h1>
                    <div class="nav">
                        <a href="${pageContext.request.contextPath}/tables" class="active">Bàn</a>
                        <a href="${pageContext.request.contextPath}/orders">Đơn hàng</a>
                        <a href="${pageContext.request.contextPath}/admin/product">Sản phẩm</a>
                        <a href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
                    </div>
                </div>

                <div class="container">
                    <c:if test="${not empty error}">
                        <div class="error">${error}</div>
                    </c:if>

                    <c:forEach var="area" items="${areas}">
                        <div class="area-section">
                            <h2 class="area-title">${area.areaName}</h2>
                            <div class="tables-grid">
                                <c:forEach var="table" items="${tables}">
                                    <c:if test="${table.area.areaId == area.areaId}">
                                        <div class="table-card ${table.status == 'AVAILABLE' ? 'available' : 'in-use'}">
                                            <div class="table-name">${table.tableName}</div>
                                            <div class="table-capacity">👤 ${table.capacity} chỗ</div>
                                            <span
                                                class="table-status ${table.status == 'AVAILABLE' ? 'status-available' : 'status-in-use'}">
                                                ${table.status == 'AVAILABLE' ? 'Trống' : 'Đang sử dụng'}
                                            </span>
                                            <c:if test="${table.status == 'AVAILABLE'}">
                                                <form method="post" action="${pageContext.request.contextPath}/tables"
                                                    style="margin-top: 8px;">
                                                    <input type="hidden" name="action" value="open">
                                                    <input type="hidden" name="tableId" value="${table.tableId}">
                                                    <button type="submit" class="btn-open">Mở bàn</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </body>

            </html>