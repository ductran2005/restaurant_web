<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="bookings" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Tìm Booking — Staff</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
            <style>
                .booking-card {
                    background: var(--surface);
                    border: 1px solid var(--border);
                    border-radius: 14px;
                    padding: 20px;
                    margin-bottom: 16px;
                    transition: all .2s
                }

                .booking-card:hover {
                    border-color: var(--primary)
                }

                .booking-card-header {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    margin-bottom: 12px;
                    gap: 8px;
                    flex-wrap: wrap
                }

                .booking-code {
                    font-size: 16px;
                    font-weight: 700;
                    color: var(--primary)
                }

                .booking-meta {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                    gap: 10px;
                    margin-bottom: 14px
                }

                .meta-item {
                    font-size: 13px;
                    color: var(--text-muted)
                }

                .meta-item strong {
                    color: var(--text);
                    display: block;
                    margin-top: 2px
                }

                .booking-actions {
                    display: flex;
                    gap: 8px;
                    flex-wrap: wrap
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
                            <h1 class="topbar-title"><i class="fa-solid fa-calendar-check"></i> Tìm Booking</h1>
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
                                    <h2>Tra cứu & Check-in</h2>
                                    <p>Tìm booking theo mã hoặc SĐT khách hàng</p>
                                </div>
                            </div>

                            <%-- Search --%>
                                <form method="get" action="${ctx}/staff/bookings"
                                    style="display:flex;gap:12px;margin-bottom:24px;flex-wrap:wrap">
                                    <div class="search-wrap" style="flex:1;min-width:200px">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" name="q" class="search-input" style="width:100%"
                                            placeholder="Mã booking hoặc SĐT..." value="${param.q}" autofocus>
                                    </div>
                                    <select name="status" class="form-control" style="width:160px">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="PENDING" ${param.status=='PENDING' ?'selected':''}>Chờ xác nhận
                                        </option>
                                        <option value="CONFIRMED" ${param.status=='CONFIRMED' ?'selected':''}>Đã xác
                                            nhận</option>
                                        <option value="CHECKED_IN" ${param.status=='CHECKED_IN' ?'selected':''}>Đã
                                            check-in</option>
                                    </select>
                                    <input type="date" name="date" class="form-control" style="width:160px"
                                        value="${param.date}">
                                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-search"></i>
                                        Tìm</button>
                                </form>

                                <%-- Results --%>
                                    <c:forEach var="b" items="${bookings}">
                                        <div class="booking-card">
                                            <div class="booking-card-header">
                                                <span class="booking-code"><i class="fa-solid fa-ticket"></i>
                                                    ${b.bookingCode}</span>
                                                <span
                                                    class="badge ${b.status=='PENDING'?'b-warning':b.status=='CONFIRMED'?'b-success':b.status=='CHECKED_IN'?'b-info':b.status=='CANCELLED'?'b-danger':'b-muted'}">
                                                    ${b.status}
                                                </span>
                                            </div>
                                            <div class="booking-meta">
                                                <div class="meta-item"><i class="fa-solid fa-user"></i>
                                                    Khách<strong>${b.customerName}</strong></div>
                                                <div class="meta-item"><i class="fa-solid fa-phone"></i>
                                                    SĐT<strong>${b.customerPhone}</strong></div>
                                                <div class="meta-item"><i class="fa-solid fa-calendar"></i>
                                                    Ngày<strong>${b.bookingDate}</strong></div>
                                                <div class="meta-item"><i class="fa-solid fa-clock"></i>
                                                    Giờ<strong>${b.bookingTime}</strong></div>
                                                <div class="meta-item"><i class="fa-solid fa-users"></i> Số
                                                    khách<strong>${b.partySize} người</strong></div>
                                                <c:if test="${not empty b.tableName}">
                                                    <div class="meta-item"><i class="fa-solid fa-chair"></i>
                                                        Bàn<strong>${b.tableName}</strong></div>
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty b.note}">
                                                <p
                                                    style="font-size:13px;color:var(--text-muted);margin-bottom:12px;padding:8px 12px;background:var(--surface2);border-radius:8px">
                                                    <i class="fa-solid fa-sticky-note" style="color:var(--primary)"></i>
                                                    ${b.note}
                                                </p>
                                            </c:if>
                                            <div class="booking-actions">
                                                <c:if test="${b.status == 'PENDING'}">
                                                    <form method="post" action="${ctx}/staff/bookings/confirm"
                                                        style="display:inline">
                                                        <input type="hidden" name="bookingId" value="${b.id}">
                                                        <button type="submit" class="btn btn-primary btn-sm"><i
                                                                class="fa-solid fa-check"></i> Xác nhận</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${b.status == 'CONFIRMED'}">
                                                    <form method="post" action="${ctx}/staff/bookings/checkin"
                                                        style="display:inline">
                                                        <input type="hidden" name="bookingId" value="${b.id}">
                                                        <button type="submit" class="btn btn-primary btn-sm"><i
                                                                class="fa-solid fa-right-to-bracket"></i>
                                                            Check-in</button>
                                                    </form>
                                                    <button class="btn btn-ghost btn-sm"
                                                        onclick="openAssignModal(${b.id}, '${b.bookingCode}', ${b.partySize})">
                                                        <i class="fa-solid fa-chair"></i> Gán bàn
                                                    </button>
                                                </c:if>
                                                <c:if test="${b.status == 'PENDING' || b.status == 'CONFIRMED'}">
                                                    <button class="btn btn-ghost btn-sm"
                                                        style="color:var(--destructive)"
                                                        onclick="openCancelModal(${b.id}, '${b.bookingCode}')">
                                                        <i class="fa-solid fa-xmark"></i> Hủy
                                                    </button>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${not empty param.q && empty bookings}">
                                        <div class="empty-state"><i class="fa-solid fa-magnifying-glass"></i>
                                            <h3>Không tìm thấy booking</h3>
                                            <p>Thử thay đổi từ khóa tìm kiếm</p>
                                        </div>
                                    </c:if>
                        </div>
                    </div>
            </div>

            <%-- Assign Table Modal --%>
                <div class="modal-overlay" id="assignModal">
                    <div class="modal">
                        <div class="modal-header">
                            <h3 class="modal-title">Gán bàn</h3><button class="btn btn-ghost btn-sm"
                                onclick="closeModal('assignModal')"><i class="fa-solid fa-xmark"></i></button>
                        </div>
                        <form method="post" action="${ctx}/staff/bookings/assign-table" id="assignForm">
                            <input type="hidden" name="bookingId" id="assignBookingId">
                            <div class="modal-body">
                                <p style="color:var(--text-muted);font-size:13px;margin-bottom:16px" id="assignDesc">
                                </p>
                                <div class="form-group">
                                    <label class="form-label">Chọn bàn</label>
                                    <select name="tableId" class="form-control" required>
                                        <option value="">-- Chọn bàn --</option>
                                        <c:forEach var="t" items="${availableTables}">
                                            <option value="${t.id}">${t.tableName} (${t.capacity} chỗ) —
                                                ${t.area.areaName}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                    onclick="closeModal('assignModal')">Hủy</button><button type="submit"
                                    class="btn btn-primary">Gán bàn</button></div>
                        </form>
                    </div>
                </div>

                <%-- Cancel Modal --%>
                    <div class="modal-overlay" id="cancelModal">
                        <div class="modal">
                            <div class="modal-header">
                                <h3 class="modal-title">Hủy booking</h3><button class="btn btn-ghost btn-sm"
                                    onclick="closeModal('cancelModal')"><i class="fa-solid fa-xmark"></i></button>
                            </div>
                            <form method="post" action="${ctx}/staff/bookings/cancel" id="cancelForm">
                                <input type="hidden" name="bookingId" id="cancelBookingId">
                                <div class="modal-body">
                                    <p style="color:var(--text-muted);font-size:13px;margin-bottom:16px"
                                        id="cancelDesc"></p>
                                    <div class="form-group"><label class="form-label">Lý do hủy <span
                                                style="color:var(--destructive)">*</span></label><textarea name="reason"
                                            class="form-control" rows="3" required
                                            placeholder="Nhập lý do..."></textarea></div>
                                </div>
                                <div class="modal-footer"><button type="button" class="btn btn-ghost"
                                        onclick="closeModal('cancelModal')">Quay lại</button><button type="submit"
                                        class="btn btn-danger">Xác nhận hủy</button></div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openModal(id) { document.getElementById(id).classList.add('active') }
                        function closeModal(id) { document.getElementById(id).classList.remove('active') }
                        function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active') }
                        function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active') }
                        function openAssignModal(id, code, size) { document.getElementById('assignBookingId').value = id; document.getElementById('assignDesc').textContent = 'Gán bàn cho booking ' + code + ' (' + size + ' khách)'; openModal('assignModal') }
                        function openCancelModal(id, code) { document.getElementById('cancelBookingId').value = id; document.getElementById('cancelDesc').textContent = 'Hủy booking ' + code + '?'; openModal('cancelModal') }
                    </script>
        </body>

        </html>