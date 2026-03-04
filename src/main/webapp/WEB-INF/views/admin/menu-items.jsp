<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="sidebarActive" value="menu" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Thực đơn — Admin</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
            </head>

            <body>
                <div class="admin-layout">
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="admin-main">
                            <div class="admin-topbar">
                                <h2 style="font-size:1.125rem"><i class="fa-solid fa-bowl-food"></i> Quản lý Thực đơn
                                </h2>
                                <button class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Thêm
                                    sản phẩm</button>
                            </div>
                            <div class="admin-content">
                                <div class="form-card" style="padding:0;overflow:hidden">
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>Tên</th>
                                                <th>Danh mục</th>
                                                <th>Giá bán</th>
                                                <th>Giá vốn</th>
                                                <th>Trạng thái</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${products}">
                                                <tr>
                                                    <td class="font-bold">
                                                        <c:out value="${item.productName}" />
                                                    </td>
                                                    <td class="text-muted">
                                                        <c:out value="${item.category.categoryName}" />
                                                    </td>
                                                    <td>
                                                        <fmt:formatNumber value="${item.price}" pattern="#,###" /> đ
                                                    </td>
                                                    <td class="text-muted">
                                                        <fmt:formatNumber value="${item.costPrice}" pattern="#,###" /> đ
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.status == 'AVAILABLE'}">
                                                                <span class="badge badge-confirmed">Đang bán</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-cancelled">Ngừng bán</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <button class="btn btn-ghost btn-sm"><i
                                                                class="fa-solid fa-pen"></i></button>
                                                        <button class="btn btn-ghost btn-sm"
                                                            style="color:var(--destructive)"><i
                                                                class="fa-solid fa-trash"></i></button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty products}">
                                                <tr>
                                                    <td colspan="6" class="empty-state"><i
                                                            class="fa-solid fa-bowl-food"></i> Chưa có sản phẩm nào</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                                <%-- Hình ảnh (imageUrl): không có cột này trong DB products --%>
                                    <%-- Tồn kho (quantity): không có cột này trong products, xem bảng inventory --%>
                                        <%-- isSoldOut: đã thay bằng status=AVAILABLE/UNAVAILABLE --%>
                            </div>
                        </div>
                </div>
            </body>

            </html>