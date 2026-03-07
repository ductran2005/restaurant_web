/* ============================================================
   Hương Việt AI — Chatbot JavaScript
   Reference: new design with emoji picker, file upload, thinking
   ============================================================ */

(function () {
    'use strict';

    /* ============================================================
       Bot Response Knowledge Base (Vietnamese)
       ============================================================ */
    const BOT_RESPONSES = [
        {
            keywords: ['xin chào', 'hello', 'hi', 'chào', 'hey', 'chao'],
            reply: 'Xin chào! 👋 Tôi là trợ lý AI của nhà hàng **Hương Việt**. Tôi có thể giúp gì cho bạn hôm nay?',
            quickReplies: ['Xem thực đơn 🍜', 'Đặt bàn 📅', 'Giờ mở cửa 🕐']
        },
        {
            keywords: ['thực đơn', 'menu', 'món', 'ăn gì', 'món ăn'],
            reply: '🍜 **Thực đơn nổi bật của Hương Việt:**\n• Phở bò đặc biệt\n• Bún bò Huế truyền thống\n• Cơm tấm sườn bì chả\n• Bánh mì đặc biệt\n• Gỏi cuốn tươi\n\nBạn muốn biết giá hay chi tiết món nào không?',
            quickReplies: ['Giá cả 💰', 'Món chay 🥗', 'Đồ uống 🥤']
        },
        {
            keywords: ['đặt bàn', 'đặt chỗ', 'reservation', 'booking', 'book'],
            reply: '📅 **Đặt bàn tại Hương Việt:**\n\nVui lòng cung cấp:\n• Ngày & giờ mong muốn\n• Số lượng khách\n• Tên liên lạc & SĐT\n\nHoặc gọi **0901 234 567** để đặt ngay!\nChúng tôi xác nhận trong vòng 30 phút 🎉',
            quickReplies: ['Gọi ngay 📞', 'Khuyến mãi 🎁', 'Địa chỉ 📍']
        },
        {
            keywords: ['giờ', 'mở cửa', 'đóng cửa', 'gio mo cua'],
            reply: '🕐 **Giờ hoạt động của Hương Việt:**\n\n📌 Thứ 2 – Thứ 6: **10:00 – 22:00**\n📌 Thứ 7 – Chủ Nhật: **08:00 – 23:00**\n\nChúng tôi luôn sẵn sàng phục vụ bạn! ❤️',
            quickReplies: ['Địa chỉ 📍', 'Đặt bàn 📅', 'Liên hệ 📞']
        },
        {
            keywords: ['địa chỉ', 'ở đâu', 'cho toi biet', 'duong', 'location'],
            reply: '📍 **Địa chỉ nhà hàng Hương Việt:**\n\n🏠 123 Đường Lê Lợi, Quận 1\nTP. Hồ Chí Minh\n\nGần chợ Bến Thành, có bãi đỗ xe miễn phí! 🚗',
            quickReplies: ['Giờ mở cửa 🕐', 'Đặt bàn 📅', 'Liên hệ 📞']
        },
        {
            keywords: ['giá', 'bao nhiêu', 'tien', 'chi phi', 'price'],
            reply: '💰 **Bảng giá tham khảo:**\n\n• Phở bò: 65.000 – 95.000đ\n• Bún bò Huế: 60.000 – 80.000đ\n• Cơm tấm: 55.000 – 75.000đ\n• Đồ uống: 25.000 – 50.000đ\n\nGiá hợp lý, chất lượng tuyệt vời! 😊',
            quickReplies: ['Xem thực đơn 🍜', 'Đặt bàn 📅', 'Khuyến mãi 🎁']
        },
        {
            keywords: ['khuyến mãi', 'ưu đãi', 'giảm giá', 'khuyen mai', 'promotion'],
            reply: '🎁 **Ưu đãi hiện tại tại Hương Việt:**\n\n⭐ Giảm **15%** khi đặt bàn trước 2 ngày\n⭐ Combo gia đình (4 người) giảm **20%**\n⭐ Sinh nhật: **miễn phí** 1 món tráng miệng\n\nLiên hệ ngay để biết thêm chi tiết!',
            quickReplies: ['Đặt bàn 📅', 'Liên hệ 📞', 'Xem thực đơn 🍜']
        },
        {
            keywords: ['liên hệ', 'contact', 'dien thoai', 'phone', 'so dt'],
            reply: '📞 **Thông tin liên hệ Hương Việt:**\n\n📱 Hotline: **0901 234 567**\n📧 Email: info@huongviet.vn\n💬 Zalo: 0901 234 567\n\nHỗ trợ 8:00 – 22:00 mỗi ngày! 🌟',
            quickReplies: ['Địa chỉ 📍', 'Đặt bàn 📅', 'Giờ mở cửa 🕐']
        },
        {
            keywords: ['đồ uống', 'nuoc', 'drink', 'tra', 'ca phe', 'cafe'],
            reply: '🥤 **Thức uống tại Hương Việt:**\n\n☕ Cà phê sữa đá / đen đá\n🍵 Trà chanh mật ong\n🥤 Sinh tố trái cây tươi\n🧃 Nước ép tự nhiên\n🍺 Bia & nước giải khát\n\nTất cả làm tươi mỗi ngày! 🌿',
            quickReplies: ['Giá cả 💰', 'Xem thực đơn 🍜', 'Đặt bàn 📅']
        },
        {
            keywords: ['chay', 'vegetarian', 'vegan', 'khong thit'],
            reply: '🥗 **Menu chay tại Hương Việt:**\n\nChúng tôi có menu chay đặc biệt:\n• Phở chay đặc biệt\n• Cơm chay đa dạng\n• Gỏi chay tươi\n• Bún chay hầm\n\nVui lòng thông báo khi đặt bàn nhé! 🙏',
            quickReplies: ['Giá cả 💰', 'Đặt bàn 📅', 'Liên hệ 📞']
        },
        {
            keywords: ['cảm ơn', 'cam on', 'thank', 'tuyet', 'hay'],
            reply: 'Cảm ơn bạn rất nhiều! 🙏❤️ Hương Việt luôn hân hạnh được phục vụ bạn. Chúc bạn một ngày tuyệt vời!',
            quickReplies: ['Đặt bàn 📅', 'Xem thực đơn 🍜']
        }
    ];

    const DEFAULT_REPLY = '🤔 Xin lỗi, tôi chưa hiểu câu hỏi của bạn.\n\nBạn có thể hỏi về:\n• Thực đơn & giá cả\n• Đặt bàn\n• Giờ mở cửa & địa chỉ\n• Khuyến mãi\n\nHoặc gọi hotline **0901 234 567** để hỗ trợ trực tiếp! 📞';

    /* ============================================================
       DOM References
       ============================================================ */
    const chatBody = document.querySelector(".chat-body");
    const messageInput = document.querySelector(".message-input");
    const sendMessageButton = document.querySelector("#send-message");
    const fileInput = document.querySelector("#file-input");
    const fileUploadWrapper = document.querySelector(".file-upload-wrapper");
    const chatbotToggler = document.querySelector("#chatbot-toggler");
    const closeChatbot = document.querySelector("#close-chatbot");
    const chatForm = document.querySelector(".chat-form");

    if (!chatBody || !messageInput || !chatbotToggler) return; // guard

    /* ============================================================
       State
       ============================================================ */
    const userData = {
        message: null,
        file: { data: null, mime_type: null }
    };

    const initialInputHeight = messageInput.scrollHeight;

    /* ============================================================
       Utility: Normalise Vietnamese text for matching
       ============================================================ */
    function normalise(str) {
        return str
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd');
    }

    /* ============================================================
       Utility: simple markdown → safe HTML
       ============================================================ */
    function mdToHtml(text) {
        return text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\n/g, '<br>');
    }

    /* ============================================================
       Bot SVG avatar (inline — same as the reference design)
       ============================================================ */
    const BOT_AVATAR_SVG = `<svg class="bot-avatar" xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 1024 1024">
        <path d="M738.3 287.6H285.7c-59 0-106.8 47.8-106.8 106.8v303.1c0 59 47.8 106.8 106.8 106.8h81.5v111.1c0 .7.8 1.1 1.4.7l166.9-110.6 41.8-.8h117.4l43.6-.4c59 0 106.8-47.8 106.8-106.8V394.5c0-59-47.8-106.9-106.8-106.9zM351.7 448.2c0-29.5 23.9-53.5 53.5-53.5s53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5-53.5-23.9-53.5-53.5zm157.9 267.1c-67.8 0-123.8-47.5-132.3-109h264.6c-8.6 61.5-64.5 109-132.3 109zm110-213.7c-29.5 0-53.5-23.9-53.5-53.5s23.9-53.5 53.5-53.5 53.5 23.9 53.5 53.5-23.9 53.5-53.5 53.5zM867.2 644.5V453.1h26.5c19.4 0 35.1 15.7 35.1 35.1v121.1c0 19.4-15.7 35.1-35.1 35.1h-26.5zM95.2 609.4V488.2c0-19.4 15.7-35.1 35.1-35.1h26.5v191.3h-26.5c-19.4 0-35.1-15.7-35.1-35.1zM561.5 149.6c0 23.4-15.6 43.3-36.9 49.7v44.9h-30v-44.9c-21.4-6.5-36.9-26.3-36.9-49.7 0-28.6 23.3-51.9 51.9-51.9s51.9 23.3 51.9 51.9z"></path>
    </svg>`;

    const THINKING_HTML = `${BOT_AVATAR_SVG}
        <div class="message-text">
            <div class="thinking-indicator">
                <div class="dot"></div>
                <div class="dot"></div>
                <div class="dot"></div>
            </div>
        </div>`;

    /* ============================================================
       Create message element
       ============================================================ */
    function createMessageElement(content, ...classes) {
        const div = document.createElement('div');
        div.classList.add('message', ...classes);
        div.innerHTML = content;
        return div;
    }

    /* ============================================================
       Scroll chat body to bottom
       ============================================================ */
    function scrollToBottom() {
        chatBody.scrollTo({ top: chatBody.scrollHeight, behavior: 'smooth' });
    }

    /* ============================================================
       Get bot response
       ============================================================ */
    function getResponse(text) {
        const n = normalise(text);
        for (const item of BOT_RESPONSES) {
            for (const kw of item.keywords) {
                if (n.includes(normalise(kw))) {
                    return { reply: item.reply, quickReplies: item.quickReplies || [] };
                }
            }
        }
        return { reply: DEFAULT_REPLY, quickReplies: ['Thực đơn 🍜', 'Đặt bàn 📅', 'Liên hệ 📞'] };
    }

    /* ============================================================
       Append quick-reply chips below the last bot message
       ============================================================ */
    function appendQuickReplies(replies) {
        if (!replies || !replies.length) return;
        const wrap = document.createElement('div');
        wrap.className = 'quick-replies';
        wrap.style.cssText = 'display:flex;flex-wrap:wrap;gap:6px;padding:0 0 4px 46px;';
        replies.forEach(function (label) {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'quick-reply-btn';
            btn.textContent = label;
            btn.style.cssText = 'background:rgba(244,180,0,0.12);border:1px solid rgba(244,180,0,0.5);color:#c8930a;border-radius:14px;padding:5px 12px;font-size:12px;cursor:pointer;font-family:inherit;transition:background 0.2s;';
            btn.addEventListener('mouseenter', () => btn.style.background = 'rgba(244,180,0,0.22)');
            btn.addEventListener('mouseleave', () => btn.style.background = 'rgba(244,180,0,0.12)');
            btn.addEventListener('click', function () {
                // Strip emoji/icon suffix for clean message
                const cleanText = label.replace(/\s[\u{1F300}-\u{1FFFF}📅📍💰🎁📞🕐🥤🥗🍜]/gu, '').trim();
                document.querySelectorAll('.quick-replies').forEach(el => el.remove());
                submitMessage(cleanText);
            });
            wrap.appendChild(btn);
        });
        chatBody.appendChild(wrap);
        scrollToBottom();
    }

    /* ============================================================
       Simulate bot response (with thinking delay)
       ============================================================ */
    function simulateBotResponse(incomingMessageDiv) {
        const response = getResponse(userData.message || '');
        const delay = 700 + Math.random() * 600;

        setTimeout(function () {
            incomingMessageDiv.classList.remove('thinking');
            const messageEl = incomingMessageDiv.querySelector('.message-text');
            messageEl.innerHTML = mdToHtml(response.reply);
            scrollToBottom();

            // Clear file after use
            userData.file = { data: null, mime_type: null };

            appendQuickReplies(response.quickReplies);
        }, delay);
    }

    /* ============================================================
       Core: submit a message text (used by both form and quick replies)
       ============================================================ */
    function submitMessage(text) {
        if (!text) return;
        userData.message = text;

        // Remove existing quick replies
        document.querySelectorAll('.quick-replies').forEach(el => el.remove());

        // Build outgoing bubble
        const userContent = `<div class="message-text"></div>${userData.file.data
                ? `<img src="data:${userData.file.mime_type};base64,${userData.file.data}" class="attachment" />`
                : ''
            }`;
        const outgoing = createMessageElement(userContent, 'user-message');
        outgoing.querySelector('.message-text').textContent = text;
        chatBody.appendChild(outgoing);
        scrollToBottom();

        // Show thinking indicator then respond
        setTimeout(function () {
            const incoming = createMessageElement(THINKING_HTML, 'bot-message', 'thinking');
            chatBody.appendChild(incoming);
            scrollToBottom();
            simulateBotResponse(incoming);
        }, 600);
    }

    /* ============================================================
       Handle form submit / send button
       ============================================================ */
    function handleOutgoingMessage(e) {
        e.preventDefault();
        const text = messageInput.value.trim();
        if (!text) return;
        messageInput.value = '';
        messageInput.dispatchEvent(new Event('input'));
        submitMessage(text);
    }

    /* ============================================================
       Event: Enter key
       ============================================================ */
    messageInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey && window.innerWidth > 768) {
            const text = e.target.value.trim();
            if (text) handleOutgoingMessage(e);
        }
    });

    /* ============================================================
       Event: auto-resize textarea
       ============================================================ */
    messageInput.addEventListener('input', function () {
        messageInput.style.height = initialInputHeight + 'px';
        messageInput.style.height = messageInput.scrollHeight + 'px';
        if (chatForm) {
            chatForm.style.borderRadius =
                messageInput.scrollHeight > initialInputHeight ? '15px' : '32px';
        }
    });

    /* ============================================================
       Event: send button click
       ============================================================ */
    if (sendMessageButton) {
        sendMessageButton.addEventListener('click', handleOutgoingMessage);
    }

    /* ============================================================
       Event: file upload
       ============================================================ */
    if (fileInput) {
        fileInput.addEventListener('change', function () {
            const file = fileInput.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = function (ev) {
                userData.file = {
                    data: ev.target.result.split(',')[1],
                    mime_type: file.type
                };
                if (fileUploadWrapper) fileUploadWrapper.classList.add('file-selected');
            };
            reader.readAsDataURL(file);
            fileInput.value = '';
        });
    }

    const fileUploadBtn = document.querySelector('#file-upload');
    if (fileUploadBtn && fileInput) {
        fileUploadBtn.addEventListener('click', () => fileInput.click());
    }

    /* ============================================================
       Event: emoji picker (emoji-mart)
       ============================================================ */
    const emojiPickerBtn = document.querySelector('#emoji-picker');
    if (emojiPickerBtn && typeof EmojiMart !== 'undefined') {
        const picker = new EmojiMart.Picker({
            theme: 'light',
            skinTonePosition: 'none',
            preview: 'none',
            onEmojiSelect: function (emoji) {
                const { selectionStart: start, selectionEnd: end } = messageInput;
                messageInput.setRangeText(emoji.native, start, end, 'end');
                messageInput.focus();
                messageInput.dispatchEvent(new Event('input'));
            },
            onClickOutside: function (e) {
                if (e.target.id === 'emoji-picker') {
                    document.body.classList.toggle('show-emoji-picker');
                } else {
                    document.body.classList.remove('show-emoji-picker');
                }
            }
        });
        if (chatForm) chatForm.appendChild(picker);
    } else if (emojiPickerBtn) {
        // Fallback if emoji-mart not loaded — just focus the input
        emojiPickerBtn.addEventListener('click', function () {
            messageInput.focus();
        });
    }

    /* ============================================================
       Event: toggle & close chatbot
       ============================================================ */
    chatbotToggler.addEventListener('click', function () {
        document.body.classList.toggle('show-chatbot');
        if (document.body.classList.contains('show-chatbot')) {
            setTimeout(() => messageInput.focus(), 300);
        }
    });

    if (closeChatbot) {
        closeChatbot.addEventListener('click', function () {
            document.body.classList.remove('show-chatbot');
            document.body.classList.remove('show-emoji-picker');
        });
    }
})();
