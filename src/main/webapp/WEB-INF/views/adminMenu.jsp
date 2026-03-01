<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Restaurant POS - Quản Lý Sản Phẩm</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: 'Segoe UI', Tahoma, sans-serif;
                        background: #f5f5f5;
                        color: #333;
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
                        margin: 0 auto;
                        padding: 20px;
                    }

                    /* Thông báo */
                    .alert {
                        padding: 12px 20px;
                        border-radius: 8px;
                        margin-bottom: 20px;
                    }

                    .alert-error {
                        background: #ffe0e0;
                        color: #c0392b;
                        border: 1px solid #e74c3c;
                    }

                    .alert-success {
                        background: #e0ffe0;
                        color: #27ae60;
                        border: 1px solid #2ecc71;
                    }

                    /* Form */
                    .form-card {
                        background: #fff;
                        border-radius: 12px;
                        padding: 24px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        margin-bottom: 30px;
                    }

                    .form-card h2 {
                        color: #2c3e50;
                        margin-bottom: 16px;
                    }

                    .form-row {
                        display: flex;
                        gap: 16px;
                        flex-wrap: wrap;
                        margin-bottom: 12px;
                    }

                    .form-group {
                        flex: 1;
                        min-width: 200px;
                    }

                    .form-group label {
                        display: block;
                        margin-bottom: 6px;
                        font-weight: 600;
                        color: #555;
                    }

                    .form-group input,
                    .form-group textarea,
                    .form-group select {
                        width: 100%;
                        padding: 10px 14px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                        transition: border-color 0.3s;
                    }

                    .form-group input:focus,
                    .form-group textarea:focus,
                    .form-group select:focus {
                        border-color: #3498db;
                        outline: none;
                    }

                    .btn {
                        padding: 10px 24px;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 600;
                        transition: all 0.3s;
                        text-decoration: none;
                        display: inline-block;
                    }

                    .btn-primary {
                        background: #3498db;
                        color: #fff;
                    }

                    .btn-primary:hover {
                        background: #2980b9;
                    }

                    .btn-danger {
                        background: #e74c3c;
                        color: #fff;
                    }

                    .btn-danger:hover {
                        background: #c0392b;
                    }

                    .btn-warning {
                        background: #f39c12;
                        color: #fff;
                    }

                    .btn-warning:hover {
                        background: #d68910;
                    }

                    .btn-success {
                        background: #27ae60;
                        color: #fff;
                    }

                    .btn-success:hover {
                        background: #219a52;
                    }

                    /* Search + Filter */
                    .toolbar {
                        display: flex;
                        gap: 10px;
                        margin-bottom: 20px;
                        flex-wrap: wrap;
                        align-items: center;
                    }

                    .toolbar input {
                        flex: 1;
                        min-width: 200px;
                        padding: 10px 14px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                    }

                    .toolbar select {
                        padding: 10px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                    }

                    /* Table */
                    .table-card {
                        background: #fff;
                        border-radius: 12px;
                        padding: 24px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        overflow-x: auto;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    th {
                        background: #2c3e50;
                        color: #fff;
                        padding: 14px 12px;
                        text-align: left;
                    }

                    td {
                        padding: 12px;
                        border-bottom: 1px solid #eee;
                    }

                    tr:hover {
                        background: #f8f9fa;
                    }

                    .status-available {
                        color: #27ae60;
                        font-weight: 600;
                    }

                    .status-unavailable {
                        color: #e74c3c;
                        font-weight: 600;
                    }

                    .actions {
                        display: flex;
                        gap: 8px;
                    }

                    /* Image */
                    .product-img {
                        width: 50px;
                        height: 50px;
                        object-fit: cover;
                        border-radius: 6px;
                    }

                    .img-preview {
                        max-width: 120px;
                        max-height: 80px;
                        border-radius: 6px;
                        margin-top: 6px;
                    }
                </style>
            </head>

            <body>
                <div class="header">
                    <h1>🍽️ Restaurant POS</h1>
                    <div class="nav">
                        <a href="${pageContext.request.contextPath}/tables">Bàn</a>
                        <a href="${pageContext.request.contextPath}/orders">Đơn hàng</a>
                        <a href="${pageContext.request.contextPath}/admin/product" class="active">Sản phẩm</a>
                        <a href="${pageContext.request.contextPath}/auth/logout">Đăng xuất</a>
                    </div>
                </div>

                <div class="container">
                    <!-- Thông báo -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-error">${error}</div>
                    </c:if>
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success">${param.success}</div>
                    </c:if>

                    <!-- Form thêm sản phẩm -->
                    <div class="form-card">
                        <h2>➕ Thêm Sản Phẩm Mới</h2>
                        <form action="${pageContext.request.contextPath}/admin/product" method="post"
                            enctype="multipart/form-data">
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="name">Tên sản phẩm *</label>
                                    <input type="text" id="name" name="name" required placeholder="Nhập tên sản phẩm">
                                </div>
                                <div class="form-group">
                                    <label for="category">Danh mục *</label>
                                    <select id="category" name="category" required>
                                        <option value="">-- Chọn danh mục --</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.categoryId}">${cat.categoryName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="price">Giá bán (VNĐ) *</label>
                                    <input type="number" id="price" name="price" step="1000" required placeholder="0">
                                </div>
                                <div class="form-group">
                                    <label for="cost">Giá vốn (VNĐ) *</label>
                                    <input type="number" id="cost" name="cost" step="1000" required placeholder="0">
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="description">Mô tả</label>
                                    <textarea id="description" name="description" rows="3"
                                        placeholder="Mô tả sản phẩm..."></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="image">Ảnh sản phẩm</label>
                                    <input type="file" id="image" name="image" accept="image/*"
                                        onchange="previewImage(this)">
                                    <img id="imgPreview" class="img-preview" style="display:none;">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary">✅ Thêm Sản Phẩm</button>
                        </form>
                    </div>

                    <!-- Toolbar: Search + Filter -->
                    <div class="toolbar">
                        <form action="${pageContext.request.contextPath}/admin/product" method="get"
                            style="display:flex; gap:8px; flex:1; min-width:250px;">
                            <input type="hidden" name="action" value="search">
                            <input type="text" name="keyword" value="${keyword}" placeholder="🔍 Tìm kiếm theo tên...">
                            <button type="submit" class="btn btn-primary">Tìm</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/admin/product" method="get"
                            style="display:flex; gap:8px;">
                            <input type="hidden" name="action" value="filter">
                            <select name="categoryId" onchange="this.form.submit()">
                                <option value="">📂 Tất cả danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" ${selectedCategory==cat.categoryId ? 'selected'
                                        : '' }>
                                        ${cat.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </form>

                        <a href="${pageContext.request.contextPath}/admin/product" class="btn btn-warning">🔄 Reset</a>
                    </div>

                    <!-- Bảng sản phẩm -->
                    <div class="table-card">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Danh mục</th>
                                    <th>Giá bán</th>
                                    <th>Giá vốn</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${list}">
                                    <tr>
                                        <td>${p.productId}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/${p.imageUrl}"
                                                        class="product-img" alt="${p.productName}">
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#ccc;">📷</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><strong>${p.productName}</strong></td>
                                        <td>${p.category.categoryName}</td>
                                        <td>
                                            <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true" /> ₫
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${p.costPrice}" type="number"
                                                groupingUsed="true" /> ₫
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status == 'AVAILABLE'}">
                                                    <span class="status-available">✅ Có sẵn</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-unavailable">❌ Hết hàng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/admin/product?action=edit&id=${p.productId}"
                                                class="btn btn-warning" style="padding:6px 14px;">Sửa</a>
                                            <a href="${pageContext.request.contextPath}/admin/product?action=delete&id=${p.productId}"
                                                class="btn btn-danger" style="padding:6px 14px;"
                                                onclick="return confirm('Bạn có chắc muốn ẩn sản phẩm này?')">Ẩn</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty list}">
                                    <tr>
                                        <td colspan="8" style="text-align:center; color:#999; padding:30px;">
                                            Chưa có sản phẩm nào.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <script>
                    function previewImage(input) {
                        var preview = document.getElementById('imgPreview');
                        if (input.files && input.files[0]) {
                            var reader = new FileReader();
                            reader.onload = function (e) {
                                preview.src = e.target.result;
                                preview.style.display = 'block';
                            };
                            reader.readAsDataURL(input.files[0]);
                        }
                    }
                </script>
            </body>

            </html>