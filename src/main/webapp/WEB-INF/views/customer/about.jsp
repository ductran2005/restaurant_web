<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Về chúng tôi - Hương Việt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
</head>
<body>
    <%@ include file="_navbar.jsp" %>

    <div class="about-page">
        <!-- Hero Section -->
        <section class="about-hero">
            <div class="hero-content">
                <h1>Về Hương Việt</h1>
                <p>Hơn một thập kỷ giữ hương vị quê nhà</p>
            </div>
        </section>

        <div class="container">
            <!-- Story Section -->
            <section class="story-section">
                <div class="section-grid">
                    <div class="story-content">
                        <h2>Câu chuyện của chúng tôi</h2>
                        <p>Từ năm 2014, Hương Việt đã trở thành điểm hẹn quen thuộc của hàng nghìn gia đình và nhóm bạn tại TP.HCM — nơi giao thoa giữa ẩm thực dân dã và không gian hiện đại.</p>
                        
                        <p>Khởi đầu từ một quán nhỏ với 10 bàn, chúng tôi đã phát triển thành chuỗi 5 chi nhánh với hơn 200 món ăn đặc sắc từ ba miền. Điều không thay đổi là tình yêu với ẩm thực Việt Nam và sự tận tâm phục vụ khách hàng.</p>

                        <div class="stats">
                            <div class="stat-item">
                                <div class="stat-number">10+</div>
                                <div class="stat-label">Năm kinh nghiệm</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">200+</div>
                                <div class="stat-label">Món ăn</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">5</div>
                                <div class="stat-label">Chi nhánh</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">10k+</div>
                                <div class="stat-label">Khách hàng</div>
                            </div>
                        </div>
                    </div>
                    <div class="story-image">
                        <img src="${pageContext.request.contextPath}/assets/img/interior.png" alt="Không gian nhà hàng">
                    </div>
                </div>
            </section>

            <!-- Values Section -->
            <section class="values-section">
                <h2>Giá trị cốt lõi</h2>
                <div class="values-grid">
                    <div class="value-item">
                        <div class="value-icon">
                            <i class="fa-solid fa-wheat-awn"></i>
                        </div>
                        <h3>Nguyên liệu tươi sống</h3>
                        <p>Nhập hàng trực tiếp từ chợ đầu mối Bình Điền mỗi ngày, không qua trung gian, đảm bảo độ tươi ngon tối đa.</p>
                    </div>
                    <div class="value-item">
                        <div class="value-icon">
                            <i class="fa-solid fa-fire-burner"></i>
                        </div>
                        <h3>Bếp trưởng kinh nghiệm</h3>
                        <p>Đội ngũ đầu bếp được đào tạo bài bản với hơn 15 năm kinh nghiệm, am hiểu ẩm thực từng vùng miền.</p>
                    </div>
                    <div class="value-item">
                        <div class="value-icon">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <h3>Phục vụ tận tâm</h3>
                        <p>Đội ngũ nhân viên được đào tạo chuyên nghiệp, luôn sẵn sàng mang đến trải nghiệm tuyệt vời nhất.</p>
                    </div>
                    <div class="value-item">
                        <div class="value-icon">
                            <i class="fa-solid fa-heart"></i>
                        </div>
                        <h3>Không gian ấm cúng</h3>
                        <p>Thiết kế kết hợp giữa truyền thống và hiện đại, tạo không gian ấm cúng cho mọi dịp đặc biệt.</p>
                    </div>
                </div>
            </section>

            <!-- Team Section -->
            <section class="team-section">
                <h2>Đội ngũ của chúng tôi</h2>
                <div class="team-grid">
                    <div class="team-member">
                        <div class="member-avatar">
                            <i class="fa-solid fa-user-tie"></i>
                        </div>
                        <h3>Nguyễn Văn A</h3>
                        <p class="member-role">Tổng Giám Đốc</p>
                        <p>Với hơn 20 năm kinh nghiệm trong ngành F&B, anh A đã dẫn dắt Hương Việt trở thành thương hiệu uy tín.</p>
                    </div>
                    <div class="team-member">
                        <div class="member-avatar">
                            <i class="fa-solid fa-chef-hat"></i>
                        </div>
                        <h3>Trần Thị B</h3>
                        <p class="member-role">Bếp Trưởng</p>
                        <p>Bà B là người giữ gìn và phát triển các công thức món ăn truyền thống, mang đến hương vị đậm đà.</p>
                    </div>
                    <div class="team-member">
                        <div class="member-avatar">
                            <i class="fa-solid fa-user-check"></i>
                        </div>
                        <h3>Lê Văn C</h3>
                        <p class="member-role">Quản Lý Vận Hành</p>
                        <p>Anh C đảm bảo chất lượng dịch vụ và trải nghiệm khách hàng luôn ở mức tốt nhất.</p>
                    </div>
                </div>
            </section>

            <!-- Awards Section -->
            <section class="awards-section">
                <h2>Giải thưởng & Chứng nhận</h2>
                <div class="awards-grid">
                    <div class="award-item">
                        <div class="award-icon">
                            <i class="fa-solid fa-trophy"></i>
                        </div>
                        <h3>Top 10 Nhà hàng Việt Nam 2023</h3>
                        <p>Được bình chọn bởi Hiệp hội Ẩm thực Việt Nam</p>
                    </div>
                    <div class="award-item">
                        <div class="award-icon">
                            <i class="fa-solid fa-certificate"></i>
                        </div>
                        <h3>Chứng nhận HACCP</h3>
                        <p>Đảm bảo an toàn thực phẩm theo tiêu chuẩn quốc tế</p>
                    </div>
                    <div class="award-item">
                        <div class="award-icon">
                            <i class="fa-solid fa-star"></i>
                        </div>
                        <h3>4.8/5 sao trên Google</h3>
                        <p>Từ hơn 2,000 đánh giá của khách hàng</p>
                    </div>
                </div>
            </section>

            <!-- Mission Section -->
            <section class="mission-section">
                <div class="mission-content">
                    <h2>Sứ mệnh của chúng tôi</h2>
                    <blockquote>
                        "Mang đến những trải nghiệm ẩm thực đích thực, kết nối mọi người qua hương vị quê nhà, 
                        và tạo ra những kỷ niệm đáng nhớ cho mỗi khách hàng."
                    </blockquote>
                    <p>Chúng tôi tin rằng ẩm thực không chỉ là món ăn, mà còn là cầu nối văn hóa, là nơi gắn kết tình cảm gia đình và bạn bè.</p>
                </div>
            </section>
        </div>
    </div>

    <%@ include file="_footer.jsp" %>
</body>
</html>