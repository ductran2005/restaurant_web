<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="menu" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thực đơn — Admin</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
                <style>
                    .img-thumb {
                        width: 56px;
                        height: 56px;
                        border-radius: 10px;
                        object-fit: cover;
                        border: 2px solid var(--border);
                        background: var(--bg-subtle, #f5f5f5);
                    }
                    .img-placeholder {
                        width: 56px;
                        height: 56px;
                        border-radius: 10px;
                        border: 2px dashed var(--border);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--text-muted);
                        font-size: 18px;
                        background: var(--bg-subtle, #f5f5f5);
                    }
                    .product-name-cell {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                    }
                    /* Upload area */
                    .upload-area {
                        border: 2px dashed var(--border);
                        border-radius: 12px;
                        padding: 20px;
                        text-align: center;
                        cursor: pointer;
                        transition: all .2s;
                        position: relative;
                        background: var(--bg-subtle, #f9f9f9);
                    }
                    .upload-area:hover {
                        border-color: var(--primary);
                        background: rgba(99, 102, 241, .04);
                    }
                    .upload-area input[type="file"] {
                        position: absolute;
                        inset: 0;
                        opacity: 0;
                        cursor: pointer;
                    }
                    .upload-icon {
                        font-size: 28px;
                        color: var(--text-muted);
                        margin-bottom: 8px;
                    }
                    .upload-text {
                        font-size: 13px;
                        color: var(--text-muted);
                    }
                    .upload-text strong {
                        color: var(--primary);
                    }
                    .upload-hint {
                        font-size: 11px;
                        color: var(--text-muted);
                        margin-top: 4px;
                    }
                    .img-preview-wrap {
                        position: relative;
                        display: inline-block;
                    }
                    .img-preview {
                        max-width: 100%;
                        max-height: 160px;
                        border-radius: 10px;
                        object-fit: cover;
                        border: 2px solid var(--border);
                    }
                    .img-remove-btn {
                        position: absolute;
                        top: -8px;
                        right: -8px;
                        width: 24px;
                        height: 24px;
                        border-radius: 50%;
                        background: var(--destructive);
                        color: #fff;
                        border: 2px solid #fff;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 11px;
                        cursor: pointer;
                        box-shadow: 0 2px 6px rgba(0,0,0,.2);
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
                                <h1 class="topbar-title"><i class="fa-solid fa-bowl-food"></i> Quản lý Thực đơn</h1>
                                <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>
                            <div class="content">
                                <c:if test="${not empty sessionScope.flash_msg}">
                                    <div
                                        class="alert alert-${sessionScope.flash_type == 'error' ? 'error' : 'success'}">
                                        <i
                                            class="fa-solid ${sessionScope.flash_type == 'error' ? 'fa-circle-exclamation' : 'fa-check-circle'}"></i>
                                        ${sessionScope.flash_msg}
                                    </div>
                                    <c:remove var="flash_msg" scope="session" />
                                    <c:remove var="flash_type" scope="session" />
                                </c:if>
                                <div class="page-header">
                                    <div class="page-header-left">
                                        <h2>Sản phẩm thực đơn</h2>
                                        <p>Quản lý món ăn, đồ uống</p>
                                    </div>
                                    <button class="btn btn-primary" onclick="openCreateModal()"><i
                                            class="fa-solid fa-plus"></i> Thêm sản phẩm</button>
                                </div>
                                <form method="get" action="${ctx}/admin/menu"
                                    style="display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap">
                                    <div class="search-wrap" style="flex:1;min-width:200px">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" name="search" class="search-input" style="width:100%"
                                            placeholder="Tìm theo tên..." value="${param.search}">
                                    </div>
                                    <select name="categoryId" class="form-control" style="width:180px">
                                        <option value="">Tất cả danh mục</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}" ${param.categoryId==cat.id ? 'selected' : '' }>
                                                ${cat.categoryName}</option>
                                        </c:forEach>
                                    </select>
                                    <select name="status" class="form-control" style="width:160px">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="AVAILABLE" ${param.status=='AVAILABLE' ?'selected':''}>Đang bán
                                        </option>
                                        <option value="UNAVAILABLE" ${param.status=='UNAVAILABLE' ?'selected':''}>Ngừng
                                            bán</option>
                                    </select>
                                    <button type="submit" class="btn btn-ghost"><i class="fa-solid fa-filter"></i>
                                        Lọc</button>
                                </form>
                                <div class="table-card">
                                    <table class="admin-table">
                                        <thead>
                                            <tr>
                                                <th>Sản phẩm</th>
                                                <th>Danh mục</th>
                                                <th style="text-align:right">Giá bán</th>
                                                <th style="text-align:right">Giá vốn</th>
                                                <th style="text-align:center">Số lượng</th>
                                                <th>Trạng thái</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="p" items="${products}">
                                                <tr>
                                                    <td>
                                                        <div class="product-name-cell">
                                                            <c:choose>
                                                                <c:when test="${not empty p.imageUrl}">
                                                                    <img src="${p.imageUrl}" alt="${p.productName}" class="img-thumb">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="img-placeholder">
                                                                        <i class="fa-solid fa-image"></i>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <span style="font-weight:600"><c:out value="${p.productName}" /></span>
                                                        </div>
                                                    </td>
                                                    <td style="color:var(--text-muted)">${p.category.categoryName}</td>
                                                    <td style="text-align:right">
                                                        <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                                    </td>
                                                    <td style="text-align:right;color:var(--text-muted)">
                                                        <fmt:formatNumber value="${p.costPrice}" pattern="#,###" />đ
                                                    </td>
                                                    <td style="text-align:center">
                                                        <span
                                                            class="badge ${p.quantity > 0 ? 'b-success' : 'b-danger'}">${p.quantity}</span>
                                                    </td>
                                                    <td><span
                                                            class="badge ${p.status=='AVAILABLE'?'b-success':'b-danger'}">${p.status=='AVAILABLE'?'Đang
                                                            bán':'Ngừng bán'}</span></td>
                                                    <td>
                                                        <div style="display:flex;gap:4px">
                                                            <button class="btn btn-ghost btn-sm"
                                                                onclick="openEditModal(${p.id},'${p.productName}',${p.category.id},${p.price},${p.costPrice},${p.quantity},'${p.status}','${p.description}','${p.imageUrl}')"
                                                                title="Sửa"><i class="fa-solid fa-pen"></i></button>
                                                            <form method="post" action="${ctx}/admin/menu"
                                                                style="display:inline">
                                                                <input type="hidden" name="action" value="toggleStatus">
                                                                <input type="hidden" name="itemId" value="${p.id}">
                                                                <button type="submit" class="btn btn-ghost btn-sm"
                                                                    title="Đổi trạng thái"
                                                                    style="color:${p.status=='AVAILABLE'?'var(--warning)':'var(--success)'}">
                                                                    <i
                                                                        class="fa-solid ${p.status=='AVAILABLE'?'fa-toggle-on':'fa-toggle-off'}"></i>
                                                                </button>
                                                            </form>
                                                            <button class="btn btn-ghost btn-sm"
                                                                style="color:var(--destructive)"
                                                                onclick="openDeleteModal(${p.id},'${p.productName}')"
                                                                title="Xóa"><i class="fa-solid fa-trash"></i></button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty products}">
                                                <tr>
                                                    <td colspan="7" class="empty-state"><i
                                                            class="fa-solid fa-bowl-food"></i>
                                                        <h3>Chưa có sản phẩm</h3>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                </div>

                <%-- Create/Edit Modal --%>
                    <div class="modal-overlay" id="formModal">
                        <div class="modal" style="max-width:540px">
                            <div class="modal-header">
                                <h3 class="modal-title" id="fTitle">Thêm sản phẩm</h3><button
                                    class="btn btn-ghost btn-sm" onclick="closeModal('formModal')"><i
                                        class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" id="prodForm" action="${ctx}/admin/menu" enctype="multipart/form-data">
                                <input type="hidden" name="action" id="pAction" value="create">
                                <input type="hidden" name="itemId" id="pId">
                                <input type="hidden" name="removeImage" id="pRemoveImage" value="false">
                                <div class="modal-body">
                                    <!-- Image Upload -->
                                    <div class="form-group">
                                        <label class="form-label">Ảnh sản phẩm</label>
                                        <div id="uploadArea" class="upload-area">
                                            <input type="file" name="imageFile" id="pImage" accept="image/*"
                                                onchange="previewImage(this)">
                                            <div id="uploadPlaceholder">
                                                <div class="upload-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
                                                <div class="upload-text">Kéo thả hoặc <strong>chọn ảnh</strong></div>
                                                <div class="upload-hint">JPG, PNG, WebP — Tối đa 5MB</div>
                                            </div>
                                            <div id="imagePreviewContainer" style="display:none">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group"><label class="form-label">Tên sản phẩm *</label><input
                                            type="text" name="itemName" id="pName" class="form-control" required>
                                    </div>
                                    <div class="form-group"><label class="form-label">Danh mục *</label>
                                        <select name="categoryId" id="pCat" class="form-control" required>
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.id}">${cat.categoryName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group"><label class="form-label">Giá bán *</label><input
                                                type="number" name="price" id="pPrice" class="form-control" required
                                                min="0" step="1000"></div>
                                        <div class="form-group"><label class="form-label">Giá vốn *</label><input
                                                type="number" name="costPrice" id="pCost" class="form-control" required
                                                min="0" step="1000"></div>
                                    </div>
                                    <div class="form-group"><label class="form-label">Số lượng *</label><input
                                            type="number" name="quantity" id="pQty" class="form-control" required
                                            min="0" step="1" value="0"></div>
                                    <div class="form-group"><label class="form-label">Mô tả</label><textarea
                                            name="description" id="pDesc" class="form-control" rows="2"></textarea>
                                    </div>
                                    <div class="form-group"><label class="form-label">Trạng thái</label>
                                        <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
                                            <input type="checkbox" name="isActive" id="pIsActive" checked>
                                            <span>Đang bán</span>
                                        </label>
                                    </div>
                                </div>
                                <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                        onclick="closeModal('formModal')">Hủy</button><button type="submit"
                                        class="btn btn-primary" id="fBtn">Thêm mới</button></div>
                            </form>
                        </div>
                    </div>

                    <%-- Delete Modal --%>
                        <div class="modal-overlay" id="delModal">
                            <div class="modal">
                                <div class="modal-header">
                                    <h3 class="modal-title"><i class="fa-solid fa-triangle-exclamation"
                                            style="color:var(--destructive)"></i> Xóa sản phẩm</h3><button
                                        class="btn btn-ghost btn-sm" onclick="closeModal('delModal')"><i
                                            class="fa-solid fa-xmark"></i></button>
                                </div>
                                <form method="post" action="${ctx}/admin/menu" id="delForm">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="itemId" id="delId">
                                    <div class="modal-body">
                                        <p id="delDesc" style="color:var(--text-muted);margin-bottom:16px"></p>
                                        <div class="form-group"><label class="form-label">Lý do *</label><textarea
                                                name="reason" class="form-control" rows="2" required
                                                placeholder="Nhập lý do..."></textarea></div>
                                    </div>
                                    <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                            onclick="closeModal('delModal')">Hủy</button><button type="submit"
                                            class="btn btn-danger">Xóa</button></div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function openModal(id) { document.getElementById(id).classList.add('active') }
                            function closeModal(id) { document.getElementById(id).classList.remove('active') }
                            function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                            function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }

                            function openCreateModal() {
                                document.getElementById('fTitle').textContent = 'Thêm sản phẩm';
                                document.getElementById('fBtn').textContent = 'Thêm mới';
                                document.getElementById('pAction').value = 'create';
                                document.getElementById('pId').value = '';
                                document.getElementById('pName').value = '';
                                document.getElementById('pPrice').value = '';
                                document.getElementById('pCost').value = '';
                                document.getElementById('pQty').value = '0';
                                document.getElementById('pDesc').value = '';
                                document.getElementById('pIsActive').checked = true;
                                document.getElementById('pRemoveImage').value = 'false';
                                resetImageUpload();
                                openModal('formModal');
                            }

                            function openEditModal(id, n, cat, pr, co, qty, st, de, imgUrl) {
                                document.getElementById('fTitle').textContent = 'Sửa sản phẩm';
                                document.getElementById('fBtn').textContent = 'Cập nhật';
                                document.getElementById('pAction').value = 'update';
                                document.getElementById('pId').value = id;
                                document.getElementById('pName').value = n;
                                document.getElementById('pCat').value = cat;
                                document.getElementById('pPrice').value = pr;
                                document.getElementById('pCost').value = co;
                                document.getElementById('pQty').value = qty;
                                document.getElementById('pIsActive').checked = (st === 'AVAILABLE');
                                document.getElementById('pDesc').value = de || '';
                                document.getElementById('pRemoveImage').value = 'false';

                                // Show existing image or reset
                                if (imgUrl && imgUrl !== 'null' && imgUrl !== '') {
                                    showImagePreview(imgUrl);
                                } else {
                                    resetImageUpload();
                                }

                                openModal('formModal');
                            }

                            function openDeleteModal(id, n) {
                                document.getElementById('delId').value = id;
                                document.getElementById('delDesc').textContent = 'Xóa "' + n + '"? Không thể hoàn tác.';
                                openModal('delModal');
                            }

                            // Image preview functions
                            function previewImage(input) {
                                if (input.files && input.files[0]) {
                                    var file = input.files[0];
                                    // Validate size (5MB)
                                    if (file.size > 5 * 1024 * 1024) {
                                        alert('Ảnh quá lớn! Tối đa 5MB.');
                                        input.value = '';
                                        return;
                                    }
                                    var reader = new FileReader();
                                    reader.onload = function (e) {
                                        showImagePreview(e.target.result);
                                    };
                                    reader.readAsDataURL(file);
                                    document.getElementById('pRemoveImage').value = 'false';
                                }
                            }

                            function showImagePreview(src) {
                                document.getElementById('uploadPlaceholder').style.display = 'none';
                                var container = document.getElementById('imagePreviewContainer');
                                container.style.display = 'block';
                                container.innerHTML = '<div class="img-preview-wrap">' +
                                    '<img src="' + src + '" class="img-preview" alt="Preview">' +
                                    '<button type="button" class="img-remove-btn" onclick="removeImage()" title="Xóa ảnh">' +
                                    '<i class="fa-solid fa-xmark"></i></button></div>';
                            }

                            function removeImage() {
                                document.getElementById('pImage').value = '';
                                document.getElementById('pRemoveImage').value = 'true';
                                resetImageUpload();
                            }

                            function resetImageUpload() {
                                document.getElementById('uploadPlaceholder').style.display = 'block';
                                document.getElementById('imagePreviewContainer').style.display = 'none';
                                document.getElementById('imagePreviewContainer').innerHTML = '';
                                document.getElementById('pImage').value = '';
                            }
                        </script>
            </body>

            </html>