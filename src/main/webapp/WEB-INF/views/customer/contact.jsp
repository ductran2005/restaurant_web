<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ - Hương Việt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
</head>
<body>
    <%@ include file="_navbar.jsp" %>

    <div class="contact-page">
        <div class="container">
            <div class="page-header">
                <h1><i class="fa-solid fa-phone"></i> Liên hệ với chúng tôi</h1>
                <p>Chúng tôi luôn sẵn sàng lắng nghe và hỗ trợ bạn</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <i class="fa-solid fa-exclamation-triangle"></i>
                    ${error}
                </div>
            </c:if>

            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fa-solid fa-check-circle"></i>
                    ${success}
                </div>
            </c:if>

            <div class="contact-grid">
                <!-- Contact Info -->
                <div class="contact-info">
                    <h2>Thông tin liên hệ</h2>
                    
                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fa-solid fa-location-dot"></i>
                        </div>
                        <div class="contact-details">
                            <h3>Địa chỉ</h3>
                            <p>123 Nguyễn Huệ, Quận 1, TP.HCM</p>
                        </div>
                    </div>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fa-solid fa-phone"></i>
                        </div>
                        <div class="contact-details">
                            <h3>Hotline</h3>
                            <p>1900 1234</p>
                            <small>8:00 - 23:00 hàng ngày</small>
                        </div>
                    </div>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fa-solid fa-envelope"></i>
                        </div>
                        <div class="contact-details">
                            <h3>Email</h3>
                            <p>info@huongviet.com</p>
                            <p>booking@huongviet.com</p>
                        </div>
                    </div>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <i class="fa-regular fa-clock"></i>
                        </div>
                        <div class="contact-details">
                            <h3>Giờ mở cửa</h3>
                            <p>10:00 - 23:00 hàng ngày</p>
                            <small>Kể cả cuối tuần và ngày lễ</small>
                        </div>
                    </div>

                    <!-- Social Media -->
                    <div class="social-media">
                        <h3>Theo dõi chúng tôi</h3>
                        <div class="social-links">
                            <a href="#" class="social-link facebook">
                                <i class="fa-brands fa-facebook-f"></i>
                            </a>
                            <a href="#" class="social-link instagram">
                                <i class="fa-brands fa-instagram"></i>
                            </a>
                            <a href="#" class="social-link tiktok">
                                <i class="fa-brands fa-tiktok"></i>
                            </a>
                            <a href="#" class="social-link youtube">
                                <i class="fa-brands fa-youtube"></i>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Contact Form -->
                <div class="contact-form-section">
                    <h2>Gửi tin nhắn cho chúng tôi</h2>
                    
                    <form method="post" class="contact-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="name">Họ và tên *</label>
                                <input type="text" id="name" name="name" value="${name}" required>
                            </div>
                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" name="phone" value="${phone}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="email">Email *</label>
                            <input type="email" id="email" name="email" value="${email}" required>
                        </div>

                        <div class="form-group">
                            <label for="subject">Chủ đề *</label>
                            <select id="subject" name="subject" required>
                                <option value="">Chọn chủ đề</option>
                                <option value="Đặt bàn" ${subject == 'Đặt bàn' ? 'selected' : ''}>Đặt bàn</option>
                                <option value="Thắc mắc menu" ${subject == 'Thắc mắc menu' ? 'selected' : ''}>Thắc mắc về menu</option>
                                <option value="Phản hồi dịch vụ" ${subject == 'Phản hồi dịch vụ' ? 'selected' : ''}>Phản hồi dịch vụ</option>
                                <option value="Hợp tác" ${subject == 'Hợp tác' ? 'selected' : ''}>Hợp tác kinh doanh</option>
                                <option value="Khác" ${subject == 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="message">Nội dung *</label>
                            <textarea id="message" name="message" rows="6" required placeholder="Nhập nội dung tin nhắn của bạn...">${message}</textarea>
                        </div>

                        <button type="submit" class="btn btn-primary btn-large">
                            <i class="fa-solid fa-paper-plane"></i>
                            Gửi tin nhắn
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
                        height="400" 
                        style="border:0;" 
                        allowfullscreen="" 
                        loading="lazy" 
                        referrerpolicy="no-referrer-when-downgrade">
                    </iframe>
                </div>
                <div class="map-info">
                    <div class="map-info-item">
                        <i class="fa-solid fa-car"></i>
                        <span>Có bãi đỗ xe miễn phí</span>
                    </div>
                    <div class="map-info-item">
                        <i class="fa-solid fa-bus"></i>
                        <span>Gần các tuyến xe buýt 03, 19, 36</span>
                    </div>
                    <div class="map-info-item">
                        <i class="fa-solid fa-train-subway"></i>
                        <span>Cách ga Metro Bến Thành 500m</span>
                    </div>
                </div>
            </div>

            <!-- FAQ Section -->
            <div class="faq-section">
                <h2>Câu hỏi thường gặp</h2>
                <div class="faq-list">
                    <div class="faq-item">
                        <div class="faq-question">
                            <i class="fa-solid fa-question-circle"></i>
                            Nhà hàng có nhận đặt bàn trước không?
                        </div>
                        <div class="faq-answer">
                            Có, bạn có thể đặt bàn trước qua website, hotline hoặc trực tiếp tại nhà hàng. Chúng tôi khuyến khích đặt trước để đảm bảo có chỗ.
                        </div>
                    </div>
                    <div class="faq-item">
                        <div class="faq-question">
                            <i class="fa-solid fa-question-circle"></i>
                            Nhà hàng có phục vụ tiệc sinh nhật không?
                        </div>
                        <div class="faq-answer">
                            Có, chúng tôi có các gói tiệc sinh nhật với nhiều lựa chọn khác nhau. Vui lòng liên hệ trước ít nhất 1 ngày để được tư vấn.
                        </div>
                    </div>
                    <div class="faq-item">
                        <div class="faq-question">
                            <i class="fa-solid fa-question-circle"></i>
                            Có dịch vụ giao hàng tận nơi không?
                        </div>
                        <div class="faq-answer">
                            Hiện tại chúng tôi chưa có dịch vụ giao hàng, nhưng bạn có thể đặt món trước và đến lấy tại nhà hàng.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="_footer.jsp" %>

    <script>
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