<%@ tag description="Customer Layout" pageEncoding="UTF-8"%>
<%@ attribute name="pageTitle" required="true" type="java.lang.String"%>
<%@ attribute name="activeMenu" required="false" type="java.lang.String"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${pageTitle} — Hương Việt</title>
    <!-- Use standard font awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
</head>
<body class="l-customer-shell">
    <header class="l-customer-topbar">
        <div class="topbar-inner">
            <a href="${pageContext.request.contextPath}/menu" class="brand">
                <div class="brand-icon"><i class="fa-solid fa-utensils"></i></div>
                <span class="brand-text">Nha hang Huong Viet</span>
            </a>
            <nav class="nav-menu">
                <a href="${pageContext.request.contextPath}/menu" class="nav-item ${activeMenu == 'menu' ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> Thuc don
                </a>
                <a href="${pageContext.request.contextPath}/booking" class="nav-item ${activeMenu == 'booking' ? 'active' : ''}">
                    <i class="fa-regular fa-calendar-plus"></i> Dat ban
                </a>
                <a href="${pageContext.request.contextPath}/booking/status" class="nav-item ${activeMenu == 'status' ? 'active' : ''}">
                    <i class="fa-solid fa-magnifying-glass"></i> Tra cuu dat ban
                </a>
                <a href="${pageContext.request.contextPath}/pre-order" class="nav-item ${activeMenu == 'preorder' ? 'active' : ''}">
                    <i class="fa-solid fa-cart-shopping"></i> Dat mon truoc
                </a>
            </nav>
            <div class="auth-section">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/customer/home" class="nav-item">
                            <i class="fa-solid fa-user"></i> ${sessionScope.user.fullName}
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="nav-item">
                            <i class="fa-solid fa-right-to-bracket"></i> Dang nhap
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </header>

    <main class="l-customer-main">
        <jsp:doBody/>
    </main>

    <footer class="l-customer-footer" style="display:none;">
        <p>123 Nguyễn Huệ, Quận 1, TP.HCM | Hotline: <span class="font-bold">1900 1234</span></p>
    </footer>

    <jsp:include page="/chatbot.jsp" /></body>
</html>
