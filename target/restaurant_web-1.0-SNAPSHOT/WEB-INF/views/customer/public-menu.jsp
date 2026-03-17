<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta name="description"
                    content="Thực đơn nhà hàng Hương Việt — Hơn 50 món ăn đặc sắc ba miền, hải sản tươi sống, lẩu nướng và đồ uống.">
                <title>Thực đơn — Nhà hàng Hương Việt</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
                <style>
                    /* ── Menu Page Specific Overrides ── */
                    .menu-page-hero {
                        padding: 140px 48px 60px;
                        text-align: center;
                        position: relative;
                        overflow: hidden;
                    }

                    .menu-page-hero::before {
                        content: '';
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, 0.08) 0%, transparent 60%);
                        pointer-events: none;
                    }

                    .menu-page-hero .section-label {
                        display: inline-flex;
                        margin-bottom: 16px;
                    }

                    .menu-page-hero h1 {
                        font-family: var(--font-serif);
                        font-size: clamp(32px, 5vw, 52px);
                        color: var(--text);
                        margin-bottom: 12px;
                    }

                    .menu-page-hero h1 em {
                        color: var(--primary);
                        font-style: italic;
                    }

                    .menu-page-hero p {
                        font-size: 15px;
                        color: var(--text-muted);
                        max-width: 520px;
                        margin: 0 auto;
                    }

                    /* ── Search ── */
                    .menu-search-wrap {
                        max-width: 540px;
                        margin: 40px auto 0;
                    }

                    .menu-search-box {
                        position: relative;
                        display: flex;
                        align-items: center;
                    }

                    .menu-search-box i {
                        position: absolute;
                        left: 18px;
                        color: var(--text-muted);
                        font-size: 14px;
                        pointer-events: none;
                    }

                    .menu-search-box input {
                        width: 100%;
                        background: rgba(255, 255, 255, 0.06);
                        border: 1px solid var(--border);
                        border-radius: 12px;
                        padding: 14px 20px 14px 46px;
                        font-size: 15px;
                        color: var(--text);
                        font-family: inherit;
                        transition: all 0.3s;
                    }

                    .menu-search-box input::placeholder {
                        color: var(--text-muted);
                    }

                    .menu-search-box input:focus {
                        outline: none;
                        border-color: var(--primary);
                        background: rgba(232, 160, 32, 0.05);
                        box-shadow: 0 0 0 3px rgba(232, 160, 32, 0.1);
                    }

                    /* ── Category Tabs ── */
                    .menu-filter-section {
                        padding: 0 48px 20px;
                        display: flex;
                        justify-content: center;
                    }

                    .filter-tabs {
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        flex-wrap: wrap;
                        justify-content: center;
                    }

                    .filter-tab {
                        padding: 10px 24px;
                        border-radius: 99px;
                        font-size: 13px;
                        font-weight: 600;
                        color: var(--text-muted);
                        border: 1px solid var(--border);
                        text-decoration: none;
                        transition: all 0.25s;
                        letter-spacing: 0.03em;
                        cursor: pointer;
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .filter-tab:hover {
                        color: var(--primary);
                        border-color: rgba(232, 160, 32, 0.4);
                        background: rgba(232, 160, 32, 0.08);
                    }

                    .filter-tab.active {
                        background: var(--primary);
                        color: #000;
                        border-color: var(--primary);
                    }

                    /* ── Menu Grid Override for this page ── */
                    .menu-content {
                        padding: 40px 48px 100px;
                        max-width: 1400px;
                        margin: 0 auto;
                    }

                    .menu-content .menu-grid {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 20px;
                    }

                    @media (max-width: 1200px) {
                        .menu-content .menu-grid {
                            grid-template-columns: repeat(3, 1fr);
                        }
                    }

                    @media (max-width: 900px) {
                        .menu-content .menu-grid {
                            grid-template-columns: repeat(2, 1fr);
                        }

                        .menu-page-hero {
                            padding: 120px 24px 48px;
                        }

                        .menu-filter-section {
                            padding: 0 24px 20px;
                        }

                        .menu-content {
                            padding: 32px 24px 80px;
                        }
                    }

                    @media (max-width: 600px) {
                        .menu-content .menu-grid {
                            grid-template-columns: 1fr;
                        }
                    }

                    /* ── Menu Card Sold-out ── */
                    .menu-card.sold-out {
                        opacity: 0.6;
                    }

                    .menu-card.sold-out:hover {
                        transform: none;
                        box-shadow: none;
                    }

                    .sold-badge {
                        position: absolute;
                        top: 14px;
                        right: 14px;
                        background: #ef4444;
                        color: #fff;
                        padding: 3px 10px;
                        border-radius: 99px;
                        font-size: 11px;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        gap: 4px;
                        letter-spacing: 0.04em;
                    }

                    .sold-text {
                        font-size: 13px;
                        color: #ef4444;
                        font-weight: 600;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .menu-card-img .img-placeholder {
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: linear-gradient(135deg, #1e1b17 0%, #2a2520 100%);
                    }

                    .menu-card-img .img-placeholder i {
                        font-size: 3rem;
                        color: rgba(232, 160, 32, 0.15);
                    }

                    /* ── Menu page empty state ── */
                    .menu-empty {
                        text-align: center;
                        padding: 80px 24px;
                    }

                    .menu-empty i {
                        font-size: 4rem;
                        color: rgba(232, 160, 32, 0.2);
                        margin-bottom: 20px;
                    }

                    .menu-empty h3 {
                        font-size: 20px;
                        font-weight: 700;
                        color: var(--text);
                        margin-bottom: 8px;
                    }

                    .menu-empty p {
                        color: var(--text-muted);
                        font-size: 14px;
                    }

                    /* ── Stats bar ── */
                    .menu-stats {
                        display: flex;
                        justify-content: center;
                        gap: 40px;
                        padding: 20px 48px 0;
                    }

                    .menu-stat {
                        text-align: center;
                    }

                    .menu-stat-num {
                        font-size: 28px;
                        font-weight: 800;
                        color: var(--primary);
                    }

                    .menu-stat-label {
                        font-size: 11px;
                        color: var(--text-muted);
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        margin-top: 2px;
                    }
                </style>
            </head>

            <body>

                <!-- ============================================================
     NAVBAR (same as landing)
============================================================ -->
                <nav class="navbar" id="navbar">
                    <a href="${pageContext.request.contextPath}/" class="nav-logo">
                        <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                    </a>
                    <div class="nav-links">
                        <a href="${pageContext.request.contextPath}/menu" class="active">Thực đơn</a>
                        <a href="${pageContext.request.contextPath}/booking">Đặt bàn</a>
                        <a href="${pageContext.request.contextPath}/booking/status">Tra cứu</a>
                        <a href="${pageContext.request.contextPath}/pre-order">Đặt món trước</a>
                        <a href="${pageContext.request.contextPath}/about">Về chúng tôi</a>
                        <a href="${pageContext.request.contextPath}/contact">Liên hệ</a>
                    </div>
                    <div class="nav-actions">
                        <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
                        <a href="${pageContext.request.contextPath}/booking" class="btn-book">
                            <i class="fa-solid fa-calendar-check"></i> Đặt bàn
                        </a>
                    </div>
                    <div class="nav-burger" id="navBurger">
                        <span></span><span></span><span></span>
                    </div>
                </nav>

                <!-- ============================================================
     HERO
============================================================ -->
                <section class="menu-page-hero">
                    <div class="section-label"><i class="fa-solid fa-utensils"></i> Thực đơn nhà hàng</div>
                    <h1>Khám phá hương vị <em>đậm đà</em></h1>
                    <p>Hơn 50 món ăn được chế biến từ nguyên liệu tươi ngon mỗi ngày — từ khai vị, hải sản, lẩu nướng
                        đến đồ uống đặc biệt.</p>

                    <!-- Search -->
                    <div class="menu-search-wrap">
                        <form method="get" action="${pageContext.request.contextPath}/menu">
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

                <!-- ============================================================
     CATEGORY TABS
============================================================ -->
                <div class="menu-filter-section">
                    <div class="filter-tabs">
                        <a href="${pageContext.request.contextPath}/menu"
                            class="filter-tab ${empty selectedCategoryId ? 'active' : ''}">
                            <i class="fa-solid fa-grid-2"></i> Tất cả
                        </a>
                        <c:forEach var="cat" items="${categories}">
                            <a href="${pageContext.request.contextPath}/menu?categoryId=${cat.id}"
                                class="filter-tab ${selectedCategoryId == cat.id ? 'active' : ''}">
                                <c:out value="${cat.categoryName}" />
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <!-- ============================================================
     MENU GRID
============================================================ -->
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
                                            <div class="img-placeholder">
                                                <i class="fa-solid fa-bowl-food"></i>
                                            </div>
                                            <c:if test="${item.status == 'UNAVAILABLE'}">
                                                <span class="sold-badge"><i class="fa-solid fa-ban"></i> Hết món</span>
                                            </c:if>
                                        </div>
                                        <div class="menu-card-body">
                                            <div class="menu-card-cat">
                                                <c:out value="${item.category.categoryName}" />
                                            </div>
                                            <h3 class="menu-card-title">
                                                <c:out value="${item.productName}" />
                                            </h3>
                                            <c:if test="${not empty item.description}">
                                                <p class="menu-card-desc">
                                                    <c:out value="${item.description}" />
                                                </p>
                                            </c:if>
                                            <div class="menu-card-footer">
                                                <div class="menu-card-price">
                                                    <fmt:formatNumber value="${item.price}" pattern="#,###" />
                                                    <span>đ</span>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${item.status == 'UNAVAILABLE'}">
                                                        <div class="sold-text"><i class="fa-solid fa-ban"></i> Tạm hết
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/pre-order"
                                                            class="btn-add-dish" title="Đặt món trước">
                                                            <i class="fa-solid fa-plus"></i>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- ============================================================
     CTA BOOKING
============================================================ -->
                <section class="cta-section" id="contact">
                    <div class="section-label">Đặt bàn ngay</div>
                    <h2 class="section-title" style="font-family:var(--font-serif)">Đảm bảo bàn của bạn ngay hôm nay</h2>
                    <p>Đặt trước để nhận ưu đãi tốt nhất và không lo hết chỗ vào giờ cao điểm.</p>
                    <form class="cta-form" action="${pageContext.request.contextPath}/booking" method="get">
                        <input type="text" class="cta-input" name="name" placeholder="Họ và tên...">
                        <input type="tel" class="cta-input" name="phone" placeholder="Số điện thoại...">
                        <input type="date" class="cta-input" name="date">
                        <button type="submit" class="btn-cta">
                            <i class="fa-solid fa-arrow-right"></i> Đặt bàn
                        </button>
                    </form>
                </section>

                <!-- ============================================================
     FOOTER (same as landing)
============================================================ -->
                <footer class="footer" id="footer">
                    <div class="footer-grid">
                        <div class="footer-brand">
                            <div class="footer-logo">
                                <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                                <div class="footer-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                            </div>
                            <p class="footer-desc">Không chỉ là nhà hàng, Hương Việt còn là phong cách sống — điểm hẹn
                                của những khoảnh khắc đáng nhớ.</p>
                            <div class="socials">
                                <a href="#" class="social"><i class="fa-brands fa-facebook-f"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-instagram"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-tiktok"></i></a>
                                <a href="#" class="social"><i class="fa-brands fa-youtube"></i></a>
                            </div>
                        </div>
                        <div class="footer-col">
                            <h4>Khám phá</h4>
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/menu">Thực đơn</a></li>
                                <li><a href="${pageContext.request.contextPath}/booking">Đặt bàn</a></li>
                                <li><a href="${pageContext.request.contextPath}/booking/status">Tra cứu booking</a></li>
                                <li><a href="${pageContext.request.contextPath}/pre-order">Đặt món trước</a></li>
                            </ul>
                        </div>
                        <div class="footer-col">
                            <h4>Về chúng tôi</h4>
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/about">Giới thiệu</a></li>
                                <li><a href="${pageContext.request.contextPath}/contact">Liên hệ</a></li>
                            </ul>
                        </div>
                        <div class="footer-col">
                            <h4>Liên hệ</h4>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-solid fa-location-dot"></i></div>
                                <div class="footer-contact-text"><strong>Địa chỉ</strong>123 Nguyễn Huệ, Quận 1, TP.HCM
                                </div>
                            </div>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-solid fa-phone"></i></div>
                                <div class="footer-contact-text"><strong>Hotline</strong>1900 1234 (8:00 – 23:00)</div>
                            </div>
                            <div class="footer-contact-item">
                                <div class="footer-contact-icon"><i class="fa-regular fa-clock"></i></div>
                                <div class="footer-contact-text"><strong>Giờ mở cửa</strong>10:00 – 23:00 hàng ngày
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="footer-bottom">
                        <p>© 2026 Nhà hàng Hương Việt.</p>
                        <p>Thiết kế bởi <a href="#">Đội ngũ Hương Việt Tech</a></p>
                    </div>
                </footer>

                <!-- Float Mobile Book Button -->
                <a href="${pageContext.request.contextPath}/booking" class="float-book">
                    <i class="fa-solid fa-calendar-check"></i> Đặt bàn ngay
                </a>

                <!-- ============================================================
     JAVASCRIPT
============================================================ -->
                <script>
                    // Navbar scroll effect
                    const navbar = document.getElementById('navbar');
                    window.addEventListener('scroll', () => {
                        navbar.classList.toggle('scrolled', window.scrollY > 60);
                    });

                    // Mobile burger nav
                    document.getElementById('navBurger').addEventListener('click', function () {
                        const links = document.querySelector('.nav-links');
                        links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
                    });

                    // Submit search on Enter
                    const searchInput = document.querySelector('.menu-search-box input');
                    if (searchInput) {
                        searchInput.addEventListener('keypress', function (e) {
                            if (e.key === 'Enter') {
                                this.closest('form').submit();
                            }
                        });
                    }
                </script>

                <!-- chatbot widget include -->
                <jsp:include page="/chatbot.jsp" />

            </body>

            </html>