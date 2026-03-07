<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description"
            content="Không chỉ là nhà hàng, Hương Việt còn là phong cách sống – điểm hẹn liên hoan, sinh nhật, xả stress, tụ tập bạn bè. 123 Nguyễn Huệ, Q.1, TP.HCM.">
        <title>Nhà hàng Hương Việt – Hương vị đậm đà, kỷ niệm trọn vẹn</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    </head>

    <body>

        <!-- ============================================================
     NAVBAR
============================================================ -->
        <nav class="navbar" id="navbar">
            <a href="#" class="nav-logo">
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
        <section class="hero">
            <div class="hero-bg"></div>
            <div class="hero-content">
                <div class="hero-label"><i class="fa-solid fa-star"></i> Nhà hàng hàng đầu TP.HCM</div>
                <h1 class="hero-title">
                    Hương vị <em>đậm đà</em>,<br>kỷ niệm trọn vẹn
                </h1>
                <p class="hero-desc">
                    Không chỉ là nhà hàng — Hương Việt là điểm hẹn liên hoan, sinh nhật, xả stress, tụ tập bạn bè với
                    hơn 50 món ngon đặc sắc từ ba miền.
                </p>
                <div class="hero-cta">
                    <a href="${pageContext.request.contextPath}/menu" class="btn-primary">
                        <i class="fa-solid fa-book-open"></i> Xem thực đơn
                    </a>
                    <a href="${pageContext.request.contextPath}/booking" class="btn-outline">
                        <i class="fa-regular fa-calendar-plus"></i> Đặt bàn ngay
                    </a>
                </div>
            </div>
            <div class="hero-stats">
                <div class="hero-stat">
                    <div class="hero-stat-num">50+</div>
                    <div class="hero-stat-label">Món ăn</div>
                </div>
                <div class="hero-stat">
                    <div class="hero-stat-num">10k+</div>
                    <div class="hero-stat-label">Khách hàng</div>
                </div>
            </div>
            <div class="hero-scroll">
                <div class="scroll-line"></div>
                <span>Cuộn xuống</span>
            </div>
        </section>

        <!-- ============================================================
     NEW DISHES TICKER
============================================================ -->
        <div class="dishes-new">
            <div class="dishes-ticker" id="ticker">
                <!-- Set 1 -->
                <div class="ticker-set">
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish1.png" alt="Gỏi cuốn">
                        <div>
                            <div class="ticker-item-name">Gỏi cuốn tôm thịt</div>
                            <div class="ticker-item-price">65.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Khai vị</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Bò lúc lắc">
                        <div>
                            <div class="ticker-item-name">Bò lúc lắc sốt tiêu đen</div>
                            <div class="ticker-item-price">185.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Món hot</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish3.png" alt="Hải sản">
                        <div>
                            <div class="ticker-item-name">Mâm hải sản tươi sống</div>
                            <div class="ticker-item-price">320.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Đặc sản</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish4.png" alt="Lẩu">
                        <div>
                            <div class="ticker-item-name">Lẩu gà đen nấm rừng</div>
                            <div class="ticker-item-price">280.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Mới ra</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish1.png" alt="Gỏi">
                        <div>
                            <div class="ticker-item-name">Gỏi bò cà pháo đồng quê</div>
                            <div class="ticker-item-price">95.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Khai vị</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Nướng">
                        <div>
                            <div class="ticker-item-name">Nầm sữa cháy tỏi</div>
                            <div class="ticker-item-price">145.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Best Seller</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish3.png" alt="Ghẹ">
                        <div>
                            <div class="ticker-item-name">Ghẹ rang muối otoro</div>
                            <div class="ticker-item-price">250.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Hải sản</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish4.png" alt="Lẩu Thái">
                        <div>
                            <div class="ticker-item-name">Lẩu Thái hải sản cay đặc biệt</div>
                            <div class="ticker-item-price">299.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Lẩu</span>
                    </div>
                </div>
                <!-- Set 2 (duplicate for infinite) -->
                <div class="ticker-set" aria-hidden="true">
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish1.png" alt="Gỏi cuốn">
                        <div>
                            <div class="ticker-item-name">Gỏi cuốn tôm thịt</div>
                            <div class="ticker-item-price">65.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Khai vị</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Bò lúc lắc">
                        <div>
                            <div class="ticker-item-name">Bò lúc lắc sốt tiêu đen</div>
                            <div class="ticker-item-price">185.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Món hot</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish3.png" alt="Hải sản">
                        <div>
                            <div class="ticker-item-name">Mâm hải sản tươi sống</div>
                            <div class="ticker-item-price">320.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Đặc sản</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish4.png" alt="Lẩu">
                        <div>
                            <div class="ticker-item-name">Lẩu gà đen nấm rừng</div>
                            <div class="ticker-item-price">280.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Mới ra</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish1.png" alt="Gỏi">
                        <div>
                            <div class="ticker-item-name">Gỏi bò cà pháo đồng quê</div>
                            <div class="ticker-item-price">95.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Khai vị</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Nướng">
                        <div>
                            <div class="ticker-item-name">Nầm sữa cháy tỏi</div>
                            <div class="ticker-item-price">145.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Best Seller</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish3.png" alt="Ghẹ">
                        <div>
                            <div class="ticker-item-name">Ghẹ rang muối otoro</div>
                            <div class="ticker-item-price">250.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Hải sản</span>
                    </div>
                    <div class="ticker-item">
                        <img src="${pageContext.request.contextPath}/assets/img/dish4.png" alt="Lẩu Thái">
                        <div>
                            <div class="ticker-item-name">Lẩu Thái hải sản cay đặc biệt</div>
                            <div class="ticker-item-price">299.000 đ</div>
                        </div>
                        <span class="ticker-item-tag">Lẩu</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
     FEATURED MENU
