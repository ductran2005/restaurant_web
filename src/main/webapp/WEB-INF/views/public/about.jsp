<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Về Hương Việt - Dấu ấn hơn một thập kỷ giữ hương vị quê nhà tại TP.HCM.">
    <title>Về chúng tôi — Nhà hàng Hương Việt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/mobile.css">
    <style>
        .about-page-hero {
            padding: 140px 48px 60px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .about-page-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, 0.08) 0%, transparent 60%);
            pointer-events: none;
        }

        .about-page-hero .section-label {
            display: inline-flex;
            margin-bottom: 16px;
        }

        .about-page-hero h1 {
            font-family: var(--font-serif);
            font-size: clamp(32px, 5vw, 52px);
            color: var(--text);
            margin-bottom: 12px;
        }

        .about-page-hero h1 em {
            color: var(--primary);
            font-style: italic;
        }

        .about-page-hero p {
            font-size: 15px;
            color: var(--text-muted);
            max-width: 520px;
            margin: 0 auto;
        }

        /* Container cho phần thân trang about */
        .about-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 48px 80px;
        }

        /* Story Section - Giống landing */
        .story-section {
            margin-bottom: 100px;
        }
        
        /* Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 40px;
            padding-top: 40px;
            border-top: 1px solid var(--border);
        }
        
        .stat-item {
            text-align: center;
        }
        .stat-number {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary);
            line-height: 1;
            margin-bottom: 8px;
        }
        .stat-label {
            font-size: 12px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        /* Generic Grid Styles cho Values, Team, Awards */
        .generic-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            margin-top: 40px;
        }

        .generic-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 32px;
            text-align: center;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .generic-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.4);
            border-color: rgba(232, 160, 32, 0.3);
        }

        .generic-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: rgba(232, 160, 32, 0.1);
            color: var(--primary);
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }

        .generic-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 12px;
        }

        .generic-desc {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
        }
        
        .role {
            font-size: 12px;
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            font-weight: 600;
            margin-bottom: 12px;
        }

        /* Grid specific cho 4 cột (Values) */
        .values-grid {
            grid-template-columns: repeat(4, 1fr);
        }

        /* Mission Blockquote */
        .mission-blockquote {
            text-align: center;
            padding: 60px 40px;
            background: rgba(232, 160, 32, 0.05);
            border: 1px solid rgba(232, 160, 32, 0.2);
            border-radius: 20px;
            margin-top: 80px;
            position: relative;
        }

        .mission-blockquote i.fa-quote-left {
            font-size: 40px;
            color: var(--primary);
            opacity: 0.3;
            margin-bottom: 20px;
        }

        .mission-blockquote blockquote {
            font-family: var(--font-serif);
            font-size: 24px;
            font-style: italic;
            color: var(--text);
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .mission-blockquote p {
            color: var(--text-muted);
            font-size: 15px;
        }

        @media (max-width: 1024px) {
            .values-grid { grid-template-columns: repeat(2, 1fr); }
            .generic-grid { grid-template-columns: repeat(2, 1fr); }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 640px) {
            .about-page-hero { padding: 120px 24px 40px; }
            .about-container { padding: 0 24px 60px; }
            .values-grid, .generic-grid, .stats-grid { grid-template-columns: 1fr; }
            .mission-blockquote { padding: 40px 20px; }
            .mission-blockquote blockquote { font-size: 20px; }
        }
    </style>
</head>
<body>
    <!-- ── NAVBAR ── -->
    <nav class="navbar" id="navbar">
        <a href="${pageContext.request.contextPath}/" class="nav-logo">
            <div class="nav-logo-icon"><i class="fa-solid fa-utensils"></i></div>
            <div class="nav-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/menu">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/about" class="active">Về chúng tôi</a>
            <a href="${pageContext.request.contextPath}/contact">Liên hệ</a>
            <a href="${pageContext.request.contextPath}/login">Đặt bàn</a>
        </div>
        <div class="nav-actions">
            <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
            <a href="${pageContext.request.contextPath}/login" class="btn-book">
                <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
            </a>
        </div>
        <div class="nav-burger" id="navBurger"><span></span><span></span><span></span></div>
    </nav>

    <!-- ── HERO ── -->
    <section class="about-page-hero">
        <div class="section-label"><i class="fa-solid fa-info-circle"></i> Về nhà hàng</div>
        <h1>Câu chuyện <em>Hương Việt</em></h1>
        <p>Hơn một thập kỷ giữ gìn và phát triển tinh hoa ẩm thực quê nhà giữa lòng thành phố hiện đại.</p>
    </section>

    <div class="about-container">
        
        <!-- Story Section -->
        <section class="story-section about-grid">
            <div class="about-images">
                <div class="about-img-main">
                    <img src="${pageContext.request.contextPath}/assets/img/interior.png" alt="Không gian nhà hàng Hương Việt">
                </div>
                <!-- Remove the sub-img because it's hard to position without landing specific layout CSS, or use it if we included the full `.about-grid` CSS -->
                <div class="about-img-sub">
                    <img src="${pageContext.request.contextPath}/assets/img/dish2.png" alt="Món đặc sắc">
                </div>
                <div class="about-badge">
                    <div class="about-badge-num">10+</div>
                    <div class="about-badge-text">Năm kinh nghiệm</div>
                </div>
            </div>
            <div class="about-content">
                <div class="section-label">Hành trình của chúng tôi</div>
                <h2 class="section-title">Từ quán nhỏ đến<br><em style="color:var(--primary);font-style:italic">Nhà hàng hàng đầu</em></h2>
                <p class="section-subtitle" style="margin-bottom: 16px;">Từ năm 2014, Hương Việt đã trở thành điểm hẹn quen thuộc của hàng nghìn gia đình và nhóm bạn tại TP.HCM — nơi giao thoa giữa ẩm thực dân dã và không gian hiện đại.</p>
                <p class="section-subtitle">Khởi đầu từ một quán nhỏ với 10 bàn, chúng tôi đã phát triển thành nhà hàng hàng đầu với hơn 50 món ăn đặc sắc từ ba miền. Điều không thay đổi là tình yêu với ẩm thực Việt Nam và sự tận tâm phục vụ khách hàng.</p>
                
                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-number">10+</div>
                        <div class="stat-label">Năm phát triển</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">50+</div>
                        <div class="stat-label">Món ăn</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">10k+</div>
                        <div class="stat-label">Khách quen</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Values Section -->
        <section class="values-section" style="margin-top: 60px;">
            <div class="section-head center">
                <div class="section-label">Giá trị cốt lõi</div>
                <h2 class="section-title">Cam kết vì <em style="color:var(--primary);font-style:italic">khách hàng</em></h2>
            </div>
            <div class="generic-grid values-grid">
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-wheat-awn"></i></div>
                    <h3 class="generic-title">Nguyên liệu tươi sống</h3>
                    <p class="generic-desc">Nhập hàng trực tiếp từ chợ đầu mối Bình Điền mỗi ngày, không qua trung gian, đảm bảo độ tươi ngon tối đa.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-fire-burner"></i></div>
                    <h3 class="generic-title">Bếp trưởng kinh nghiệm</h3>
                    <p class="generic-desc">Đội ngũ đầu bếp được đào tạo bài bản với hơn 15 năm kinh nghiệm, am hiểu ẩm thực từng vùng miền.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-users"></i></div>
                    <h3 class="generic-title">Phục vụ tận tâm</h3>
                    <p class="generic-desc">Đội ngũ nhân viên chuyên nghiệp, thân thiện, luôn sẵn sàng mang đến trải nghiệm tuyệt vời nhất cho thực khách.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-heart"></i></div>
                    <h3 class="generic-title">Không gian ấm cúng</h3>
                    <p class="generic-desc">Thiết kế tinh tế kết hợp giữa truyền thống và hiện đại, tạo không gian hoàn hảo cho mọi dịp đặc biệt.</p>
                </div>
            </div>
        </section>

        <!-- Team Section -->
        <section class="team-section" style="margin-top: 100px;">
            <div class="section-head center">
                <div class="section-label">Đội ngũ lãnh đạo</div>
                <h2 class="section-title">Những người kiến tạo <em style="color:var(--primary);font-style:italic">Hương Việt</em></h2>
            </div>
            <div class="generic-grid">
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-user-tie"></i></div>
                    <h3 class="generic-title">Nguyễn Văn A</h3>
                    <div class="role">Tổng Giám Đốc</div>
                    <p class="generic-desc">Với hơn 20 năm kinh nghiệm trong ngành F&B, anh A đã viết nên câu chuyện thành công của thương hiệu Hương Việt.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-chef-hat"></i></div>
                    <h3 class="generic-title">Trần Thị B</h3>
                    <div class="role">Bếp Trưởng</div>
                    <p class="generic-desc">Người giữ lửa và thổi hồn vào từng món ăn, giữ gìn trọn vẹn hương vị truyền thống tinh túy ba miền.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-user-check"></i></div>
                    <h3 class="generic-title">Lê Văn C</h3>
                    <div class="role">Quản Lý Vận Hành</div>
                    <p class="generic-desc">Người luôn đôn đốc, đảm bảo chất lượng dịch vụ và quy trình vận hành trơn tru mỗi ngày tại tất cả chi nhánh.</p>
                </div>
            </div>
        </section>

        <!-- Awards Section -->
        <section class="awards-section" style="margin-top: 100px;">
            <div class="section-head center">
                <div class="section-label">Thành tựu đạt được</div>
                <h2 class="section-title">Giải thưởng & Chứng nhận</h2>
            </div>
            <div class="generic-grid">
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-trophy"></i></div>
                    <h3 class="generic-title">Top 10 Nhà hàng Việt Nam</h3>
                    <p class="generic-desc">Được bình chọn bởi Hiệp hội Văn hóa Ẩm thực Việt Nam năm 2023.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-certificate"></i></div>
                    <h3 class="generic-title">Chứng nhận HACCP</h3>
                    <p class="generic-desc">Tiêu chuẩn quốc tế đảm bảo vệ sinh an toàn thực phẩm khắt khe nhất.</p>
                </div>
                <div class="generic-card">
                    <div class="generic-icon"><i class="fa-solid fa-star"></i></div>
                    <h3 class="generic-title">Đánh giá xuất sắc</h3>
                    <p class="generic-desc">Đạt 4.8/5 sao trên Google Reviews từ hơn 2,000 khách hàng thực tế.</p>
                </div>
            </div>
        </section>

        <!-- Mission -->
        <div class="mission-blockquote">
            <i class="fa-solid fa-quote-left"></i>
            <blockquote>"Mang đến những trải nghiệm ẩm thực đích thực, kết nối mọi người qua hương vị quê nhà, và tạo ra những kỷ niệm đáng nhớ cho mỗi khách hàng."</blockquote>
            <p>Sứ mệnh của tập thể Hương Việt - Vì chúng tôi tin rằng bữa ăn không chỉ để no, mà còn là nơi gắn kết yêu thương.</p>
        </div>

    </div>

    <!-- ── FOOTER ── -->
    <footer class="footer" id="footer">
        <div class="footer-grid">
            <div class="footer-brand">
                <div class="footer-logo">
                    <div class="footer-logo-icon"><i class="fa-solid fa-utensils"></i></div>
                    <div class="footer-logo-text">Hương Việt<span>Nhà hàng & Quán nhậu</span></div>
                </div>
                <p class="footer-desc">Không chỉ là nhà hàng, Hương Việt còn là phong cách sống — điểm hẹn của những khoảnh khắc đáng nhớ.</p>
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
                    <li><a href="${pageContext.request.contextPath}/about">Về chúng tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact">Liên hệ</a></li>
                    <li><a href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
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

    <script>
        // Navbar scroll
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 60));

        // Burger menu
        document.getElementById('navBurger').addEventListener('click', function () {
            const links = document.querySelector('.nav-links');
            links.style.display = links.style.display === 'flex' ? 'none' : 'flex';
        });
    </script>

    <!-- chatbot widget include -->
    <jsp:include page="/chatbot.jsp" />

</body>
</html>