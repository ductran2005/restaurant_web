<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurant POS - Quản Lý Sản Phẩm</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; color: #333; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        h1 { text-align: center; color: #2c3e50; margin-bottom: 30px; }

        /* Error / Success Messages */
        .alert { padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; }
        .alert-error { background: #ffe0e0; color: #c0392b; border: 1px solid #e74c3c; }
        .alert-success { background: #e0ffe0; color: #27ae60; border: 1px solid #2ecc71; }

        /* Form */
        .form-card { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .form-card h2 { color: #2c3e50; margin-bottom: 16px; }
        .form-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 12px; }
        .form-group { flex: 1; min-width: 200px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #555; }
        .form-group input, .form-group textarea, .form-group select {
            width: 100%; padding: 10px 14px; border: 1px solid #ddd; border-radius: 8px;
            font-size: 14px; transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group textarea:focus { border-color: #3498db; outline: none; }
        .btn { padding: 10px 24px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: #3498db; color: #fff; }
        .btn-primary:hover { background: #2980b9; }
        .btn-danger { background: #e74c3c; color: #fff; }
        .btn-danger:hover { background: #c0392b; }
        .btn-warning { background: #f39c12; color: #fff; }
        .btn-warning:hover { background: #d68910; }

        /* Search */
        .search-bar { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-bar input { flex: 1; padding: 10px 14px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; }

        /* Table */
        .table-card { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #2c3e50; color: #fff; padding: 14px 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f8f9fa; }
        .status-available { color: #27ae60; font-weight: 600; }
        .status-unavailable { color: #e74c3c; font-weight: 600; }
        .actions { display: flex; gap: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🍽️ Quản Lý Sản Phẩm</h1>

        <!-- Thông báo -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
        </c:if>

        <!-- Form thêm sản phẩm -->
        <div class="form-card">
            <h2>➕ Thêm Sản Phẩm Mới</h2>
            <form action="${pageContext.request.contextPath}/admin/product" method="post">
                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Tên sản phẩm</label>
                        <input type="text" id="name" name="name" required placeholder="Nhập tên sản phẩm">
                    </div>
                    <div class="form-group">
                        <label for="category">Danh mục</label>
                        <input type="number" id="category" name="category" required placeholder="ID danh mục">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="price">Giá bán (VNĐ)</label>
                        <input type="number" id="price" name="price" step="1000" required placeholder="0">
                    </div>
                    <div class="form-group">
                        <label for="cost">Giá vốn (VNĐ)</label>
                        <input type="number" id="cost" name="cost" step="1000" required placeholder="0">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" rows="3" placeholder="Mô tả sản phẩm..."></textarea>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Thêm Sản Phẩm</button>
            </form>
        </div>

        <!-- Tìm kiếm -->
        <form action="${pageContext.request.contextPath}/admin/product" method="get" class="search-bar">
            <input type="hidden" name="action" value="search">
            <input type="text" name="keyword" value="${keyword}" placeholder="🔍 Tìm kiếm sản phẩm...">
            <button type="submit" class="btn btn-primary">Tìm kiếm</button>
            <a href="${pageContext.request.contextPath}/admin/product" class="btn btn-warning">Tất cả</a>
        </form>

        <!-- Bảng sản phẩm -->
        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
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
                            <td>${p.productName}</td>
                            <td>${p.categoryId}</td>
                            <td><fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> ₫</td>
                            <td><fmt:formatNumber value="${p.costPrice}" type="number" groupingUsed="true"/> ₫</td>
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
                                <a href="${pageContext.request.contextPath}/admin/product?action=edit&id=${p.productId}" class="btn btn-warning">Sửa</a>
                                <a href="${pageContext.request.contextPath}/admin/product?action=delete&id=${p.productId}"
                                   class="btn btn-danger"
                                   onclick="return confirm('Bạn có chắc muốn xóa sản phẩm này?')">Xóa</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty list}">
                        <tr>
                            <td colspan="7" style="text-align:center; color:#999; padding:30px;">
                                Chưa có sản phẩm nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
