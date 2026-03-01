<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Sửa sản phẩm - Restaurant POS</title>
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

                    .container {
                        max-width: 600px;
                        margin: 30px auto;
                        padding: 0 20px;
                    }

                    .card {
                        background: white;
                        border-radius: 12px;
                        padding: 30px;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                    }

                    .card h2 {
                        color: #333;
                        margin-bottom: 20px;
                        border-bottom: 2px solid #667eea;
                        padding-bottom: 10px;
                    }

                    .form-group {
                        margin-bottom: 16px;
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
                    }

                    .form-group input:focus,
                    .form-group textarea:focus,
                    .form-group select:focus {
                        border-color: #667eea;
                        outline: none;
                    }

                    .form-row {
                        display: flex;
                        gap: 16px;
                    }

                    .form-row .form-group {
                        flex: 1;
                    }

                    .btn {
                        padding: 12px 24px;
                        border: none;
                        border-radius: 8px;
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 600;
                        text-decoration: none;
                        display: inline-block;
                    }

                    .btn-primary {
                        background: #667eea;
                        color: white;
                    }

                    .btn-primary:hover {
                        background: #5a6fd6;
                    }

                    .btn-back {
                        background: #f5f5f5;
                        color: #333;
                        border: 1px solid #ddd;
                        margin-left: 10px;
                    }

                    .btn-back:hover {
                        background: #e8e8e8;
                    }

                    .error {
                        background: #ffebee;
                        color: #c62828;
                        padding: 12px;
                        border-radius: 8px;
                        margin-bottom: 15px;
                    }

                    .current-img {
                        max-width: 150px;
                        border-radius: 8px;
                        margin-top: 8px;
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
                    <h1>🍽️ Restaurant POS - Sửa sản phẩm</h1>
                </div>

                <div class="container">
                    <div class="card">
                        <h2>✏️ Sửa sản phẩm #${product.productId}</h2>

                        <c:if test="${not empty error}">
                            <div class="error">${error}</div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/admin/product"
                            enctype="multipart/form-data">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="productId" value="${product.productId}">

                            <div class="form-group">
                                <label>Tên sản phẩm *</label>
                                <input type="text" name="name" value="${product.productName}" required>
                            </div>

                            <div class="form-group">
                                <label>Danh mục *</label>
                                <select name="category" required>
                                    <option value="">-- Chọn danh mục --</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}" ${product.category.categoryId==cat.categoryId
                                            ? 'selected' : '' }>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label>Giá bán (VNĐ) *</label>
                                    <input type="number" name="price" value="${product.price}" step="1000" required>
                                </div>
                                <div class="form-group">
                                    <label>Giá vốn (VNĐ) *</label>
                                    <input type="number" name="cost" value="${product.costPrice}" step="1000" required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Mô tả</label>
                                <textarea name="description" rows="3">${product.description}</textarea>
                            </div>

                            <div class="form-group">
                                <label>Ảnh sản phẩm</label>
                                <c:if test="${not empty product.imageUrl}">
                                    <div>
                                        <img src="${pageContext.request.contextPath}/${product.imageUrl}"
                                            class="current-img" alt="Ảnh hiện tại">
                                        <p style="color:#888; font-size:12px; margin-top:4px;">Ảnh hiện tại</p>
                                    </div>
                                </c:if>
                                <input type="file" name="image" accept="image/*" onchange="previewImage(this)">
                                <img id="imgPreview" class="img-preview" style="display:none;">
                                <p style="color:#888; font-size:12px; margin-top:4px;">Để trống nếu không muốn thay đổi
                                    ảnh</p>
                            </div>

                            <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
                            <a href="${pageContext.request.contextPath}/admin/product" class="btn btn-back">← Quay
                                lại</a>
                        </form>
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