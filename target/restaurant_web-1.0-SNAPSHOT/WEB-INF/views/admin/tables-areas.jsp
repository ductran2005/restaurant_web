<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="sidebarActive" value="tables" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Bàn & Khu vực — Admin</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        </head>

        <body>
            <div class="admin-layout">
                <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>
                    <div class="admin-main">
                        <div class="admin-topbar">
                            <h2 style="font-size:1.125rem"><i class="fa-solid fa-chair"></i> Quản lý Bàn & Khu vực</h2>
                            <div style="display:flex;gap:.5rem">
                                <button class="btn btn-outline btn-sm"><i class="fa-solid fa-plus"></i> Thêm Khu
                                    vực</button>
                                <button class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Thêm
                                    Bàn</button>
                            </div>
                        </div>
                        <div class="admin-content">
                            <c:forEach var="area" items="${areas}">
                                <div class="area-section">
                                    <div class="area-title"><i class="fa-solid fa-location-dot"></i>
                                        <c:out value="${area.areaName}" /> <span class="text-muted text-sm"
                                            style="font-weight:400">(${area.tables.size()} bàn)</span>
                                    </div>
                                    <div class="table-grid">
                                        <c:forEach var="table" items="${area.tables}">
                                            <div class="table-card status-${table.status.toLowerCase()}">
                                                <div class="table-name">
                                                    <c:out value="${table.tableName}" />
                                                </div>
                                                <div class="table-cap"><i class="fa-solid fa-user"></i>
                                                    ${table.capacity} chỗ</div>
                                                <span class="badge badge-${table.status.toLowerCase()}"
                                                    style="margin-top:.5rem">${table.status}</span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
            </div>
        </body>

        </html>