<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="sidebarActive" value="categories" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Danh mục — Admin</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        </head>

        <body>
            <div class="admin-layout">
                <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                    <div class="admin-main">
                        <div class="admin-topbar">
                            <h2 style="font-size:1.125rem"><i class="fa-solid fa-tags"></i> Quản lý Danh mục</h2>
                            <button class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Thêm danh
                                mục</button>
                        </div>
                        <div class="admin-content">
                            <div class="form-card" style="padding:0;overflow:hidden">
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>Tên</th>
                                            <th>Số sản phẩm</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="cat" items="${categories}">
                                            <tr>
                                                <td class="font-bold">
                                                    <c:out value="${cat.categoryName}" />
                                                </td>
                                                <%-- description: không có cột này trong DB categories --%>
                                                    <td>${cat.products != null ? cat.products.size() : 0}</td>
                                                    <td><span
                                                            class="badge ${cat.status == 'ACTIVE' ? 'badge-confirmed' : 'badge-cancelled'}">${cat.status
                                                            == 'ACTIVE'
                                                            ? 'Hoạt động' : 'Tắt'}</span></td>
                                                    <td>
                                                        <button class="btn btn-ghost btn-sm"><i
                                                                class="fa-solid fa-pen"></i></button>
                                                        <button class="btn btn-ghost btn-sm"
                                                            style="color:var(--destructive)"><i
                                                                class="fa-solid fa-trash"></i></button>
                                                    </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
            </div>
        </body>

        </html>