============================================================ -->
        <section class="menu-section" id="menu">
            <div class="section-head">
                <div class="section-label">Thực đơn nổi bật</div>
                <h2 class="section-title">Tinh hoa ẩm thực <em style="font-style:italic;color:var(--primary)">ba
                        miền</em></h2>
                <p class="section-subtitle">Hơn 50 món ăn được chế biến từ nguyên liệu tươi ngon mỗi ngày bởi đội bếp
                    có kinh nghiệm hơn 10 năm.</p>
            </div>

            <div class="menu-grid">
                <!-- Card 1 -->
                <div class="menu-card">
                    <div class="menu-card-img">
                        <img src="${pageContext.request.contextPath}/assets/img/dish1.png" alt="Gỏi cuốn tôm thịt">
                        <span class="menu-card-badge new">Mới</span>
                    </div>
                    <div class="menu-card-body">
                        <div class="menu-card-cat">Khai vị</div>
                        <h3 class="menu-card-title">Gỏi cuốn tôm thịt tươi</h3>
                        <p class="menu-card-desc">Gỏi cuốn tươi với tôm sú và thịt heo, rau sống và bún, chấm nước mắm
                            chua ngọt đặc biệt.</p>
                        <div class="menu-card-footer">
                            <div class="menu-card-price">65.000<span>đ</span></div>
                            <a href="${pageContext.request.contextPath}/menu" class="btn-add-dish"><i
                                    class="fa-solid fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                <!-- Card 2 -->
                <div class="menu-card">
                    <div class="menu-card-img">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Bò lúc lắc">
                        <span class="menu-card-badge">Best</span>
                        <div class="menu-card-hot"><i class="fa-solid fa-fire-flame-curved"></i></div>
                    </div>
                    <div class="menu-card-body">
                        <div class="menu-card-cat">Món chính</div>
                        <h3 class="menu-card-title">Bò lúc lắc bơ tỏi tiêu đen</h3>
                        <p class="menu-card-desc">Thăn bò Úc cao cấp, xào cùng bơ tỏi phi thơm, tiêu đen Phú Quốc, ăn
                            kèm cơm chiên.</p>
                        <div class="menu-card-footer">
                            <div class="menu-card-price">185.000<span>đ</span></div>
                            <a href="${pageContext.request.contextPath}/menu" class="btn-add-dish"><i
                                    class="fa-solid fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                <!-- Card 3 -->
                <div class="menu-card">
                    <div class="menu-card-img">
                        <img src="${pageContext.request.contextPath}/assets/img/dish3.png" alt="Mâm hải sản">
                    </div>
                    <div class="menu-card-body">
                        <div class="menu-card-cat">Hải sản</div>
                        <h3 class="menu-card-title">Mâm hải sản tươi sống đặc biệt</h3>
                        <p class="menu-card-desc">Tôm hùm, ghẹ gạch, nghêu hấp xả, mực nướng sa tế — đặt trước để có giá
                            tốt nhất.</p>
                        <div class="menu-card-footer">
                            <div class="menu-card-price">320.000<span>đ</span></div>
                            <a href="${pageContext.request.contextPath}/menu" class="btn-add-dish"><i
                                    class="fa-solid fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                <!-- Card 4 -->
                <div class="menu-card">
                    <div class="menu-card-img">
                        <img src="${pageContext.request.contextPath}/assets/img/dish4.png" alt="Lẩu gà đen">
                        <span class="menu-card-badge new">Mới</span>
                    </div>
                    <div class="menu-card-body">
                        <div class="menu-card-cat">Lẩu</div>
                        <h3 class="menu-card-title">Lẩu gà đen nấm rừng Vân Nam</h3>
                        <p class="menu-card-desc">Gà đen hầm cùng nấm rừng Vân Nam trong nước dùng trong vắt, ngọt
                            thanh, bổ dưỡng.</p>
                        <div class="menu-card-footer">
                            <div class="menu-card-price">280.000<span>đ</span></div>
                            <a href="${pageContext.request.contextPath}/menu" class="btn-add-dish"><i
                                    class="fa-solid fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="view-all-wrap">
                <a href="${pageContext.request.contextPath}/menu" class="btn-outline" style="display:inline-flex">
                    <i class="fa-solid fa-book-open"></i> Xem toàn bộ thực đơn
                </a>
            </div>
        </section>

        <!-- ============================================================
     STORY / ABOUT
