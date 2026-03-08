<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Liên hệ với nhà hàng Hương Việt - Đặt tiệc, thắc mắc menu, phản hồi dịch vụ.">
    <title>Liên hệ — Nhà hàng Hương Việt</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <style>
        .contact-page-hero {
            padding: 140px 48px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .contact-page-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(ellipse at 50% 0%, rgba(232, 160, 32, 0.08) 0%, transparent 60%);
            pointer-events: none;
        }

        .contact-page-hero .section-label {
            display: inline-flex;
            margin-bottom: 16px;
        }

        .contact-page-hero h1 {
            font-family: var(--font-serif);
            font-size: clamp(32px, 5vw, 52px);
            color: var(--text);
            margin-bottom: 12px;
        }

        .contact-page-hero h1 em {
            color: var(--primary);
            font-style: italic;
        }

        .contact-page-hero p {
            font-size: 15px;
            color: var(--text-muted);
            max-width: 520px;
            margin: 0 auto;
        }

        /* Container */
        .contact-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 48px 80px;
        }

        /* Alert notifications */
        .alert-error {
            background: rgba(239, 68, 68, 0.08);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #f87171;
            padding: 16px 20px;
            border-radius: 12px;
            font-size: 14px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success {
            background: rgba(34, 197, 94, 0.08);
            border: 1px solid rgba(34, 197, 94, 0.2);
            color: #4ade80;
            padding: 16px 20px;
            border-radius: 12px;
            font-size: 14px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Grid Layout */
        .contact-grid {
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            gap: 60px;
            margin-bottom: 80px;
        }

        /* Info Section */
        .contact-info h2 {
            font-family: var(--font-serif);
            font-size: 28px;
            color: var(--text);
            margin-bottom: 30px;
        }

        .contact-item {
            display: flex;
            align-items: flex-start;
            gap: 20px;
            margin-bottom: 30px;
        }

        .contact-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: rgba(232, 160, 32, 0.1);
            color: var(--primary);
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .contact-details h3 {
            font-size: 16px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 4px;
        }

        .contact-details p {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        .contact-details small {
            display: block;
            font-size: 12px;
            color: rgba(158, 148, 136, 0.7);
            margin-top: 4px;
        }

        /* Social Media */
        .social-media {
            margin-top: 50px;
            padding-top: 40px;
            border-top: 1px solid var(--border);
        }

        .social-media h3 {
            font-size: 18px;
            color: var(--text);
            margin-bottom: 20px;
        }

        .social-links {
            display: flex;
            gap: 16px;
        }

        .social-link {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.05);
            color: var(--text);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            transition: all 0.3s;
            border: 1px solid var(--border);
        }

        .social-link:hover {
            background: var(--primary);
            color: #000;
            border-color: var(--primary);
            transform: translateY(-4px);
        }

        /* Form Section */
        .contact-form-section {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 40px;
        }

        .contact-form-section h2 {
            font-family: var(--font-serif);
            font-size: 24px;
            color: var(--text);
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 8px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            color: var(--text);
            font-size: 14px;
            font-family: inherit;
            outline: none;
            transition: all 0.25s;
        }

        .form-group input::placeholder,
        .form-group textarea::placeholder {
            color: var(--text-muted);
        }

        .form-group select option {
            background: var(--bg-card);
            color: var(--text);
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(232, 160, 32, 0.1);
        }

        .btn-submit {
            width: 100%;
            padding: 16px;
            font-size: 15px;
            font-weight: 700;
            background: var(--primary);
            color: #000;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-family: inherit;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
            transition: all 0.3s;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(232, 160, 32, 0.3);
            background: var(--primary-dark);
        }

        /* Maps Section */
        .map-section {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 80px;
        }

        .map-section h2 {
            font-family: var(--font-serif);
            font-size: 28px;
            color: var(--text);
            margin-bottom: 30px;
            text-align: center;
        }

        .map-container {
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--border);
            height: 400px;
            margin-bottom: 30px;
        }

        .map-info {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
        }

        .map-info-item {
            display: flex;
            align-items: center;
            gap: 12px;
            color: var(--text-muted);
            font-size: 14px;
        }

        .map-info-item i {
            color: var(--primary);
            font-size: 20px;
        }

        /* FAQ Section */
        .faq-section {
            max-width: 800px;
            margin: 0 auto;
        }

        .faq-section h2 {
            font-family: var(--font-serif);
            font-size: 28px;
            color: var(--text);
            margin-bottom: 40px;
            text-align: center;
        }

        .faq-item {
            border-bottom: 1px solid var(--border);
            padding: 24px 0;
        }

        .faq-item:first-child {
            border-top: 1px solid var(--border);
        }

        .faq-question {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 16px;
            font-weight: 600;
            color: var(--text);
            cursor: pointer;
            transition: color 0.2s;
        }

        .faq-question:hover {
            color: var(--primary);
        }

        .faq-question i {
            color: var(--primary);
            transition: transform 0.3s;
        }

        .faq-answer {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease-out;
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
            margin-left: 32px;
        }

        .faq-item.active .faq-answer {
            margin-top: 16px;
        }

        .faq-item.active .faq-question i {
            transform: rotate(180deg);
        }

        @media (max-width: 992px) {
            .contact-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 640px) {
            .contact-page-hero { padding: 120px 24px 40px; }
            .contact-container { padding: 0 24px 60px; }
            .form-row { grid-template-columns: 1fr; }
            .contact-form-section { padding: 30px 20px; }
            .map-section { padding: 30px 20px; }
            .map-info { flex-direction: column; gap: 20px; align-items: flex-start; }
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
            <a href="${pageContext.request.contextPath}/booking">Đặt bàn</a>
            <a href="${pageContext.request.contextPath}/booking/status">Tra cứu</a>
            <a href="${pageContext.request.contextPath}/pre-order">Đặt món trước</a>
            <a href="${pageContext.request.contextPath}/about">Về chúng tôi</a>
            <a href="${pageContext.request.contextPath}/contact" class="active">Liên hệ</a>
        </div>
        <div class="nav-actions">
            <div class="hotline"><i class="fa-solid fa-phone-volume"></i> 1900 1234</div>
            <a href="${pageContext.request.contextPath}/booking" class="btn-book">
                <i class="fa-solid fa-calendar-check"></i> Đặt bàn
            </a>
        </div>
        <div class="nav-burger" id="navBurger"><span></span><span></span><span></span></div>
    </nav>

    <!-- ── HERO ── -->
    <section class="contact-page-hero">
        <div class="section-label"><i class="fa-solid fa-phone"></i> Liên hệ</div>
        <h1>Lắng nghe để <em>phục vụ tốt hơn</em></h1>
        <p>Chúng tôi luôn sẵn sàng hỗ trợ, tư vấn và ghi nhận mọi ý kiến đóng góp từ bạn để hoàn thiện hơn mỗi ngày.</p>
    </section>

    <div class="contact-container">
        
        <c:if test="${not empty error}">
            <div class="alert-error">
                <i class="fa-solid fa-circle-exclamation"></i>
                ${error}
            </div>
        </c:if>

        <c:if test="${not empty success}">
            <div class="alert-success">
                <i class="fa-solid fa-circle-check"></i>
                ${success}
            </div>
        </c:if>

        <div class="contact-grid">
            <!-- Info Section -->
            <div class="contact-info">
                <h2>Thông tin liên hệ</h2>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-solid fa-location-dot"></i></div>
                    <div class="contact-details">
                        <h3>Địa chỉ</h3>
                        <p>123 Nguyễn Huệ, Quận 1, TP.HCM</p>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-solid fa-phone"></i></div>
                    <div class="contact-details">
                        <h3>Hotline Đặt bàn</h3>
                        <p>1900 1234</p>
                        <small>Hoạt động từ 8:00 - 23:00 mỗi ngày</small>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-regular fa-envelope"></i></div>
                    <div class="contact-details">
                        <h3>Email Hỗ trợ</h3>
                        <p>info@huongviet.com</p>
                        <p>booking@huongviet.com</p>
                    </div>
                </div>

                <div class="contact-item">
                    <div class="contact-icon"><i class="fa-regular fa-clock"></i></div>
                    <div class="contact-details">
                        <h3>Giờ mở cửa</h3>
                        <p>10:00 - 23:00 hàng ngày</p>
                        <small>Phục vụ cả cuối tuần và ngày lễ</small>
                    </div>
                </div>

                <div class="social-media">
                    <h3>Kết nối với chúng tôi</h3>
                    <div class="social-links">
                        <a href="#" class="social-link" title="Facebook"><i class="fa-brands fa-facebook-f"></i></a>
                        <a href="#" class="social-link" title="Instagram"><i class="fa-brands fa-instagram"></i></a>
                        <a href="#" class="social-link" title="TikTok"><i class="fa-brands fa-tiktok"></i></a>
                        <a href="#" class="social-link" title="Youtube"><i class="fa-brands fa-youtube"></i></a>
                    </div>
                </div>
            </div>

            <!-- Form Section -->
            <div class="contact-form-section">
                <h2>Gửi tin nhắn cho chúng tôi</h2>
                <form method="post" class="contact-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Họ và tên *</label>
                            <input type="text" id="name" name="name" value="${name}" placeholder="Nguyễn Văn A" required>
                        </div>
                        <div class="form-group">
                            <label for="phone">Số điện thoại</label>
                            <input type="tel" id="phone" name="phone" value="${phone}" placeholder="0901234567">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" name="email" value="${email}" placeholder="abc@example.com" required>
                    </div>

                    <div class="form-group">
                        <label for="subject">Chủ đề *</label>
                        <select id="subject" name="subject" required>
                            <option value="">-- Chọn chủ đề --</option>
                            <option value="Đặt bàn" ${subject == 'Đặt bàn' ? 'selected' : ''}>Tư vấn đặt bàn / Đặt tiệc</option>
                            <option value="Thắc mắc menu" ${subject == 'Thắc mắc menu' ? 'selected' : ''}>Thắc mắc về thực đơn</option>
                            <option value="Phản hồi dịch vụ" ${subject == 'Phản hồi dịch vụ' ? 'selected' : ''}>Góp ý & Phản hồi dịch vụ</option>
                            <option value="Hợp tác" ${subject == 'Hợp tác' ? 'selected' : ''}>Hợp tác kinh doanh / Quảng cáo</option>
                            <option value="Khác" ${subject == 'Khác' ? 'selected' : ''}>Câu hỏi khác</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="message">Nội dung chi tiết *</label>
                        <textarea id="message" name="message" rows="5" placeholder="Bạn cần hỗ trợ điều gì..." required>${message}</textarea>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fa-solid fa-paper-plane"></i> Gửi phản hồi
                    </button>
                </form>
            </div>
        </div>

        <!-- Map Section -->
        <div class="map-section">
            <h2>Vị trí nhà hàng</h2>
            <div class="map-container">
                <iframe 
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3919.4326002932!2d106.70204731533414!3d10.776530192319!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752f4b3330bcc9%3A0x2a4d4b2b2b2b2b2b!2zTmd1eeG7hW4gSHXhu4csIFF1YW4gMSwgVGjDoG5oIHBo4buRIEjhu5MgQ2jDrSBNaW5o!5e0!3m2!1svi!2s!4v1234567890123!5m2!1svi!2s"
                    width="100%" 
                    height="100%" 
                    style="border:0;" 
                    allowfullscreen="" 
                    loading="lazy" 
                    referrerpolicy="no-referrer-when-downgrade">
                </iframe>
            </div>
            <div class="map-info">
                <div class="map-info-item">
                    <i class="fa-solid fa-car"></i>
                    <span>Có bãi đỗ xe ô tô/xe máy miễn phí an toàn</span>
                </div>
                <div class="map-info-item">
                    <i class="fa-solid fa-bus"></i>
                    <span>Gần các trạm dừng xe buýt 03, 19, 36</span>
                </div>
                <div class="map-info-item">
                    <i class="fa-solid fa-train-subway"></i>
                    <span>Cách trung tâm thương mại & Metro Bến Thành 500m</span>
                </div>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="faq-section">
            <h2>Câu hỏi thường gặp</h2>
            <div class="faq-list">
                <div class="faq-item">
                    <div class="faq-question">
                        <i class="fa-solid fa-chevron-down"></i>
                        Nhà hàng có nhận đặt bàn sinh nhật, liên hoan trước không?
                    </div>
                    <div class="faq-answer">
                        Chắc chắn rồi. Hương Việt chuyên phục vụ các bữa tiệc từ nhỏ đến lớn. Chúng tôi có đa dạng không gian VIP, sảnh tiệc, cùng ưu đãi tặng kèm hoa/bánh/trang trí khi đặt trước. Bạn có thể sử dụng chức năng Đặt Bàn Khách Đoàn trên trang Đặt Bàn hoặc gọi Hotline.
                    </div>
                </div>
                <div class="faq-item">
                    <div class="faq-question">
                        <i class="fa-solid fa-chevron-down"></i>
                        Nhà hàng có phục vụ món chay không?
                    </div>
                    <div class="faq-answer">
                        Có. Mặc dù chuyên hải sản và các món ăn ba miền, Thực Đơn của chúng tôi vẫn có danh mục các món chay thanh tịnh, dinh dưỡng phù hợp cho nhu cầu của từng thực khách.
                    </div>
                </div>
                <div class="faq-item">
                    <div class="faq-question">
                        <i class="fa-solid fa-chevron-down"></i>
                        Nhà hàng có dịch vụ giao tận nơi (delivery) không?
                    </div>
                    <div class="faq-answer">
                        Hiện tại, để duy trì chất lượng và hương vị đạt chuẩn cao nhất, Hương Việt khuyến khích dùng cơm trực tiếp hoặc sử dụng tính năng "Đặt Món Trước" trên website để tiết kiệm thời gian chờ đợi. Giao hàng tận nơi chúng tôi chỉ đang áp dụng trong phạm vi rất hẹp ở các quận trung tâm.
                    </div>
                </div>
            </div>
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

        // FAQ toggle
        document.querySelectorAll('.faq-question').forEach(question => {
            question.addEventListener('click', function() {
                const faqItem = this.parentElement;
                const answer = faqItem.querySelector('.faq-answer');
                
                faqItem.classList.toggle('active');
                
                if (faqItem.classList.contains('active')) {
                    answer.style.maxHeight = answer.scrollHeight + 'px';
                } else {
                    answer.style.maxHeight = '0';
                }
            });
        });
    </script>
</body>
</html>