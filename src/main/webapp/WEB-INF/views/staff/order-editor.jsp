<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <c:set var="ctx" value="${pageContext.request.contextPath}" />
            <c:set var="sidebarActive" value="orders" />
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>
                    <c:choose>
                        <c:when test="${not empty order}">Order #${order.id} — ${order.table.tableName}</c:when>
                        <c:otherwise>Quản lý Order — Staff</c:otherwise>
                    </c:choose>
                </title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <style>
                    .order-layout {
                        display: grid;
                        grid-template-columns: 1fr 340px;
                        gap: 20px;
                        align-items: start;
                    }

                    .menu-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                        gap: 12px;
                        margin-top: 16px;
                    }

                    .menu-card {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: 12px;
                        padding: 14px 12px;
                        cursor: pointer;
                        transition: all .18s;
                        text-align: center;
                    }

                    .menu-card:hover {
                        border-color: var(--primary);
                        background: var(--primary-bg);
                    }

                    .menu-card-name {
                        font-size: 13px;
                        font-weight: 600;
                        margin-bottom: 4px;
                        color: var(--text);
                    }

                    .menu-card-price {
                        font-size: 12px;
                        color: var(--primary);
                        font-weight: 700;
                    }

                    .order-panel {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: 14px;
                        position: sticky;
                        top: 80px;
                    }

                    .order-panel-header {
                        padding: 16px 20px;
                        border-bottom: 1px solid var(--border);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                    }

                    .order-items {
                        padding: 16px 20px;
                        max-height: 380px;
                        overflow-y: auto;
                    }

                    .order-item-row {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 8px 0;
                        border-bottom: 1px solid var(--border);
                        font-size: 13px;
                    }

                    .order-item-row:last-child {
                        border-bottom: none;
                    }

                    .order-item-name {
                        flex: 1;
                        font-weight: 500;
                    }

                    .order-item-price {
                        color: var(--primary);
                        font-weight: 600;
                        white-space: nowrap;
                    }

                    .order-total-bar {
                        padding: 14px 20px;
                        border-top: 1px solid var(--border);
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        font-weight: 700;
                    }

                    .cat-tabs {
                        display: flex;
                        gap: 8px;
                        flex-wrap: wrap;
                        margin-bottom: 4px;
                    }

                    .cat-tab {
                        padding: 6px 14px;
                        border-radius: 8px;
                        font-size: 12px;
                        font-weight: 600;
                        cursor: pointer;
                        background: var(--surface2);
                        border: 1px solid var(--border);
                        color: var(--text-muted);
                        transition: all .15s;
                        font-family: inherit;
                    }

                    .cat-tab.active,
                    .cat-tab:hover {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    @media(max-width: 860px) {
                        .order-layout {
                            grid-template-columns: 1fr;
                        }
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
                                <h1 class="topbar-title">
                                    <i class="fa-solid fa-clipboard-list"></i>
                                    <c:choose>
                                        <c:when test="${not empty order}">
                                            Order #${order.id}
                                            <span
                                                style="font-size:13px;font-weight:400;color:var(--text-muted);margin-left:6px">
                                                — ${order.table.tableName}
                                            </span>
                                        </c:when>
                                        <c:otherwise>Quản lý Order</c:otherwise>
                                    </c:choose>
                                </h1>
                                <div class="topbar-right">
                                    <a href="${ctx}/staff" class="btn btn-ghost btn-sm">
                                        <i class="fa-solid fa-map"></i> Sơ đồ bàn
                                    </a>
                                    <span class="badge-role">${sessionScope.user.role.name}</span>
                                </div>
                            </header>

                            <div class="content">

                                <%-- Flash --%>
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

                                    <c:choose>
                                        <%--======SINGLE ORDER VIEW (from table-map click)======--%>
                                            <c:when test="${not empty order}">
                                                <div class="order-layout">

                                                    <%-- Left: Menu --%>
                                                        <div>
                                                            <div class="page-header" style="margin-bottom:12px">
                                                                <div class="page-header-left">
                                                                    <h2>Chọn món</h2>
                                                                    <p>Thêm món vào order #${order.id} —
                                                                        ${order.table.tableName}</p>
                                                                </div>
                                                                <span
                                                                    class="badge ${order.status=='OPEN'?'b-info':order.status=='SERVED'?'b-success':'b-primary'}"
                                                                    style="font-size:13px;padding:6px 14px">
                                                                    ${order.status}
                                                                </span>
                                                            </div>

                                                            <%-- Category tabs --%>
                                                                <div class="cat-tabs" id="catTabs">
                                                                    <button class="cat-tab active"
                                                                        onclick="filterCat('', this)">Tất cả</button>
                                                                    <c:forEach var="cat" items="${categories}">
                                                                        <button class="cat-tab"
                                                                            onclick="filterCat('${cat.id}', this)">
                                                                            <c:out value="${cat.categoryName}" />
                                                                        </button>
                                                                    </c:forEach>
                                                                </div>

                                                                <%-- Menu cards --%>
                                                                    <div class="menu-grid" id="menuGrid">
                                                                        <c:forEach var="p" items="${products}">
                                                                            <div class="menu-card"
                                                                                data-cat="${p.category.id}"
                                                                                onclick="addItem(${order.id}, ${p.id}, '${p.productName}')">
                                                                                <div class="menu-card-name">
                                                                                    <c:out value="${p.productName}" />
                                                                                </div>
                                                                                <div class="menu-card-price">
                                                                                    <fmt:formatNumber value="${p.price}"
                                                                                        pattern="#,###" />đ
                                                                                </div>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                        </div>

                                                        <%-- Right: Order panel --%>
                                                            <div class="order-panel">
                                                                <div class="order-panel-header">
                                                                    <span style="font-weight:700;font-size:15px">
                                                                        <i class="fa-solid fa-receipt"
                                                                            style="color:var(--primary)"></i>
                                                                        Order #${order.id}
                                                                    </span>
                                                                    <span
                                                                        style="font-size:12px;color:var(--text-muted)">${order.table.tableName}</span>
                                                                </div>

                                                                <div class="order-items">
                                                                    <c:choose>
                                                                        <c:when test="${empty order.orderDetails}">
                                                                            <p
                                                                                style="text-align:center;color:var(--text-muted);padding:2rem 0;font-size:13px">
                                                                                Chưa có món nào
                                                                            </p>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <c:forEach var="d"
                                                                                items="${order.orderDetails}">
                                                                                <c:if
                                                                                    test="${d.itemStatus != 'CANCELLED'}">
                                                                                    <div class="order-item-row">
                                                                                        <div class="order-item-name">
                                                                                            <c:if
                                                                                                test="${d.itemStatus == 'PENDING'}">
                                                                                                <i class="fa-solid fa-clock"
                                                                                                    style="color:#f59e0b; font-size:10px; margin-right:4px"
                                                                                                    title="Chưa gửi bếp"></i>
                                                                                            </c:if>
                                                                                            <c:out
                                                                                                value="${d.product.productName}" />
                                                                                            <span
                                                                                                style="color:var(--text-muted);font-size:12px">
                                                                                                x${d.quantity}
                                                                                            </span>
                                                                                        </div>
                                                                                        <div class="order-item-price">
                                                                                            <fmt:formatNumber
                                                                                                value="${d.unitPrice}"
                                                                                                pattern="#,###" />đ
                                                                                        </div>
                                                                                        <c:choose>
                                                                                            <%-- If item is PENDING,
                                                                                                staff can remove
                                                                                                directly --%>
                                                                                                <c:when
                                                                                                    test="${d.itemStatus == 'PENDING'}">
                                                                                                    <form method="post"
                                                                                                        action="${ctx}/staff/orders"
                                                                                                        style="margin:0">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="removeItem">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="orderDetailId"
                                                                                                            value="${d.id}">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="orderId"
                                                                                                            value="${order.id}">
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            class="btn btn-ghost btn-sm"
                                                                                                            style="color:var(--destructive);padding:3px 7px"
                                                                                                            title="Xóa món">
                                                                                                            <i
                                                                                                                class="fa-solid fa-xmark"></i>
                                                                                                        </button>
                                                                                                    </form>
                                                                                                </c:when>
                                                                                                <%-- If item is ORDERED,
                                                                                                    staff must provide a
                                                                                                    reason to remove
                                                                                                    --%>
                                                                                                    <c:when
                                                                                                        test="${d.itemStatus == 'ORDERED'}">
                                                                                                        <button
                                                                                                            type="button"
                                                                                                            class="btn btn-ghost btn-sm"
                                                                                                            style="color:var(--destructive);padding:3px 7px"
                                                                                                            title="Xóa món (đã gửi bếp - cần lý do)"
                                                                                                            onclick="openRemoveModal(${d.id}, '${d.product.productName}')">
                                                                                                            <i
                                                                                                                class="fa-solid fa-eraser"></i>
                                                                                                        </button>
                                                                                                    </c:when>
                                                                                        </c:choose>
                                                                                    </div>
                                                                                </c:if>
                                                                            </c:forEach>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>

                                                                <div class="order-total-bar">
                                                                    <span>Tổng cộng</span>
                                                                    <span style="color:var(--primary);font-size:17px">
                                                                        <fmt:formatNumber value="${order.totalAmount}"
                                                                            pattern="#,###" />đ
                                                                    </span>
                                                                </div>

                                                                <%-- Staff actions: OPEN=add/confirm; SERVED=waiting
                                                                    cashier --%>
                                                                    <c:if test="${order.status == 'OPEN'}">
                                                                        <div
                                                                            style="padding:0 20px 16px;display:flex;flex-direction:column;gap:10px">
                                                                            <c:set var="hasPending" value="false" />
                                                                            <c:forEach var="item"
                                                                                items="${order.orderDetails}">
                                                                                <c:if
                                                                                    test="${item.itemStatus == 'PENDING'}">
                                                                                    <c:set var="hasPending"
                                                                                        value="true" />
                                                                                </c:if>
                                                                            </c:forEach>

                                                                            <form method="post"
                                                                                action="${ctx}/staff/orders"
                                                                                style="margin:0">
                                                                                <input type="hidden" name="action"
                                                                                    value="confirmItems">
                                                                                <input type="hidden" name="orderId"
                                                                                    value="${order.id}">
                                                                                <button type="submit"
                                                                                    class="btn btn-warning"
                                                                                    style="width:100%;justify-content:center"
                                                                                    ${!hasPending ? 'disabled' : '' }>
                                                                                    <i class="fa-solid fa-utensils"></i>
                                                                                    Xác nhận gửi bếp
                                                                                </button>
                                                                            </form>

                                                                            <div
                                                                                style="text-align:center;border:1px dashed var(--border);border-radius:10px;padding:12px;margin-top:5px">
                                                                                <p
                                                                                    style="font-size:11px;color:#6b7280;margin:0">
                                                                                    <i class="fa-solid fa-receipt"></i>
                                                                                    Vui lòng yêu cầu thanh toán tại
                                                                                    <strong>Sơ đồ bàn</strong>.
                                                                                </p>
                                                                            </div>
                                                                        </div>
                                                                    </c:if>

                                                                    <c:if test="${order.status == 'SERVED'}">
                                                                        <div style="padding:0 20px 16px">
                                                                            <div
                                                                                style="background:rgba(34,197,94,0.1);border:1px solid rgba(34,197,94,0.25);border-radius:10px;padding:12px 14px;text-align:center">
                                                                                <div
                                                                                    style="color:#22c55e;font-weight:700;font-size:13px;margin-bottom:4px">
                                                                                    <i class="fa-solid fa-clock"></i>
                                                                                    Đang chờ thanh toán
                                                                                </div>
                                                                                <div
                                                                                    style="color:var(--text-muted);font-size:11px">
                                                                                    Cashier sẽ xử lý thanh toán bàn này
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </c:if>

                                                                    <c:if test="${order.status == 'PAID'}">
                                                                        <div style="padding:0 20px 16px">
                                                                            <div class="alert alert-success"
                                                                                style="margin:0;justify-content:center">
                                                                                <i class="fa-solid fa-check-circle"></i>
                                                                                Đã thanh toán
                                                                            </div>
                                                                        </div>
                                                                    </c:if>
                                                            </div>

                                                </div>

                                                <%-- Hidden form for add item --%>
                                                    <form id="addItemForm" method="post" action="${ctx}/staff/orders"
                                                        style="display:none">
                                                        <input type="hidden" name="action" value="addItem">
                                                        <input type="hidden" name="orderId" value="${order.id}">
                                                        <input type="hidden" name="productId" id="addProductId">
                                                        <input type="hidden" name="quantity" id="addQuantity" value="1">
                                                    </form>

                                                    <%-- Hidden form for remove item with reason --%>
                                                        <form id="removeItemForm" method="post"
                                                            action="${ctx}/staff/orders" style="display:none">
                                                            <input type="hidden" name="action" value="removeItem">
                                                            <input type="hidden" name="orderId" value="${order.id}">
                                                            <input type="hidden" name="orderDetailId"
                                                                id="removeDetailId">
                                                            <input type="hidden" name="cancelReason"
                                                                id="removeCancelReason">
                                                        </form>
                                            </c:when>

                                            <%--======ALL ACTIVE ORDERS LIST======--%>
                                                <c:otherwise>
                                                    <div class="page-header">
                                                        <div class="page-header-left">
                                                            <h2>Danh sách Order đang mở</h2>
                                                            <p>Tất cả order chưa thanh toán</p>
                                                        </div>
                                                        <a href="${ctx}/staff" class="btn btn-ghost">
                                                            <i class="fa-solid fa-map"></i> Sơ đồ bàn
                                                        </a>
                                                    </div>
                                                    <div class="table-card">
                                                        <table class="admin-table">
                                                            <thead>
                                                                <tr>
                                                                    <th>Order ID</th>
                                                                    <th>Bàn</th>
                                                                    <th>Số món</th>
                                                                    <th style="text-align:right">Tổng</th>
                                                                    <th>Trạng thái</th>
                                                                    <th>Thời gian</th>
                                                                    <th>Thao tác</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="o" items="${activeOrders}">
                                                                    <tr>
                                                                        <td style="font-weight:600">#${o.id}</td>
                                                                        <td><i class="fa-solid fa-chair"
                                                                                style="color:var(--primary)"></i>
                                                                            ${o.table.tableName}</td>
                                                                        <td>${o.orderDetails.size()}</td>
                                                                        <td style="text-align:right;font-weight:600">
                                                                            <fmt:formatNumber value="${o.totalAmount}"
                                                                                pattern="#,###" /> đ
                                                                        </td>
                                                                        <td>
                                                                            <span
                                                                                class="badge ${o.status=='OPEN'?'b-info':o.status=='SERVED'?'b-success':o.status=='PAID'?'b-primary':'b-muted'}">
                                                                                ${o.status}
                                                                            </span>
                                                                        </td>
                                                                        <td
                                                                            style="color:var(--text-muted);font-size:12px">
                                                                            ${o.openedAt}</td>
                                                                        <td>
                                                                            <a href="${ctx}/staff/orders?orderId=${o.id}"
                                                                                class="btn btn-ghost btn-sm">
                                                                                <i class="fa-solid fa-pen"></i> Xem
                                                                            </a>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                                <c:if test="${empty activeOrders}">
                                                                    <tr>
                                                                        <td colspan="7" class="empty-state">
                                                                            <i class="fa-solid fa-clipboard"></i>
                                                                            <h3>Chưa có order nào đang mở</h3>
                                                                            <p>Vào sơ đồ bàn và chọn bàn để tạo order
                                                                                mới</p>
                                                                        </td>
                                                                    </tr>
                                                                </c:if>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </c:otherwise>
                                    </c:choose>

                            </div>
                        </div>
                </div>

                <%-- Quantity Selection Modal --%>
                    <div id="qtyModal" class="modal">
                        <div class="modal-content" style="max-width:320px">
                            <div class="modal-header">
                                <h3 id="qtyModalTitle" style="font-size:16px">Số lượng</h3>
                                <button type="button" class="btn-close" onclick="closeQtyModal()">&times;</button>
                            </div>
                            <div class="modal-body">
                                <div
                                    style="display:flex; align-items:center; gap:15px; justify-content:center; margin:10px 0">
                                    <button type="button" class="btn btn-ghost"
                                        style="font-size:20px; width:45px; height:45px; padding:0"
                                        onclick="document.getElementById('qtyInput').stepDown()">-</button>
                                    <input type="number" id="qtyInput" class="form-control" value="1" min="1"
                                        style="width:80px; text-align:center; font-size:22px; font-weight:700; border:none; background:transparent">
                                    <button type="button" class="btn btn-ghost"
                                        style="font-size:20px; width:45px; height:45px; padding:0"
                                        onclick="document.getElementById('qtyInput').stepUp()">+</button>
                                </div>
                            </div>
                            <div class="modal-footer" style="padding-top:10px">
                                <button type="button" class="btn btn-primary"
                                    style="width:100%; height:45px; font-weight:700" onclick="submitAddWithQty()">
                                    <i class="fa-solid fa-plus"></i> THÊM VÀO ORDER
                                </button>
                            </div>
                        </div>
                    </div>

                    <%-- Removal Modal --%>
                        <div id="removeModal" class="modal">
                            <div class="modal-content" style="max-width:400px">
                                <div class="modal-header">
                                    <h3>Xóa món (Gửi bếp)</h3>
                                    <button type="button" class="btn-close"
                                        onclick="closeRemoveModal()">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <p style="margin-bottom:12px; font-size:13px">Bạn đang xóa món <strong
                                            id="removeProductName"></strong> đã được gửi tới bếp. Vui lòng nhập lý do:
                                    </p>
                                    <textarea id="cancelReasonInput" class="form-control" rows="3"
                                        placeholder="Ví dụ: Khách đổi ý, Hết nguyên liệu..."></textarea>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-ghost"
                                        onclick="closeRemoveModal()">Hủy</button>
                                    <button type="button" class="btn btn-primary" onclick="submitRemoveItem()">Xác nhận
                                        xóa</button>
                                </div>
                            </div>
                        </div>

                        <style>
                            /* Basic Modal Styles */
                            .modal {
                                display: none;
                                position: fixed;
                                z-index: 1000;
                                left: 0;
                                top: 0;
                                width: 100%;
                                height: 100%;
                                background: rgba(0, 0, 0, 0.5);
                                align-items: center;
                                justify-content: center;
                            }

                            .modal.active {
                                display: flex;
                            }

                            .modal-content {
                                background: var(--surface);
                                padding: 20px;
                                border-radius: 12px;
                                border: 1px solid var(--border);
                                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                                width: 90%;
                            }

                            .modal-header {
                                display: flex;
                                justify-content: space-between;
                                align-items: center;
                                margin-bottom: 15px;
                            }

                            .btn-close {
                                background: none;
                                border: none;
                                font-size: 24px;
                                color: var(--text-muted);
                                cursor: pointer;
                            }
                        </style>

                        <script>
                            function openSidebar() {
                                document.getElementById('sidebar').classList.add('open');
                                document.getElementById('sidebarOverlay').classList.add('active');
                            }
                            function closeSidebar() {
                                document.getElementById('sidebar').classList.remove('open');
                                document.getElementById('sidebarOverlay').classList.remove('active');
                            }

                            function closeQtyModal() {
                                document.getElementById('qtyModal').classList.remove('active');
                            }

                            function addItem(orderId, productId, productName) {
                                document.getElementById('addProductId').value = productId;
                                document.getElementById('qtyModalTitle').innerText = productName;
                                document.getElementById('qtyInput').value = 1;
                                document.getElementById('qtyModal').classList.add('active');
                            }

                            function submitAddWithQty() {
                                const qty = document.getElementById('qtyInput').value;
                                if (qty <= 0) {
                                    alert('Số lượng phải lớn hơn 0');
                                    return;
                                }
                                document.getElementById('addQuantity').value = qty;
                                document.getElementById('addItemForm').submit();
                            }

                            function filterCat(catId, btn) {
                                document.querySelectorAll('.cat-tab').forEach(t => t.classList.remove('active'));
                                btn.classList.add('active');
                                document.querySelectorAll('.menu-card').forEach(card => {
                                    card.style.display = (!catId || card.dataset.cat == catId) ? '' : 'none';
                                });
                            }

                            function openRemoveModal(detailId, productName) {
                                document.getElementById('removeDetailId').value = detailId;
                                document.getElementById('removeProductName').innerText = productName;
                                document.getElementById('cancelReasonInput').value = '';
                                document.getElementById('removeModal').classList.add('active');
                            }

                            function closeRemoveModal() {
                                document.getElementById('removeModal').classList.remove('active');
                            }

                            function submitRemoveItem() {
                                const reason = document.getElementById('cancelReasonInput').value.trim();
                                if (!reason) {
                                    alert('Vui lòng nhập lý do xóa món');
                                    return;
                                }
                                document.getElementById('removeCancelReason').value = reason;
                                document.getElementById('removeItemForm').submit();
                            }
                        </script>
            </body>

            </html>