============================================================ -->
        <section class="about-section" id="about">
            <div class="about-grid">
                <div class="about-images">
                    <div class="about-img-main">
                        <img src="${pageContext.request.contextPath}/assets/img/interior.png"
                            alt="Không gian nhà hàng Hương Việt">
                    </div>
                    <div class="about-img-sub">
                        <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Món đặc sắc">
                    </div>
                    <div class="about-badge">
                        <div class="about-badge-num">10+</div>
                        <div class="about-badge-text">Năm kinh nghiệm</div>
                    </div>
                </div>
                <div class="about-content">
                    <div class="section-label">Câu chuyện của chúng tôi</div>
                    <h2 class="section-title">Hơn một thập kỷ giữ hương vị <em
                            style="color:var(--primary);font-style:italic">quê nhà</em></h2>
                    <p class="section-subtitle">Từ năm 2014, Hương Việt đã trở thành điểm hẹn quen thuộc của hàng nghìn
                        gia đình và nhóm bạn tại TP.HCM — nơi giao thoa giữa ẩm thực dân dã và không gian hiện đại.</p>
                    <div class="features">
                        <div class="feature">
                            <div class="feature-icon"><i class="fa-solid fa-wheat-awn"></i></div>
                            <div>
                                <div class="feature-title">Nguyên liệu tươi sống mỗi ngày</div>
                                <div class="feature-desc">Nhập hàng trực tiếp từ chợ đầu mối Bình Điền, không qua trung
                                    gian, đảm bảo độ tươi ngon.</div>
                            </div>
                        </div>
                        <div class="feature">
                            <div class="feature-icon"><i class="fa-solid fa-fire-burner"></i></div>
                            <div>
                                <div class="feature-title">Bếp trưởng 15 năm kinh nghiệm</div>
                                <div class="feature-desc">Đội ngũ đầu bếp được đào tạo bài bản, am hiểu ẩm thực từng
                                    vùng miền của Việt Nam.</div>
                            </div>
                        </div>
                        <div class="feature">
                            <div class="feature-icon"><i class="fa-solid fa-users"></i></div>
                            <div>
                                <div class="feature-title">Phục vụ nhóm 5–200 người</div>
                                <div class="feature-desc">Có phòng VIP riêng tư, sảnh tiệc cho tổ chức sự kiện lớn nhỏ,
                                    liên hoan cuối năm.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ============================================================
     PROMOTIONS
