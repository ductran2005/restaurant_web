<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="rbac" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Phân quyền RBAC — Admin</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
            <style>
                .perm-matrix {
                    width: 100%;
                    border-collapse: collapse;
                    font-size: 13px;
                }

                .perm-matrix th {
                    padding: 12px 16px;
                    text-align: center;
                    background: var(--surface2);
                    border-bottom: 1px solid var(--border);
                    font-size: 11px;
                    text-transform: uppercase;
                    letter-spacing: .06em;
                    color: var(--text-muted);
                    font-weight: 600;
                }

                .perm-matrix th:first-child {
                    text-align: left;
                    min-width: 220px;
                    position: sticky;
                    left: 0;
                    background: var(--surface2);
                    z-index: 2;
                }

                .perm-matrix td {
                    padding: 10px 16px;
                    border-bottom: 1px solid var(--border);
                    text-align: center;
                    vertical-align: middle;
                }

                .perm-matrix td:first-child {
                    text-align: left;
                    position: sticky;
                    left: 0;
                    background: var(--surface);
                    z-index: 1;
                    font-weight: 500;
                }

                .perm-matrix tbody tr:hover td {
                    background: var(--surface2);
                }

                .perm-matrix .group-row td {
                    background: rgba(232, 160, 32, .05);
                    color: var(--text-muted);
                    font-size: 11px;
                    text-transform: uppercase;
                    letter-spacing: .08em;
                    font-weight: 700;
                    padding: 8px 16px;
                }

                .perm-toggle {
                    width: 32px;
                    height: 32px;
                    border-radius: 8px;
                    border: none;
                    cursor: pointer;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 14px;
                    transition: all .2s;
                }

                .perm-toggle.on {
                    background: rgba(34, 197, 94, .12);
                    color: #22c55e;
                }

                .perm-toggle.off {
                    background: rgba(156, 163, 175, .1);
                    color: #6b7280;
                }

                .perm-toggle.off:hover {
                    background: rgba(34, 197, 94, .08);
                    color: #22c55e;
                }

                .perm-toggle.locked {
                    opacity: .5;
                    cursor: not-allowed;
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
                            <h1 class="topbar-title"><i class="fa-solid fa-shield-halved"></i> Phân quyền RBAC</h1>
                            <div class="topbar-right"><span class="badge-role">${sessionScope.user.role.name}</span>
                            </div>
                        </header>

                        <div class="content">
                            <c:if test="${not empty sessionScope.flash_msg}">
                                <div class="alert alert-success"><i class="fa-solid fa-check-circle"></i>
                                    ${sessionScope.flash_msg}</div>
                                <c:remove var="flash_msg" scope="session" />
                            </c:if>

                            <div class="page-header">
                                <div class="page-header-left">
                                    <h2>Ma trận phân quyền</h2>
                                    <p>Quản lý quyền truy cập theo vai trò. Admin luôn có toàn quyền.</p>
                                </div>
                            </div>

                            <div class="table-card" style="overflow-x:auto">
                                <table class="perm-matrix">
                                    <thead>
                                        <tr>
                                            <th>Quyền</th>
                                            <th>ADMIN</th>
                                            <th>STAFF</th>
                                            <th>CASHIER</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%-- Dashboard --%>
                                            <tr class="group-row">
                                                <td colspan="4"><i class="fa-solid fa-chart-pie"></i> Dashboard</td>
                                            </tr>
                                            <tr>
                                                <td>dashboard.view</td>
                                                <td><span class="perm-toggle on locked"><i
                                                            class="fa-solid fa-check"></i></span></td>
                                                <td><span class="perm-toggle on"><i
                                                            class="fa-solid fa-check"></i></span></td>
                                                <td><span class="perm-toggle on"><i
                                                            class="fa-solid fa-check"></i></span></td>
                                            </tr>

                                            <%-- Categories --%>
                                                <tr class="group-row">
                                                    <td colspan="4"><i class="fa-solid fa-tags"></i> Danh mục</td>
                                                </tr>
                                                <c:forEach var="p"
                                                    items="${['categories.view','categories.create','categories.update','categories.delete']}">
                                                    <tr>
                                                        <td>${p}</td>
                                                        <td><span class="perm-toggle on locked"><i
                                                                    class="fa-solid fa-check"></i></span></td>
                                                        <td>
                                                            <form method="post" action="${ctx}/admin/rbac/toggle"
                                                                style="display:inline">
                                                                <input type="hidden" name="role" value="STAFF">
                                                                <input type="hidden" name="permission" value="${p}">
                                                                <button type="submit"
                                                                    class="perm-toggle ${rolePerms['STAFF'].contains(p) ? 'on' : 'off'}">
                                                                    <i
                                                                        class="fa-solid ${rolePerms['STAFF'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                </button>
                                                            </form>
                                                        </td>
                                                        <td>
                                                            <form method="post" action="${ctx}/admin/rbac/toggle"
                                                                style="display:inline">
                                                                <input type="hidden" name="role" value="CASHIER">
                                                                <input type="hidden" name="permission" value="${p}">
                                                                <button type="submit"
                                                                    class="perm-toggle ${rolePerms['CASHIER'].contains(p) ? 'on' : 'off'}">
                                                                    <i
                                                                        class="fa-solid ${rolePerms['CASHIER'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                </button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>

                                                <%-- Menu --%>
                                                    <tr class="group-row">
                                                        <td colspan="4"><i class="fa-solid fa-bowl-food"></i> Thực đơn
                                                        </td>
                                                    </tr>
                                                    <c:forEach var="p"
                                                        items="${['menu.view','menu.create','menu.update','menu.delete','menu.toggle_status']}">
                                                        <tr>
                                                            <td>${p}</td>
                                                            <td><span class="perm-toggle on locked"><i
                                                                        class="fa-solid fa-check"></i></span></td>
                                                            <td>
                                                                <form method="post" action="${ctx}/admin/rbac/toggle"
                                                                    style="display:inline">
                                                                    <input type="hidden" name="role"
                                                                        value="STAFF"><input type="hidden"
                                                                        name="permission" value="${p}">
                                                                    <button type="submit"
                                                                        class="perm-toggle ${rolePerms['STAFF'].contains(p) ? 'on' : 'off'}">
                                                                        <i
                                                                            class="fa-solid ${rolePerms['STAFF'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                    </button>
                                                                </form>
                                                            </td>
                                                            <td>
                                                                <form method="post" action="${ctx}/admin/rbac/toggle"
                                                                    style="display:inline">
                                                                    <input type="hidden" name="role"
                                                                        value="CASHIER"><input type="hidden"
                                                                        name="permission" value="${p}">
                                                                    <button type="submit"
                                                                        class="perm-toggle ${rolePerms['CASHIER'].contains(p) ? 'on' : 'off'}">
                                                                        <i
                                                                            class="fa-solid ${rolePerms['CASHIER'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                    </button>
                                                                </form>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>

                                                    <%-- Tables --%>
                                                        <tr class="group-row">
                                                            <td colspan="4"><i class="fa-solid fa-chair"></i> Bàn</td>
                                                        </tr>
                                                        <c:forEach var="p"
                                                            items="${['tables.view','tables.create','tables.update','tables.update_status']}">
                                                            <tr>
                                                                <td>${p}</td>
                                                                <td><span class="perm-toggle on locked"><i
                                                                            class="fa-solid fa-check"></i></span></td>
                                                                <td>
                                                                    <form method="post"
                                                                        action="${ctx}/admin/rbac/toggle"
                                                                        style="display:inline">
                                                                        <input type="hidden" name="role"
                                                                            value="STAFF"><input type="hidden"
                                                                            name="permission" value="${p}">
                                                                        <button type="submit"
                                                                            class="perm-toggle ${rolePerms['STAFF'].contains(p) ? 'on' : 'off'}">
                                                                            <i
                                                                                class="fa-solid ${rolePerms['STAFF'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                        </button>
                                                                    </form>
                                                                </td>
                                                                <td>
                                                                    <form method="post"
                                                                        action="${ctx}/admin/rbac/toggle"
                                                                        style="display:inline">
                                                                        <input type="hidden" name="role"
                                                                            value="CASHIER"><input type="hidden"
                                                                            name="permission" value="${p}">
                                                                        <button type="submit"
                                                                            class="perm-toggle ${rolePerms['CASHIER'].contains(p) ? 'on' : 'off'}">
                                                                            <i
                                                                                class="fa-solid ${rolePerms['CASHIER'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                        </button>
                                                                    </form>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>

                                                        <%-- Orders --%>
                                                            <tr class="group-row">
                                                                <td colspan="4"><i
                                                                        class="fa-solid fa-clipboard-list"></i> Order
                                                                </td>
                                                            </tr>
                                                            <c:forEach var="p"
                                                                items="${['order.view','order.create','order.update','order.cancel']}">
                                                                <tr>
                                                                    <td>${p}</td>
                                                                    <td><span class="perm-toggle on locked"><i
                                                                                class="fa-solid fa-check"></i></span>
                                                                    </td>
                                                                    <td>
                                                                        <form method="post"
                                                                            action="${ctx}/admin/rbac/toggle"
                                                                            style="display:inline">
                                                                            <input type="hidden" name="role"
                                                                                value="STAFF"><input type="hidden"
                                                                                name="permission" value="${p}">
                                                                            <button type="submit"
                                                                                class="perm-toggle ${rolePerms['STAFF'].contains(p) ? 'on' : 'off'}">
                                                                                <i
                                                                                    class="fa-solid ${rolePerms['STAFF'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                            </button>
                                                                        </form>
                                                                    </td>
                                                                    <td>
                                                                        <form method="post"
                                                                            action="${ctx}/admin/rbac/toggle"
                                                                            style="display:inline">
                                                                            <input type="hidden" name="role"
                                                                                value="CASHIER"><input type="hidden"
                                                                                name="permission" value="${p}">
                                                                            <button type="submit"
                                                                                class="perm-toggle ${rolePerms['CASHIER'].contains(p) ? 'on' : 'off'}">
                                                                                <i
                                                                                    class="fa-solid ${rolePerms['CASHIER'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                            </button>
                                                                        </form>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>

                                                            <%-- Invoices --%>
                                                                <tr class="group-row">
                                                                    <td colspan="4"><i
                                                                            class="fa-solid fa-file-invoice-dollar"></i>
                                                                        Hóa đơn</td>
                                                                </tr>
                                                                <c:forEach var="p"
                                                                    items="${['invoice.view','invoice.pay','invoice.refund','invoice.void']}">
                                                                    <tr>
                                                                        <td>${p}</td>
                                                                        <td><span class="perm-toggle on locked"><i
                                                                                    class="fa-solid fa-check"></i></span>
                                                                        </td>
                                                                        <td>
                                                                            <form method="post"
                                                                                action="${ctx}/admin/rbac/toggle"
                                                                                style="display:inline">
                                                                                <input type="hidden" name="role"
                                                                                    value="STAFF"><input type="hidden"
                                                                                    name="permission" value="${p}">
                                                                                <button type="submit"
                                                                                    class="perm-toggle ${rolePerms['STAFF'].contains(p) ? 'on' : 'off'}">
                                                                                    <i
                                                                                        class="fa-solid ${rolePerms['STAFF'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                                </button>
                                                                            </form>
                                                                        </td>
                                                                        <td>
                                                                            <form method="post"
                                                                                action="${ctx}/admin/rbac/toggle"
                                                                                style="display:inline">
                                                                                <input type="hidden" name="role"
                                                                                    value="CASHIER"><input type="hidden"
                                                                                    name="permission" value="${p}">
                                                                                <button type="submit"
                                                                                    class="perm-toggle ${rolePerms['CASHIER'].contains(p) ? 'on' : 'off'}">
                                                                                    <i
                                                                                        class="fa-solid ${rolePerms['CASHIER'].contains(p) ? 'fa-check' : 'fa-xmark'}"></i>
                                                                                </button>
                                                                            </form>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
            </div>

            <script>
                function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }
            </script>
        </body>

        </html>