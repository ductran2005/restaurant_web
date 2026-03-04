<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="sidebarActive" value="orders" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Order — Staff</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
            </head>

            <body>
                <div class="admin-layout">
                    <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                        <div class="admin-main">
                            <div class="admin-topbar">
                                <h2 style="font-size:1.125rem"><i class="fa-solid fa-clipboard-list"></i> Quản lý Order
                                </h2>
                                <button class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Tạo
                                    Order</button>
                            </div>
                            <div class="admin-content">
                                <div class="form-card" style="padding:0;overflow:hidden">
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>Order ID</th>
                                                <th>Bàn</th>
                                                <th>Số món</th>
                                                <th>Tổng</th>
                                                <th>Trạng thái</th>
                                                <th>Thời gian</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="o" items="${activeOrders}">
                                                <tr>
                                                    <td class="font-bold">#${o.id}</td>
                                                    <td>${o.table.tableName}</td>
                                                    <td>${o.orderDetails.size()}</td>
                                                    <td class="font-bold">
                                                        <fmt:formatNumber value="${o.totalAmount}" pattern="#,###" /> đ
                                                    </td>
                                                    <td><span
                                                            class="badge badge-${o.status.toLowerCase()}">${o.status}</span>
                                                    </td>
                                                    <td class="text-sm text-muted">${o.openedAt}</td>
                                                    <td>
                                                        <button class="btn btn-ghost btn-sm"><i
                                                                class="fa-solid fa-pen"></i> Sửa</button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty activeOrders}">
                                                <tr>
                                                    <td colspan="7" class="empty-state"><i
                                                            class="fa-solid fa-clipboard"></i> Chưa có order nào</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                </div>
            </body>

            </html>