<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Thực đơn nhà hàng Hương Việt — Hơn 50 món ăn đặc sắc ba miền.">
    <title>Thực đơn — Nhà hàng Hương Việt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/mobile.css">
    <style>
        .menu-page-hero { padding:140px 48px 60px; text-align:center; position:relative; overflow:hidden; }
        .menu-page-hero::before { content:''; position:absolute; inset:0; background:radial-gradient(ellipse at 50% 0%,rgba(232,160,32,0.08) 0%,transparent 60%); pointer-events:none; }
        .menu-page-hero .section-label { display:inline-flex; margin-bottom:16px; }
        .menu-page-hero h1 { font-family:var(--font-serif); font-size:clamp(32px,5vw,52px); color:var(--text); margin-bottom:12px; }
        .menu-page-hero h1 em { color:var(--primary); font-style:italic; }
        .menu-page-hero p { font-size:15px; color:var(--text-muted); max-width:520px; margin:0 auto; }
        .menu-search-wrap { max-width:540px; margin:40px auto 0; }
        .menu-search-box { position:relative; display:flex; align-items:center; }
        .menu-search-box i { position:absolute; left:18px; color:var(--text-muted); font-size:14px; pointer-events:none; }
        .menu-search-box input { width:100%; background:rgba(255,255,255,0.06); border:1px solid var(--border); border-radius:12px; padding:14px 20px 14px 46px; font-size:15px; color:var(--text); font-family:inherit; transition:all 0.3s; }
        .menu-search-box input::placeholder { color:var(--text-muted); }
        .menu-search-box input:focus { outline:none; border-color:var(--primary); background:rgba(232,160,32,0.05); box-shadow:0 0 0 3px rgba(232,160,32,0.1); }
        .menu-filter-section { padding:0 48px 20px; display:flex; justify-content:center; }
        .filter-tabs { display:flex; align-items:center; gap:6px; flex-wrap:wrap; justify-content:center; }
        .filter-tab { padding:10px 24px; border-radius:99px; font-size:13px; font-weight:600; color:var(--text-muted); border:1px solid var(--border); text-decoration:none; transition:all 0.25s; letter-spacing:0.03em; cursor:pointer; display:inline-flex; align-items:center; gap:6px; }
        .filter-tab:hover { color:var(--primary); border-color:rgba(232,160,32,0.4); background:rgba(232,160,32,0.08); }
        .filter-tab.active { background:var(--primary); color:#000; border-color:var(--primary); }
        .menu-content { padding:40px 48px 100px; max-width:1400px; margin:0 auto; }
        .menu-content .menu-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:20px; }
        @media(max-width:1200px){ .menu-content .menu-grid{ grid-template-columns:repeat(3,1fr); } }
        @media(max-width:900px){ .menu-content .menu-grid{ grid-template-columns:repeat(2,1fr); } .menu-page-hero{ padding:120px 24px 48px; } .menu-filter-section{ padding:0 24px 20px; } .menu-content{ padding:32px 24px 80px; } }
        @media(max-width:600px){ .menu-content .menu-grid{ grid-template-columns:1fr; } }
        .menu-card.sold-out { opacity:0.6; }
        .menu-card.sold-out:hover { transform:none; box-shadow:none; }
        .sold-badge { position:absolute; top:14px; right:14px; background:#ef4444; color:#fff; padding:3px 10px; border-radius:99px; font-size:11px; font-weight:700; display:flex; align-items:center; gap:4px; letter-spacing:0.04em; }
        .sold-text { font-size:13px; color:#ef4444; font-weight:600; display:flex; align-items:center; gap:6px; }
        .menu-card-img .img-placeholder { width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:linear-gradient(135deg,#1e1b17 0%,#2a2520 100%); }
        .menu-card-img .img-placeholder i { font-size:3rem; color:rgba(232,160,32,0.15); }
        .menu-empty { text-align:center; padding:80px 24px; }
        .menu-empty i { font-size:4rem; color:rgba(232,160,32,0.2); margin-bottom:20px; }
        .menu-empty h3 { font-size:20px; font-weight:700; color:var(--text); margin-bottom:8px; }
        .menu-empty p { color:var(--text-muted); font-size:14px; }
        .user-footer { background:#0a0908; border-top:1px solid rgba(255,255,255,0.06); padding:24px 40px; display:flex; align-items:center; justify-content:space-between; font-size:13px; color:#9e9488; }
        .user-footer strong { color:#e8a020; }
        /* ─── User Dropdown ─── */
        .user-dropdown { position: relative; }
        .user-dropdown-btn { display:flex; align-items:center; gap:10px; background:rgba(232,160,32,0.1); border:1px solid rgba(232,160,32,0.25); border-radius:50px; padding:8px 16px 8px 10px; color:#e8a020; font-size:14px; font-weight:500; cursor:pointer; transition:all 0.3s; font-family:inherit; }
        .user-dropdown-btn:hover { background:rgba(232,160,32,0.18); border-color:rgba(232,160,32,0.4); }
        .user-avatar { width:32px; height:32px; border-radius:50%; background:linear-gradient(135deg,#e8a020,#d4911c); display:flex; align-items:center; justify-content:center; color:#fff; font-size:14px; }
        .dd-arrow { font-size:10px; transition:transform 0.3s; color:rgba(232,160,32,0.6); }
        .user-dropdown.open .dd-arrow { transform:rotate(180deg); }
        .user-dropdown-menu { position:absolute; top:calc(100% + 8px); right:0; min-width:220px; background:#1a1710; border:1px solid rgba(232,160,32,0.2); border-radius:12px; padding:6px; box-shadow:0 12px 40px rgba(0,0,0,0.5); opacity:0; visibility:hidden; transform:translateY(-8px); transition:all 0.25s ease; z-index:100; }
        .user-dropdown.open .user-dropdown-menu { opacity:1; visibility:visible; transform:translateY(0); }
        .dd-item { display:flex; align-items:center; gap:10px; padding:10px 14px; border-radius:8px; font-size:14px; color:rgba(255,255,255,0.75); text-decoration:none; transition:all 0.2s; }
        .dd-item:hover { background:rgba(232,160,32,0.1); color:#e8a020; }
        .dd-item i { width:18px; text-align:center; font-size:13px; }
        .dd-divider { height:1px; background:rgba(255,255,255,0.08); margin:4px 8px; }
        .dd-logout:hover { color:#f87171; background:rgba(248,113,113,0.08); }
    </style>
</head>
<body>

    <!-- ══════════ USER NAVBAR ══════════ -->
    <nav class="navbar" id="navbar" style="background:rgba(15,14,12,0.95); backdrop-filter:blur(12px);">
        <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div class="nav-logo-text">Hương Việt<span>Nhà hàng &amp; Quán nhậu</span></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/menu" class="active">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/user/booking/create">Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/user/booking/status">Lịch sử booking</a>
            <a href="${pageContext.request.contextPath}/user/pre-order">Đặt món trước</a>
        </div>
        <div class="nav-actions">
            <div class="user-dropdown" id="userDropdown">
                <button class="user-dropdown-btn" onclick="document.getElementById('userDropdown').classList.toggle('open')">
                    <div class="user-avatar"><i class="fa-solid fa-user"></i></div>
                    <span>${sessionScope.user.fullName}</span>
                    <i class="fa-solid fa-chevron-down dd-arrow"></i>
                </button>
                <div class="user-dropdown-menu">
                    <a href="${pageContext.request.contextPath}/user/profile" class="dd-item">
                        <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa thông tin
                    </a>
                    <div class="dd-divider"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="dd-item dd-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>
        </div>
        <div class="nav-burger" id="navBurger">
            <span></span><span></span><span></span>
        </div>
    </nav>

    <!-- ══════════ HERO ══════════ -->
    <section class="menu-page-hero">
        <div class="section-label"><i class="fa-solid fa-utensils"></i> Thực đơn nhà hàng</div>
        <h1>Khám phá hương vị <em>đậm đà</em></h1>
        <p>Hơn 50 món ăn được chế biến từ nguyên liệu tươi ngon mỗi ngày — từ khai vị, hải sản, lẩu nướng đến đồ uống đặc biệt.</p>
        <div class="menu-search-wrap">
            <form method="get" action="${pageContext.request.contextPath}/user/menu">
                <div class="menu-search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" name="search" value="${search}" placeholder="Tìm kiếm món ăn...">
                </div>
                <c:if test="${not empty selectedCategoryId}">
                    <input type="hidden" name="categoryId" value="${selectedCategoryId}">
                </c:if>
            </form>
        </div>
    </section>

    <!-- ══════════ CATEGORY TABS ══════════ -->
    <div class="menu-filter-section">
        <div class="filter-tabs">
            <a href="${pageContext.request.contextPath}/user/menu"
                class="filter-tab ${empty selectedCategoryId ? 'active' : ''}">
                <i class="fa-solid fa-grid-2"></i> Tất cả
            </a>
            <c:forEach var="cat" items="${categories}">
                <a href="${pageContext.request.contextPath}/user/menu?categoryId=${cat.id}"
                    class="filter-tab ${selectedCategoryId == cat.id ? 'active' : ''}">
                    <c:out value="${cat.categoryName}" />
                </a>
            </c:forEach>
        </div>
    </div>

    <!-- ══════════ MENU GRID ══════════ -->
    <div class="menu-content">
        <c:choose>
            <c:when test="${empty products}">
                <div class="menu-empty">
                    <i class="fa-solid fa-bowl-food"></i>
                    <h3>Không tìm thấy món ăn</h3>
                    <p>Vui lòng thử tìm kiếm với từ khóa khác hoặc chọn danh mục khác.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="menu-grid">
                    <c:forEach var="item" items="${products}">
                        <div class="menu-card ${item.status == 'UNAVAILABLE' ? 'sold-out' : ''}">
                            <div class="menu-card-img">
                                <c:choose>
                                    <c:when test="${not empty item.imageUrl}">
                                        <img src="${item.imageUrl}" alt="${item.productName}" style="width:100%;height:100%;object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="img-placeholder">
                                            <i class="fa-solid fa-bowl-food"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${item.status == 'UNAVAILABLE'}">
                                    <span class="sold-badge"><i class="fa-solid fa-ban"></i> Hết món</span>
                                </c:if>
                            </div>
                            <div class="menu-card-body">
                                <div class="menu-card-cat"><c:out value="${item.category.categoryName}" /></div>
                                <h3 class="menu-card-title"><c:out value="${item.productName}" /></h3>
                                <c:if test="${not empty item.description}">
                                    <p class="menu-card-desc"><c:out value="${item.description}" /></p>
                                </c:if>
                                <div class="menu-card-footer">
                                    <div class="menu-card-price">
                                        <fmt:formatNumber value="${item.price}" pattern="#,###" /><span>đ</span>
                                    </div>
                                    <c:if test="${item.status == 'UNAVAILABLE'}">
                                        <div class="sold-text"><i class="fa-solid fa-ban"></i> Tạm hết</div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ══════════ FOOTER ══════════ -->
    <footer class="user-footer">
        <p>© 2026 Nhà hàng Hương Việt. 123 Nguyễn Huệ, Q.1, TP.HCM</p>
        <p>Hotline: <strong>1900 1234</strong> (8:00 – 23:00)</p>
    </footer>

    <jsp:include page="/chatbot.jsp" />

    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('scrolled', window.scrollY > 60);
        });
        document.addEventListener('click', function(e) {
            const dd = document.getElementById('userDropdown');
            if (dd && !dd.contains(e.target)) dd.classList.remove('open');
        });
        document.getElementById('navBurger').addEventListener('click', function() {
            const links = document.querySelector('.nav-links');
            links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
        });
        const searchInput = document.querySelector('.menu-search-box input');
        if (searchInput) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') this.closest('form').submit();
            });
        }
    </script>
</body>
</html>
