<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <c:set var="sidebarActive" value="config" />
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Cấu hình hệ thống — Admin</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
                <link rel="stylesheet" href="${ctx}/assets/css/mobile.css">
        </head>

        <body>
            <div class="shell">
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
                <%@ include file="/WEB-INF/views/admin/_sidebar.jsp" %>

                    <div class="main">
                        <header class="topbar">
                            <button class="burger" onclick="openSidebar()"><i class="fa-solid fa-bars"></i></button>
                            <h1 class="topbar-title"><i class="fa-solid fa-gear"></i> Cấu hình hệ thống</h1>
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
                                    <h2>Thiết lập vận hành</h2>
                                    <p>Các thông số ảnh hưởng trực tiếp đến hoạt động nhà hàng</p>
                                </div>
                            </div>

                            <form method="post" action="${ctx}/admin/config/save" id="configForm">
                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px">
                                    <%-- Tax & Fees --%>
                                        <div class="table-card" style="padding:24px">
                                            <h3
                                                style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                                <i class="fa-solid fa-percent" style="color:var(--primary)"></i> Thuế &
                                                Phí
                                            </h3>
                                            <div class="form-group">
                                                <label class="form-label">VAT (%)</label>
                                                <input type="number" name="vat_rate" class="form-control"
                                                    value="${config['vat_rate'] != null ? config['vat_rate'] : '10'}"
                                                    step="0.1" min="0" max="100">
                                            </div>
                                            <div class="form-group">
                                                <label class="form-label">Phí dịch vụ (%)</label>
                                                <input type="number" name="service_fee_rate" class="form-control"
                                                    value="${config['service_fee_rate'] != null ? config['service_fee_rate'] : '5'}"
                                                    step="0.1" min="0" max="100">
                                            </div>
                                        </div>

                                        <%-- Operating Hours --%>
                                            <div class="table-card" style="padding:24px">
                                                <h3
                                                    style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                                    <i class="fa-solid fa-clock" style="color:var(--info)"></i> Giờ hoạt
                                                    động
                                                </h3>
                                                <div class="form-group">
                                                    <label class="form-label">Giờ mở cửa</label>
                                                    <input type="time" name="opening_hours" class="form-control"
                                                        value="${config['opening_hours'] != null ? config['opening_hours'] : '10:00'}">
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">Giờ đóng cửa</label>
                                                    <input type="time" name="closing_hours" class="form-control"
                                                        value="${config['closing_hours'] != null ? config['closing_hours'] : '22:00'}">
                                                </div>
                                            </div>

                                            <%-- Booking Settings --%>
                                                <div class="table-card" style="padding:24px">
                                                    <h3
                                                        style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                                        <i class="fa-solid fa-calendar-check"
                                                            style="color:var(--warning)"></i> Cài đặt Booking
                                                    </h3>
                                                    <div class="form-group">
                                                        <label class="form-label">Hold minutes <span
                                                                style="color:var(--text-muted);font-weight:400">(phút
                                                                giữ bàn sau giờ booking)</span></label>
                                                        <input type="number" name="hold_minutes" class="form-control"
                                                            value="${config['hold_minutes'] != null ? config['hold_minutes'] : '15'}"
                                                            min="5" max="60">
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Cutoff minutes <span
                                                                style="color:var(--text-muted);font-weight:400">(hạn sửa
                                                                pre-order trước giờ booking)</span></label>
                                                        <input type="number" name="cutoff_minutes" class="form-control"
                                                            value="${config['cutoff_minutes'] != null ? config['cutoff_minutes'] : '60'}"
                                                            min="15" max="240">
                                                    </div>
                                                </div>

                                                <%-- Session & Payment --%>
                                                    <div class="table-card" style="padding:24px">
                                                        <h3
                                                            style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                                            <i class="fa-solid fa-cog" style="color:var(--success)"></i>
                                                            Phiên & Thanh toán
                                                        </h3>
                                                        <div class="form-group">
                                                            <label class="form-label">Session timeout (phút)</label>
                                                            <input type="number" name="session_timeout"
                                                                class="form-control"
                                                                value="${config['session_timeout'] != null ? config['session_timeout'] : '30'}"
                                                                min="5" max="240">
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="form-label">Phương thức thanh toán</label>
                                                            <div
                                                                style="display:flex;gap:12px;flex-wrap:wrap;margin-top:6px">
                                                                <label
                                                                    style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);cursor:pointer">
                                                                    <input type="checkbox" name="payment_methods"
                                                                        value="CASH" checked> Tiền mặt
                                                                </label>
                                                                <label
                                                                    style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);cursor:pointer">
                                                                    <input type="checkbox" name="payment_methods"
                                                                        value="CARD"> Thẻ
                                                                </label>
                                                                <label
                                                                    style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);cursor:pointer">
                                                                    <input type="checkbox" name="payment_methods"
                                                                        value="TRANSFER" checked> Chuyển khoản
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                 <%-- Email SMTP Settings --%>
                                 <div class="table-card" style="padding:24px;grid-column:1/-1">
                                     <h3 style="font-size:15px;font-weight:700;margin-bottom:20px;display:flex;align-items:center;gap:8px">
                                         <i class="fa-solid fa-envelope" style="color:var(--primary)"></i> Cài đặt Email gửi xác nhận
                                     </h3>
                                     <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
                                         <div class="form-group">
                                             <label class="form-label">Email gửi (Gmail)</label>
                                             <input type="hidden" name="configKey" value="smtp_user">
                                             <input type="email" name="value_smtp_user" class="form-control"
                                                 value="${config['smtp_user'] != null ? config['smtp_user'] : ''}"
                                                 placeholder="yourmail@gmail.com">
                                             <div style="font-size:11px;color:var(--text-muted);margin-top:4px">
                                                 <i class="fa-solid fa-circle-info"></i>
                                                 Địa chỉ Gmail dùng để gửi email xác nhận đặt bàn
                                             </div>
                                         </div>
                                         <div class="form-group">
                                             <label class="form-label">App Password Gmail</label>
                                             <input type="hidden" name="configKey" value="smtp_pass">
                                             <input type="password" name="value_smtp_pass" id="smtpPassInput" class="form-control"
                                                 value="${config['smtp_pass'] != null ? config['smtp_pass'] : ''}"
                                                 placeholder="xxxx xxxx xxxx xxxx"
                                                 autocomplete="new-password">
                                             <div style="font-size:11px;color:var(--text-muted);margin-top:4px">
                                                 <i class="fa-solid fa-circle-info"></i>
                                                 Tạo App Password tại:
                                                 <a href="https://myaccount.google.com/apppasswords" target="_blank"
                                                    style="color:var(--primary)">myaccount.google.com/apppasswords</a>
                                                 (cần bật 2FA)
                                             </div>
                                         </div>
                                         <div class="form-group">
                                             <label class="form-label">Tên hiển thị khi gửi mail</label>
                                             <input type="hidden" name="configKey" value="smtp_from_name">
                                             <input type="text" name="value_smtp_from_name" class="form-control"
                                                 value="${config['smtp_from_name'] != null ? config['smtp_from_name'] : 'Nhà hàng Hương Việt'}"
                                                 placeholder="Nhà hàng Hương Việt">
                                         </div>
                                         <div class="form-group" style="align-self:end">
                                             <div style="display:flex;align-items:center;gap:10px;margin-top:8px">
                                                 <label style="display:flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);cursor:pointer">
                                                     <input type="checkbox" id="showPassToggle"
                                                         onchange="document.getElementById('smtpPassInput').type = this.checked ? 'text' : 'password'">
                                                     Hiện mật khẩu
                                                 </label>
                                             </div>
                                             <div style="margin-top:12px;padding:10px 14px;background:rgba(34,197,94,0.06);border:1px solid rgba(34,197,94,0.15);border-radius:8px;font-size:12px;color:#4ade80">
                                                 <i class="fa-solid fa-shield-halved"></i>
                                                 App Password không phải mật khẩu Gmail thường.
                                                 Chỉ dùng cho ứng dụng này và có thể thu hồi bất cứ lúc nào.
                                             </div>
                                         </div>
                                     </div>
                                 </div>

                                 <%-- Hidden configKeys for other fields --%>
                                 <input type="hidden" name="configKey" value="vat_rate">
                                 <input type="hidden" name="configKey" value="service_fee_rate">
                                 <input type="hidden" name="configKey" value="opening_hours">
                                 <input type="hidden" name="configKey" value="closing_hours">
                                 <input type="hidden" name="configKey" value="hold_minutes">
                                 <input type="hidden" name="configKey" value="cutoff_minutes">
                                 <input type="hidden" name="configKey" value="session_timeout">
                                 <input type="hidden" name="configKey" value="smtp_user">
                                 <input type="hidden" name="configKey" value="smtp_pass">
                                 <input type="hidden" name="configKey" value="smtp_from_name">

                                </div>

                                <div style="display:flex;justify-content:flex-end;margin-top:24px;gap:12px">
                                    <button type="button" class="btn btn-ghost" onclick="openModal('confirmModal')">
                                        <i class="fa-solid fa-floppy-disk"></i> Lưu cấu hình
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
            </div>

            <%-- Confirm Modal --%>
                <div class="modal-overlay" id="confirmModal">
                    <div class="modal">
                        <div class="modal-header">
                            <h3 class="modal-title"><i class="fa-solid fa-triangle-exclamation"
                                    style="color:var(--warning)"></i> Xác nhận cập nhật</h3>
                            <button class="btn btn-ghost btn-sm" onclick="closeModal('confirmModal')"><i
                                    class="fa-solid fa-xmark"></i></button>
                        </div>
                        <div class="modal-body">
                            <p style="color:var(--text-muted)">Thay đổi cấu hình sẽ ảnh hưởng đến toàn bộ hệ thống. Bạn
                                có chắc chắn?</p>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-ghost"
                                onclick="closeModal('confirmModal')">Hủy</button>
                            <button type="button" class="btn btn-primary"
                                onclick="document.getElementById('configForm').submit()">
                                <i class="fa-solid fa-check"></i> Xác nhận lưu
                            </button>
                        </div>
                    </div>
                </div>

                <script>
                    function openModal(id) { document.getElementById(id).classList.add('active'); }
                    function closeModal(id) { document.getElementById(id).classList.remove('active'); }
                    function openSidebar() { document.getElementById('sidebar').classList.add('open'); document.getElementById('sidebarOverlay').classList.add('active'); }
                    function closeSidebar() { document.getElementById('sidebar').classList.remove('open'); document.getElementById('sidebarOverlay').classList.remove('active'); }
                </script>
        </body>

        </html>