============================================================ -->
        <section class="promo-section">
            <div class="section-head center">
                <div class="section-label">Ưu đãi hấp dẫn</div>
                <h2 class="section-title">Đừng bỏ lỡ</h2>
            </div>
            <div class="promo-grid">
                <div class="promo-card">
                    <div class="promo-card-bg"><img src="${pageContext.request.contextPath}/assets/img/dish3.png"
                            alt=""></div>
                    <div class="promo-card-body">
                        <span class="promo-tag">🔥 Hot Deal</span>
                        <h3 class="promo-title">Mâm hải sản tươi — Giảm 20% cuối tuần</h3>
                        <p class="promo-desc">Áp dụng thứ 7 & Chủ Nhật từ 17:00 – 21:00. Đặt trước để đảm bảo bàn.</p>
                        <a href="${pageContext.request.contextPath}/booking" class="btn-promo">
                            <i class="fa-solid fa-calendar-check"></i> Đặt bàn ngay
                        </a>
                    </div>
                </div>
                <div class="promo-card">
                    <div class="promo-card-bg"><img src="${pageContext.request.contextPath}/assets/img/dish4.png"
                            alt=""></div>
                    <div class="promo-card-body">
                        <span class="promo-tag">🎂 Sinh nhật</span>
                        <h3 class="promo-title">Giảm 15% cho bàn tiệc sinh nhật</h3>
                        <p class="promo-desc">Bánh miễn phí + ưu đãi 15% hóa đơn khi đặt tiệc sinh nhật từ 10 người.</p>
                        <a href="${pageContext.request.contextPath}/booking" class="btn-promo">
                            <i class="fa-solid fa-gift"></i> Đặt tiệc
                        </a>
                    </div>
                </div>
                <div class="promo-card">
                    <div class="promo-card-bg"><img src="${pageContext.request.contextPath}/assets/img/dish2.png"
                            alt=""></div>
                    <div class="promo-card-body">
                        <span class="promo-tag">🥂 Liên hoan</span>
                        <h3 class="promo-title">Set liên hoan nhóm từ 8 người</h3>
                        <p class="promo-desc">Set riêng cho nhóm bạn, đồng nghiệp — đủ món, đủ vui từ 2.500.000 đ/bàn.
                        </p>
                        <a href="${pageContext.request.contextPath}/booking" class="btn-promo">
                            <i class="fa-solid fa-arrow-right"></i> Xem set menu
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- ============================================================
     CTA — BOOKING BANNER
============================================================ -->
        <section class="cta-section" id="contact">
            <div class="section-label">Đặt bàn ngay</div>
            <h2 class="section-title" style="font-family:var(--font-serif)">Đảm bảo bàn của bạn ngay hôm nay</h2>
            <p>Đặt trước để nhận ưu đãi tốt nhất và không lo hết chỗ vào giờ cao điểm.</p>
            <form class="cta-form" action="${pageContext.request.contextPath}/booking" method="post">
                <input type="hidden" name="fromLanding" value="true">
                <input type="text" class="cta-input" name="customerName" placeholder="Họ và tên...">
                <input type="tel" class="cta-input" name="customerPhone" placeholder="Số điện thoại...">
                <input type="date" class="cta-input" name="bookingDate">
                <button type="submit" class="btn-cta">
                    <i class="fa-solid fa-arrow-right"></i> Đặt bàn
                </button>
            </form>
        </section>

        <!-- ============================================================
     FOOTER
============================================================ -->
        <footer class="footer" id="footer">
            <div class="footer-grid">
                <div class="footer-brand">
                    <div class="footer-logo">
                        <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                        <div class="footer-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                    </div>
                    <p class="footer-desc">Không chỉ là nhà hàng, Hương Việt còn là phong cách sống — điểm hẹn của những
                        khoảnh khắc đáng nhớ.</p>
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
                        <li><a href="${pageContext.request.contextPath}/about">Về chúng tôi</a></li>
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
                        <div class="footer-contact-text"><strong>Địa chỉ</strong>123 Nguyễn Huệ, Quận 1, TP.HCM</div>
                    </div>
                    <div class="footer-contact-item">
                        <div class="footer-contact-icon"><i class="fa-solid fa-phone"></i></div>
                        <div class="footer-contact-text"><strong>Hotline</strong>1900 1234 (8:00 – 23:00)</div>
                    </div>
                    <div class="footer-contact-item">
                        <div class="footer-contact-icon"><i class="fa-regular fa-clock"></i></div>
                        <div class="footer-contact-text"><strong>Giờ mở cửa</strong>10:00 – 23:00 hàng ngày</div>
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

            // Menu tabs (visual only — full filter via /menu?categoryId=X)
            document.querySelectorAll('.menu-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.menu-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                });
            });

            // Smooth scroll for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(link => {
                link.addEventListener('click', e => {
                    e.preventDefault();
                    const target = document.querySelector(link.getAttribute('href'));
                    if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                });
            });

            // Mobile burger nav (simple toggle placeholder)
            document.getElementById('navBurger').addEventListener('click', function () {
                document.querySelector('.nav-links').style.display =
                    document.querySelector('.nav-links').style.display === 'flex' ? 'none' : 'flex';
            });
        </script>

    </body>

    </html>