<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Quên mật khẩu — Hương Việt</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
        </head>

        <body>
            <div class="auth-page">
                <div class="auth-wrapper">
                    <div class="auth-logo">
                        <div class="auth-logo-icon"><i class="fa-solid fa-key"></i></div>
                        <h1>Khôi phục</h1>
                        <p>Nhập email để lấy lại mật khẩu</p>
                    </div>
                    <div class="auth-card">
                        <c:if test="${not empty success}">
                            <div class="alert alert-success mb-4"><i class="fa-solid fa-circle-check"></i>
                                <c:out value="${success}" />
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-error mb-4"><i class="fa-solid fa-circle-exclamation"></i>
                                <c:out value="${error}" />
                            </div>
                        </c:if>
                        <form method="post">
                            <div class="form-group"><label>Email đăng ký</label><input type="email" name="email"
                                    required autofocus placeholder="email@example.com"></div>
                            <button type="submit" class="btn btn-primary btn-block" style="padding:.75rem"><i
                                    class="fa-solid fa-paper-plane"></i> Gửi yêu cầu</button>
                        </form>
                        <p class="auth-footer" style="margin-top:1.25rem"><a
                                href="${pageContext.request.contextPath}/login" style="color:var(--muted-fg)"><i
                                    class="fa-solid fa-arrow-left"></i> Quay lại đăng nhập</a></p>
                    </div>
                </div>
            </div>
        </body>

        </html>