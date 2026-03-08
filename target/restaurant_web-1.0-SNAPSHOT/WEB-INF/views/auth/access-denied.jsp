<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Truy cập bị từ chối — Hương Việt</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>

    <body>
        <div class="auth-page">
            <div class="auth-wrapper">
                <div class="auth-card" style="text-align:center;padding:3rem 2rem">
                    <div style="font-size:4rem;color:var(--destructive);margin-bottom:1rem"><i
                            class="fa-solid fa-shield-halved"></i></div>
                    <h1 style="color:var(--destructive)">Truy cập bị từ chối</h1>
                    <p class="text-muted" style="margin:.75rem 0 1.5rem">Bạn không có quyền truy cập trang này. Vui lòng
                        đăng nhập bằng tài khoản có đủ quyền hạn.</p>
                    <div style="display:flex;gap:.75rem;justify-content:center">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary"><i
                                class="fa-solid fa-right-to-bracket"></i> Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline"><i
                                class="fa-solid fa-home"></i> Trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </body>

    </html>