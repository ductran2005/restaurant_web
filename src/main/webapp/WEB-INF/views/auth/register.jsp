<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Đăng ký — Nhà hàng Hương Việt</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        </head>

        <body>
            <div class="auth-page">
                <div class="auth-wrapper">
                    <div class="auth-logo">
                        <div class="auth-logo-icon"><i class="fa-solid fa-user-plus"></i></div>
                        <h1>Đăng ký</h1>
                        <p>Tạo tài khoản khách hàng mới</p>
                    </div>
                    <div class="auth-card">
                        <c:if test="${not empty error}">
                            <div class="alert alert-error mb-4"><i class="fa-solid fa-circle-exclamation"></i>
                                <c:out value="${error}" />
                            </div>
                        </c:if>
                        <form method="post" action="${pageContext.request.contextPath}/register">
                            <div class="form-group"><label>Họ và tên <span class="required">*</span></label><input
                                    type="text" name="fullName" required placeholder="Nguyễn Văn A"></div>
                            <div class="form-group"><label>Email <span class="required">*</span></label><input
                                    type="email" name="email" required placeholder="email@example.com"></div>
                            <div class="form-group"><label>Số điện thoại</label><input type="tel" name="phone"
                                    placeholder="0901234567"></div>
                            <div class="form-group"><label>Mật khẩu <span class="required">*</span></label><input
                                    type="password" name="password" minlength="6" required
                                    placeholder="Tối thiểu 6 ký tự"></div>
                            <div class="form-group"><label>Xác nhận mật khẩu <span
                                        class="required">*</span></label><input type="password" name="confirmPassword"
                                    required placeholder="Nhập lại mật khẩu"></div>
                            <button type="submit" class="btn btn-primary btn-block" style="padding:.75rem"><i
                                    class="fa-solid fa-user-check"></i> Tạo tài khoản</button>
                        </form>
                        <p class="auth-footer" style="margin-top:1.25rem">Đã có tài khoản? <a
                                href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
                    </div>
                </div>
            </div>
        </body>

        </html>