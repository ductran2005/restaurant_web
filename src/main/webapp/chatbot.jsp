<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%-- chatbot.jsp — Hương Việt AI Chatbot Widget Include before </body>:
        <jsp:include page="/chatbot.jsp" />
        --%>

        <!-- Material Symbols (icons) -->
        <link rel="stylesheet"
            href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@48,400,0,0&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@48,400,1,0" />
        <!-- Inter font -->
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" />
        <!-- Chatbot external CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chatbot.css" />

        <%-- Inline <style> loaded LAST so it wins the cascade against landing.css --%>
            <style>
                /* ======================================================
   Hương Việt Chatbot — INLINE OVERRIDE (highest priority)
   Ensures styles are not killed by landing.css dark theme
   ====================================================== */

                /* ------- Toggle Button ------- */
                #chatbot-toggler {
                    position: fixed !important;
                    bottom: 30px !important;
                    right: 35px !important;
                    height: 50px !important;
                    width: 50px !important;
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    cursor: pointer !important;
                    border-radius: 50% !important;
                    background: #f4b400 !important;
                    border: none !important;
                    box-shadow: 0 6px 24px rgba(244, 180, 0, 0.55) !important;
                    transition: all 0.25s ease !important;
                    z-index: 10000 !important;
                    padding: 0 !important;
                    margin: 0 !important;
                }

                #chatbot-toggler:hover {
                    background: #d9a000 !important;
                    transform: scale(1.08) !important;
                }

                body.show-chatbot #chatbot-toggler {
                    transform: rotate(90deg) !important;
                }

                #chatbot-toggler span {
                    color: #fff !important;
                    position: absolute !important;
                    font-size: 26px !important;
                    line-height: 1 !important;
                    transition: opacity 0.2s !important;
                    background: transparent !important;
                }

                #chatbot-toggler span:last-child {
                    opacity: 0 !important;
                }

                body.show-chatbot #chatbot-toggler span:first-child {
                    opacity: 0 !important;
                }

                body.show-chatbot #chatbot-toggler span:last-child {
                    opacity: 1 !important;
                }

                /* ------- Popup Window ------- */
                .chatbot-popup {
                    position: fixed !important;
                    right: 25px !important;
                    bottom: 90px !important;
                    width: 420px !important;
                    background: #ffffff !important;
                    overflow: hidden !important;
                    border-radius: 15px !important;
                    opacity: 0 !important;
                    transform: scale(0.2) !important;
                    transform-origin: bottom right !important;
                    pointer-events: none !important;
                    box-shadow: 0 0 128px rgba(0, 0, 0, 0.15), 0 32px 64px -48px rgba(0, 0, 0, 0.5) !important;
                    transition: opacity 0.15s ease, transform 0.15s ease !important;
                    z-index: 10001 !important;
                    font-family: "Inter", sans-serif !important;
                }

                body.show-chatbot .chatbot-popup {
                    opacity: 1 !important;
                    pointer-events: auto !important;
                    transform: scale(1) !important;
                }

                /* ------- Header ------- */
                .chatbot-popup .chat-header {
                    display: flex !important;
                    align-items: center !important;
                    background: #f4b400 !important;
                    padding: 15px 22px !important;
                    justify-content: space-between !important;
                }

                .chatbot-popup .chat-header .chatbot-logo {
                    height: 35px !important;
                    width: 35px !important;
                    padding: 6px !important;
                    fill: #f4b400 !important;
                    background: #ffffff !important;
                    border-radius: 50% !important;
                    flex-shrink: 0 !important;
                }

                .chatbot-popup .chat-header .logo-text {
                    color: #ffffff !important;
                    font-size: 1.2rem !important;
                    font-weight: 600 !important;
                    margin: 0 !important;
                    padding: 0 !important;
                    background: transparent !important;
                    font-family: "Inter", sans-serif !important;
                }

                .chatbot-popup .chat-header .logo-subtitle {
                    color: rgba(255, 255, 255, 0.88) !important;
                    font-size: 0.75rem !important;
                    display: flex !important;
                    align-items: center !important;
                    gap: 4px !important;
                    margin: 2px 0 0 !important;
                    background: transparent !important;
                }

                .chatbot-popup .online-dot {
                    width: 7px !important;
                    height: 7px !important;
                    background: #4dff8e !important;
                    border-radius: 50% !important;
                    display: inline-block !important;
                    flex-shrink: 0 !important;
                }

                .chatbot-popup #close-chatbot {
                    border: none !important;
                    color: #ffffff !important;
                    height: 40px !important;
                    width: 40px !important;
                    font-size: 1.9rem !important;
                    margin-right: -10px !important;
                    padding-top: 2px !important;
                    cursor: pointer !important;
                    border-radius: 50% !important;
                    background: transparent !important;
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    transition: background 0.2s !important;
                    line-height: 1 !important;
                }

                .chatbot-popup #close-chatbot:hover {
                    background: rgba(0, 0, 0, 0.15) !important;
                }

                /* ------- Chat Body ------- */
                .chatbot-popup .chat-body {
                    padding: 25px 22px !important;
                    display: flex !important;
                    gap: 20px !important;
                    height: 460px !important;
                    margin-bottom: 82px !important;
                    overflow-y: auto !important;
                    flex-direction: column !important;
                    background: #ffffff !important;
                    scrollbar-width: thin !important;
                }

                .chatbot-popup .chat-body .message {
                    display: flex !important;
                    gap: 11px !important;
                    align-items: center !important;
                    background: transparent !important;
                }

                .chatbot-popup .chat-body .bot-message .bot-avatar {
                    height: 35px !important;
                    width: 35px !important;
                    padding: 6px !important;
                    fill: #ffffff !important;
                    flex-shrink: 0 !important;
                    margin-bottom: 2px !important;
                    align-self: flex-end !important;
                    background: #f4b400 !important;
                    border-radius: 50% !important;
                }

                .chatbot-popup .chat-body .user-message {
                    flex-direction: column !important;
                    align-items: flex-end !important;
                }

                .chatbot-popup .chat-body .message .message-text {
                    padding: 12px 16px !important;
                    max-width: 75% !important;
                    font-size: 0.95rem !important;
                    line-height: 1.55 !important;
                    font-family: "Inter", sans-serif !important;
                }

                .chatbot-popup .chat-body .bot-message .message-text {
                    background-color: #fff8e1 !important;
                    border: 1px solid #f4e29a !important;
                    border-radius: 13px 13px 13px 3px !important;
                    color: #1a1a1a !important;
                }

                .chatbot-popup .chat-body .user-message .message-text {
                    color: #ffffff !important;
                    background-color: #f4b400 !important;
                    border-radius: 13px 13px 3px 13px !important;
                }

                .chatbot-popup .chat-body .bot-message.thinking .message-text {
                    padding: 2px 16px !important;
                    background-color: #fff8e1 !important;
                    border: 1px solid #f4e29a !important;
                    border-radius: 13px 13px 13px 3px !important;
                }

                .chatbot-popup .thinking-indicator {
                    display: flex !important;
                    gap: 4px !important;
                    padding: 15px 0 !important;
                    background: transparent !important;
                }

                .chatbot-popup .thinking-indicator .dot {
                    height: 7px !important;
                    width: 7px !important;
                    border-radius: 50% !important;
                    background: #c8930a !important;
                    animation: hvCbDotPulseInline 1.8s ease-in-out infinite !important;
                }

                .chatbot-popup .thinking-indicator .dot:nth-child(1) {
                    animation-delay: 0.2s !important;
                }

                .chatbot-popup .thinking-indicator .dot:nth-child(2) {
                    animation-delay: 0.3s !important;
                }

                .chatbot-popup .thinking-indicator .dot:nth-child(3) {
                    animation-delay: 0.4s !important;
                }

                @keyframes hvCbDotPulseInline {

                    0%,
                    44% {
                        transform: translateY(0);
                    }

                    28% {
                        opacity: 0.4;
                        transform: translateY(-5px);
                    }

                    44% {
                        opacity: 0.2;
                    }
                }

                /* ------- Footer ------- */
                .chatbot-popup .chat-footer {
                    position: absolute !important;
                    bottom: 0 !important;
                    width: 100% !important;
                    background: #ffffff !important;
                    padding: 15px 22px 20px !important;
                }

                .chatbot-popup .chat-form {
                    display: flex !important;
                    align-items: center !important;
                    background: #ffffff !important;
                    border-radius: 32px !important;
                    outline: 1px solid #f4d060 !important;
                    position: relative !important;
                }

                .chatbot-popup .chat-form:focus-within {
                    outline: 2px solid #f4b400 !important;
                }

                .chatbot-popup .message-input {
                    border: none !important;
                    outline: none !important;
                    height: 47px !important;
                    width: 100% !important;
                    resize: none !important;
                    max-height: 180px !important;
                    font-size: 0.97rem !important;
                    padding: 13px 13px 13px 16px !important;
                    border-radius: inherit !important;
                    background: transparent !important;
                    color: #1a1a1a !important;
                    box-shadow: none !important;
                    font-family: "Inter", sans-serif !important;
                }

                .chatbot-popup .message-input::placeholder {
                    color: #aaa !important;
                }

                .chatbot-popup .chat-controls {
                    display: flex !important;
                    height: 47px !important;
                    gap: 3px !important;
                    align-items: center !important;
                    align-self: flex-end !important;
                    padding-right: 6px !important;
                    background: transparent !important;
                }

                .chatbot-popup .chat-controls button {
                    height: 35px !important;
                    width: 35px !important;
                    border: none !important;
                    font-size: 1.15rem !important;
                    cursor: pointer !important;
                    color: #c8930a !important;
                    background: transparent !important;
                    border-radius: 50% !important;
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    padding: 0 !important;
                    line-height: 1 !important;
                    box-shadow: none !important;
                    transition: background 0.2s !important;
                }

                .chatbot-popup .chat-controls button:hover {
                    background: #fff8e1 !important;
                }

                .chatbot-popup .chat-controls #send-message {
                    color: #ffffff !important;
                    display: none !important;
                    background: #f4b400 !important;
                    box-shadow: 0 3px 10px rgba(244, 180, 0, 0.4) !important;
                }

                .chatbot-popup .message-input:valid~.chat-controls #send-message {
                    display: flex !important;
                }

                .chatbot-popup .chat-controls #send-message:hover {
                    background: #d9a000 !important;
                }

                .chatbot-popup .file-upload-wrapper {
                    display: flex !important;
                    align-items: center !important;
                }

                /* ------- Emoji Picker ------- */
                .chatbot-popup em-emoji-picker {
                    position: absolute !important;
                    left: 50% !important;
                    top: -337px !important;
                    width: 100% !important;
                    max-width: 350px !important;
                    max-height: 330px !important;
                    visibility: hidden !important;
                    transform: translateX(-50%) !important;
                    z-index: 10010 !important;
                }

                body.show-emoji-picker .chatbot-popup em-emoji-picker {
                    visibility: visible !important;
                }

                /* ------- Responsive ------- */
                @media screen and (max-width: 600px) {
                    .chatbot-popup {
                        width: 100% !important;
                        right: 0 !important;
                        bottom: 0 !important;
                        border-radius: 0 !important;
                        height: 100% !important;
                    }

                    .chatbot-popup .chat-body {
                        height: 100% !important;
                        margin-bottom: 0 !important;
                    }

                    #chatbot-toggler {
                        right: 16px !important;
                        bottom: 16px !important;
                    }
                }
            </style>

            <!-- ═══════════════════════════════════════════
     Toggle Button (fixed, bottom-right)
     ═══════════════════════════════════════════ -->
            <button id="chatbot-toggler" aria-label="Mở / Đóng trợ lý AI Hương Việt">
                <span class="material-symbols-outlined">mode_comment</span>
                <span class="material-symbols-rounded">close</span>
            </button>

            <!-- ═══════════════════════════════════════════
     Chatbot Popup Window
     ═══════════════════════════════════════════ -->
            <div class="chatbot-popup" role="dialog" aria-label="Trợ lý AI Hương Việt" aria-modal="true">

                <!-- Header -->
                <div class="chat-header">
                    <div class="header-info" style="display:flex;gap:10px;align-items:center;">
                        <svg class="chatbot-logo" xmlns="http://www.w3.org/2000/svg" width="50" height="50"
                            viewBox="0 0 1024 1024">
                            <path
                                d="M738.3 287.6H285.7c-59 0-106.8 47.8-106.8 106.8v303.1c0 59 47.8 106.8 106.8 106.8h81.5v111.1c0 .7.8 1.1 1.4.7l166.9-110.6 41.8-.8h117.4l43.6-.4c59 0 106.8-47.8 106.8-106.8V394.5c0-59-47.8-106.9-106.8-106.9zM351.7 448.2c0-29.5 23.9-53.5 53.5-53.5s53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5-53.5-23.9-53.5-53.5zm157.9 267.1c-67.8 0-123.8-47.5-132.3-109h264.6c-8.6 61.5-64.5 109-132.3 109zm110-213.7c-29.5 0-53.5-23.9-53.5-53.5s23.9-53.5 53.5-53.5 53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5zM867.2 644.5V453.1h26.5c19.4 0 35.1 15.7 35.1 35.1v121.1c0 19.4-15.7 35.1-35.1 35.1h-26.5zM95.2 609.4V488.2c0-19.4 15.7-35.1 35.1-35.1h26.5v191.3h-26.5c-19.4 0-35.1-15.7-35.1-35.1zM561.5 149.6c0 23.4-15.6 43.3-36.9 49.7v44.9h-30v-44.9c-21.4-6.5-36.9-26.3-36.9-49.7 0-28.6 23.3-51.9 51.9-51.9s51.9 23.3 51.9 51.9z" />
                        </svg>
                        <div>
                            <h2 class="logo-text">Hương Việt AI</h2>
                            <p class="logo-subtitle">
                                <span class="online-dot"></span> Trực tuyến
                            </p>
                        </div>
                    </div>
                    <button id="close-chatbot" class="material-symbols-rounded" aria-label="Đóng"
                        title="Đóng">keyboard_arrow_down</button>
                </div>

                <!-- Chat Body -->
                <div class="chat-body" role="log" aria-live="polite">
                    <!-- Welcome message -->
                    <div class="message bot-message">
                        <svg class="bot-avatar" xmlns="http://www.w3.org/2000/svg" width="50" height="50"
                            viewBox="0 0 1024 1024">
                            <path
                                d="M738.3 287.6H285.7c-59 0-106.8 47.8-106.8 106.8v303.1c0 59 47.8 106.8 106.8 106.8h81.5v111.1c0 .7.8 1.1 1.4.7l166.9-110.6 41.8-.8h117.4l43.6-.4c59 0 106.8-47.8 106.8-106.8V394.5c0-59-47.8-106.9-106.8-106.9zM351.7 448.2c0-29.5 23.9-53.5 53.5-53.5s53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5-53.5-23.9-53.5-53.5zm157.9 267.1c-67.8 0-123.8-47.5-132.3-109h264.6c-8.6 61.5-64.5 109-132.3 109zm110-213.7c-29.5 0-53.5-23.9-53.5-53.5s23.9-53.5 53.5-53.5 53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5zM867.2 644.5V453.1h26.5c19.4 0 35.1 15.7 35.1 35.1v121.1c0 19.4-15.7 35.1-35.1 35.1h-26.5zM95.2 609.4V488.2c0-19.4 15.7-35.1 35.1-35.1h26.5v191.3h-26.5c-19.4 0-35.1-15.7-35.1-35.1zM561.5 149.6c0 23.4-15.6 43.3-36.9 49.7v44.9h-30v-44.9c-21.4-6.5-36.9-26.3-36.9-49.7 0-28.6 23.3-51.9 51.9-51.9s51.9 23.3 51.9 51.9z" />
                        </svg>
                        <div class="message-text">
                            Xin chào! 👋<br />
                            Tôi là trợ lý AI của nhà hàng <strong>Hương Việt</strong>.<br />
                            Tôi có thể giúp gì cho bạn hôm nay?
                        </div>
                    </div>
                </div>

                <!-- Chat Footer -->
                <div class="chat-footer">
                    <form action="#" class="chat-form">
                        <textarea placeholder="Nhắn tin cho Hương Việt AI..." class="message-input" rows="1" required
                            aria-label="Nhập tin nhắn" maxlength="500"></textarea>
                        <div class="chat-controls">
                            <button type="button" id="emoji-picker" class="material-symbols-rounded" aria-label="Emoji"
                                title="Emoji">sentiment_satisfied</button>
                            <div class="file-upload-wrapper">
                                <input type="file" accept="image/*" id="file-input" hidden />
                                <button type="button" id="file-upload" class="material-symbols-rounded"
                                    aria-label="Đính kèm" title="Đính kèm">attach_file</button>
                            </div>
                            <button type="submit" id="send-message" class="material-symbols-rounded" aria-label="Gửi"
                                title="Gửi">arrow_upward</button>
                        </div>
                    </form>
                </div>

            </div><!-- /.chatbot-popup -->

            <!-- emoji-mart -->
            <script src="https://cdn.jsdelivr.net/npm/emoji-mart@latest/dist/browser.js"></script>
            <!-- Chatbot JS — inline to avoid Spring MVC routing issues -->
            <script>
                (function () {
                    'use strict';

                    var BOT_RESPONSES = [
                        {
                            keywords: ['xin chào', 'hello', 'hi', 'chào', 'hey', 'chao'],
                            reply: 'Xin chào! 👋 Tôi là trợ lý AI của nhà hàng <strong>Hương Việt</strong>. Tôi có thể giúp gì cho bạn hôm nay?',
                            quickReplies: ['Xem thực đơn 🍜', 'Đặt bàn 📅', 'Giờ mở cửa 🕐']
                        },
                        {
                            keywords: ['thực đơn', 'menu', 'món', 'ăn gì', 'mon an'],
                            reply: '🍜 <strong>Thực đơn nổi bật của Hương Việt:</strong><br>• Phở bò đặc biệt<br>• Bún bò Huế truyền thống<br>• Cơm tấm sườn bì chả<br>• Bánh mì đặc biệt<br>• Gỏi cuốn tươi',
                            quickReplies: ['Giá cả 💰', 'Món chay 🥗', 'Đồ uống 🥤']
                        },
                        {
                            keywords: ['đặt bàn', 'dat ban', 'reservation', 'booking'],
                            reply: '📅 <strong>Đặt bàn tại Hương Việt:</strong><br><br>Vui lòng cung cấp:<br>• Ngày & giờ mong muốn<br>• Số lượng khách<br>• Tên liên lạc & SĐT<br><br>Hoặc gọi <strong>0901 234 567</strong> để đặt ngay! 🎉',
                            quickReplies: ['Gọi ngay 📞', 'Khuyến mãi 🎁', 'Địa chỉ 📍']
                        },
                        {
                            keywords: ['giờ', 'gio', 'mở cửa', 'mo cua', 'đóng cửa'],
                            reply: '🕐 <strong>Giờ hoạt động của Hương Việt:</strong><br><br>📌 Thứ 2 – Thứ 6: <strong>10:00 – 22:00</strong><br>📌 Thứ 7 – CN: <strong>08:00 – 23:00</strong><br><br>Luôn sẵn sàng phục vụ bạn! ❤️',
                            quickReplies: ['Địa chỉ 📍', 'Đặt bàn 📅', 'Liên hệ 📞']
                        },
                        {
                            keywords: ['địa chỉ', 'dia chi', 'ở đâu', 'o dau', 'location'],
                            reply: '📍 <strong>Địa chỉ nhà hàng Hương Việt:</strong><br><br>🏠 123 Đường Lê Lợi, Quận 1<br>TP. Hồ Chí Minh<br><br>Gần chợ Bến Thành, có bãi đỗ xe miễn phí! 🚗',
                            quickReplies: ['Giờ mở cửa 🕐', 'Đặt bàn 📅', 'Liên hệ 📞']
                        },
                        {
                            keywords: ['giá', 'gia', 'bao nhiêu', 'tien', 'price'],
                            reply: '💰 <strong>Bảng giá tham khảo:</strong><br><br>• Phở bò: 65.000 – 95.000đ<br>• Bún bò Huế: 60.000 – 80.000đ<br>• Cơm tấm: 55.000 – 75.000đ<br>• Đồ uống: 25.000 – 50.000đ',
                            quickReplies: ['Xem thực đơn 🍜', 'Đặt bàn 📅', 'Khuyến mãi 🎁']
                        },
                        {
                            keywords: ['khuyến mãi', 'khuyen mai', 'ưu đãi', 'giảm giá', 'promotion'],
                            reply: '🎁 <strong>Ưu đãi hiện tại:</strong><br><br>⭐ Giảm <strong>15%</strong> khi đặt trước 2 ngày<br>⭐ Combo gia đình (4 người) giảm <strong>20%</strong><br>⭐ Sinh nhật: miễn phí 1 món tráng miệng',
                            quickReplies: ['Đặt bàn 📅', 'Liên hệ 📞', 'Xem thực đơn 🍜']
                        },
                        {
                            keywords: ['liên hệ', 'lien he', 'contact', 'điện thoại', 'phone'],
                            reply: '📞 <strong>Thông tin liên hệ:</strong><br><br>📱 Hotline: <strong>0901 234 567</strong><br>📧 info@huongviet.vn<br>💬 Zalo: 0901 234 567<br><br>Hỗ trợ 8:00 – 22:00 mỗi ngày!',
                            quickReplies: ['Địa chỉ 📍', 'Đặt bàn 📅', 'Giờ mở cửa 🕐']
                        },
                        {
                            keywords: ['đồ uống', 'do uong', 'drink', 'tra', 'ca phe', 'cafe'],
                            reply: '🥤 <strong>Thức uống tại Hương Việt:</strong><br><br>☕ Cà phê sữa đá / đen đá<br>🍵 Trà chanh mật ong<br>🥤 Sinh tố trái cây tươi<br>🧃 Nước ép tự nhiên<br>🍺 Bia & nước giải khát',
                            quickReplies: ['Giá cả 💰', 'Xem thực đơn 🍜', 'Đặt bàn 📅']
                        },
                        {
                            keywords: ['chay', 'vegetarian', 'vegan'],
                            reply: '🥗 <strong>Menu chay tại Hương Việt:</strong><br><br>• Phở chay đặc biệt<br>• Cơm chay đa dạng<br>• Gỏi chay tươi<br>• Bún chay hầm<br><br>Thông báo trước khi đặt bàn nhé! 🙏',
                            quickReplies: ['Giá cả 💰', 'Đặt bàn 📅', 'Liên hệ 📞']
                        },
                        {
                            keywords: ['cảm ơn', 'cam on', 'thank', 'tuyệt', 'hay'],
                            reply: 'Cảm ơn bạn rất nhiều! 🙏❤️ Hương Việt luôn hân hạnh phục vụ bạn. Chúc bạn một ngày vui vẻ!',
                            quickReplies: ['Đặt bàn 📅', 'Xem thực đơn 🍜']
                        }
                    ];

                    var DEFAULT_REPLY = '🤔 Xin lỗi, tôi chưa hiểu câu hỏi.<br><br>Bạn có thể hỏi về:<br>• Thực đơn & giá cả<br>• Đặt bàn<br>• Giờ mở cửa & địa chỉ<br>• Khuyến mãi<br><br>Hoặc gọi hotline <strong>0901 234 567</strong>! 📞';

                    /* Normalise Vietnamese for matching */
                    function norm(s) {
                        return s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\u0111/g, 'd');
                    }

                    function getResponse(text) {
                        var n = norm(text);
                        for (var i = 0; i < BOT_RESPONSES.length; i++) {
                            var item = BOT_RESPONSES[i];
                            for (var j = 0; j < item.keywords.length; j++) {
                                if (n.indexOf(norm(item.keywords[j])) !== -1) {
                                    return { reply: item.reply, quickReplies: item.quickReplies || [] };
                                }
                            }
                        }
                        return { reply: DEFAULT_REPLY, quickReplies: ['Thực đơn 🍜', 'Đặt bàn 📅', 'Liên hệ 📞'] };
                    }

                    var BOT_AVATAR = '<svg class="bot-avatar" xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 1024 1024"><path d="M738.3 287.6H285.7c-59 0-106.8 47.8-106.8 106.8v303.1c0 59 47.8 106.8 106.8 106.8h81.5v111.1c0 .7.8 1.1 1.4.7l166.9-110.6 41.8-.8h117.4l43.6-.4c59 0 106.8-47.8 106.8-106.8V394.5c0-59-47.8-106.9-106.8-106.9zM351.7 448.2c0-29.5 23.9-53.5 53.5-53.5s53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5-53.5-23.9-53.5-53.5zm157.9 267.1c-67.8 0-123.8-47.5-132.3-109h264.6c-8.6 61.5-64.5 109-132.3 109zm110-213.7c-29.5 0-53.5-23.9-53.5-53.5s23.9-53.5 53.5-53.5 53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5zM867.2 644.5V453.1h26.5c19.4 0 35.1 15.7 35.1 35.1v121.1c0 19.4-15.7 35.1-35.1 35.1h-26.5zM95.2 609.4V488.2c0-19.4 15.7-35.1 35.1-35.1h26.5v191.3h-26.5c-19.4 0-35.1-15.7-35.1-35.1zM561.5 149.6c0 23.4-15.6 43.3-36.9 49.7v44.9h-30v-44.9c-21.4-6.5-36.9-26.3-36.9-49.7 0-28.6 23.3-51.9 51.9-51.9s51.9 23.3 51.9 51.9z"/></svg>';

                    var THINKING_HTML = BOT_AVATAR + '<div class="message-text"><div class="thinking-indicator"><div class="dot"></div><div class="dot"></div><div class="dot"></div></div></div>';

                    /* Wait for DOM */
                    function init() {
                        var chatBody = document.querySelector('.chat-body');
                        var messageInput = document.querySelector('.message-input');
                        var sendBtn = document.querySelector('#send-message');
                        var fileInput = document.querySelector('#file-input');
                        var fileUploadWrap = document.querySelector('.file-upload-wrapper');
                        var toggler = document.querySelector('#chatbot-toggler');
                        var closeBtn = document.querySelector('#close-chatbot');
                        var chatForm = document.querySelector('.chat-form');
                        var fileUploadBtn = document.querySelector('#file-upload');
                        var emojiBtn = document.querySelector('#emoji-picker');

                        if (!chatBody || !messageInput || !toggler) return;

                        var userData = { message: null, file: { data: null, mime_type: null } };
                        var initialH = messageInput.scrollHeight;

                        function scrollBot() {
                            chatBody.scrollTo({ top: chatBody.scrollHeight, behavior: 'smooth' });
                        }

                        function mkEl(html) {
                            var d = document.createElement('div');
                            d.className = 'message';
                            d.innerHTML = html;
                            return d;
                        }

                        function appendQR(replies) {
                            if (!replies || !replies.length) return;
                            var wrap = document.createElement('div');
                            wrap.style.cssText = 'display:flex;flex-wrap:wrap;gap:6px;padding:0 0 4px 46px;';
                            wrap.className = 'hv-quick-replies';
                            replies.forEach(function (label) {
                                var b = document.createElement('button');
                                b.type = 'button';
                                b.textContent = label;
                                b.style.cssText = 'background:rgba(244,180,0,0.15);border:1px solid rgba(244,180,0,0.5);color:#c8930a;border-radius:14px;padding:5px 12px;font-size:12px;cursor:pointer;font-family:inherit;';
                                b.addEventListener('click', function () {
                                    document.querySelectorAll('.hv-quick-replies').forEach(function (el) { el.remove(); });
                                    submit(label.replace(/\s[\u{1F300}-\u{1FFFF}📅📍💰🎁📞🕐🥤🥗🍜]/gu, '').trim());
                                });
                                wrap.appendChild(b);
                            });
                            chatBody.appendChild(wrap);
                            scrollBot();
                        }

                        function botRespond(div) {
                            var message = userData.message || '';
                            var apiUrl = '${pageContext.request.contextPath}/chatbot-api';

                            fetch(apiUrl, {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({ message: message })
                            })
                                .then(function (res) { return res.json(); })
                                .then(function (data) {
                                    div.classList.remove('thinking');
                                    if (data.reply) {
                                        div.querySelector('.message-text').innerHTML =
                                            data.reply.replace(/\n/g, '<br>');
                                    } else {
                                        div.querySelector('.message-text').innerHTML =
                                            '⚠️ Có lỗi xảy ra. Vui lòng thử lại hoặc gọi <strong>0901 234 567</strong>.';
                                    }
                                    userData.file = { data: null, mime_type: null };
                                    scrollBot();
                                })
                                .catch(function () {
                                    div.classList.remove('thinking');
                                    div.querySelector('.message-text').innerHTML =
                                        '⚠️ Không thể kết nối. Vui lòng thử lại hoặc gọi <strong>0901 234 567</strong>.';
                                    scrollBot();
                                });
                        }


                        function submit(text) {
                            if (!text) return;
                            userData.message = text;
                            document.querySelectorAll('.hv-quick-replies').forEach(function (el) { el.remove(); });

                            var userDiv = mkEl('<div class="message-text"></div>' +
                                (userData.file.data ? '<img src="data:' + userData.file.mime_type + ';base64,' + userData.file.data + '" class="attachment"/>' : ''));
                            userDiv.classList.add('user-message');
                            userDiv.querySelector('.message-text').textContent = text;
                            chatBody.appendChild(userDiv);
                            scrollBot();

                            setTimeout(function () {
                                var incoming = mkEl(THINKING_HTML);
                                incoming.classList.add('bot-message', 'thinking');
                                chatBody.appendChild(incoming);
                                scrollBot();
                                botRespond(incoming);
                            }, 600);
                        }

                        function send(e) {
                            e.preventDefault();
                            var t = messageInput.value.trim();
                            if (!t) return;
                            messageInput.value = '';
                            messageInput.dispatchEvent(new Event('input'));
                            submit(t);
                        }

                        /* Events */
                        toggler.addEventListener('click', function () {
                            document.body.classList.toggle('show-chatbot');
                            if (document.body.classList.contains('show-chatbot')) {
                                setTimeout(function () { messageInput.focus(); }, 300);
                            }
                        });

                        if (closeBtn) {
                            closeBtn.addEventListener('click', function () {
                                document.body.classList.remove('show-chatbot');
                            });
                        }

                        if (sendBtn) sendBtn.addEventListener('click', send);

                        messageInput.addEventListener('keydown', function (e) {
                            if (e.key === 'Enter' && !e.shiftKey && window.innerWidth > 768) {
                                if (messageInput.value.trim()) send(e);
                            }
                        });

                        messageInput.addEventListener('input', function () {
                            messageInput.style.height = initialH + 'px';
                            messageInput.style.height = messageInput.scrollHeight + 'px';
                            if (chatForm) chatForm.style.borderRadius = messageInput.scrollHeight > initialH ? '15px' : '32px';
                        });

                        if (fileInput) {
                            fileInput.addEventListener('change', function () {
                                var f = fileInput.files[0];
                                if (!f) return;
                                var r = new FileReader();
                                r.onload = function (ev) {
                                    userData.file = { data: ev.target.result.split(',')[1], mime_type: f.type };
                                    if (fileUploadWrap) fileUploadWrap.classList.add('file-selected');
                                };
                                r.readAsDataURL(f);
                                fileInput.value = '';
                            });
                        }

                        if (fileUploadBtn && fileInput) {
                            fileUploadBtn.addEventListener('click', function () { fileInput.click(); });
                        }

                        /* emoji-mart */
                        if (emojiBtn && typeof EmojiMart !== 'undefined') {
                            var picker = new EmojiMart.Picker({
                                theme: 'light', skinTonePosition: 'none', preview: 'none',
                                onEmojiSelect: function (emoji) {
                                    var s = messageInput.selectionStart, e2 = messageInput.selectionEnd;
                                    messageInput.setRangeText(emoji.native, s, e2, 'end');
                                    messageInput.focus();
                                    messageInput.dispatchEvent(new Event('input'));
                                },
                                onClickOutside: function (ev) {
                                    if (ev.target.id === 'emoji-picker') {
                                        document.body.classList.toggle('show-emoji-picker');
                                    } else {
                                        document.body.classList.remove('show-emoji-picker');
                                    }
                                }
                            });
                            if (chatForm) chatForm.appendChild(picker);
                        } else if (emojiBtn) {
                            emojiBtn.addEventListener('click', function () { messageInput.focus(); });
                        }
                    }

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', init);
                    } else {
                        init();
                    }
                })();
            </script>