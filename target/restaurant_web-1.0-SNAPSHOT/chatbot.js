document.addEventListener('DOMContentLoaded', function() {
    // widget elements
    const toggleBtn = document.getElementById('chatbot-toggle');
    const container = document.getElementById('chatbot-container');
    const closeBtn = document.getElementById('chatbot-close');
    const messagesEl = document.getElementById('chatbot-messages');
    const input = document.getElementById('chatbot-user-input');
    const sendBtn = document.getElementById('chatbot-send-btn');

    // if widget elements are missing, abort
    if (!toggleBtn || !container || !messagesEl) {
        return;
    }

    function appendMessage(text, sender) {
        const div = document.createElement('div');
        div.className = 'message ' + sender;
        div.textContent = text;
        messagesEl.appendChild(div);
        messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    async function sendMessage() {
        const text = input.value.trim();
        if (!text) return;
        appendMessage(text, 'user');
        input.value = '';
        sendBtn.disabled = true;

        // compute endpoint using context if available
        let url = '/api/chat';
        if (window.appContext) {
            url = window.appContext + url;
        }

        try {
            const resp = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ message: text })
            });
            const data = await resp.json();
            if (data.reply) {
                appendMessage(data.reply, 'bot');
            } else if (data.error) {
                appendMessage('Error: ' + data.error, 'bot');
            }
        } catch (e) {
            appendMessage('Network error.', 'bot');
        } finally {
            sendBtn.disabled = false;
        }
    }

    sendBtn.addEventListener('click', sendMessage);
    input.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') sendMessage();
    });

    function openWidget() {
        container.style.display = 'flex';
        toggleBtn.style.display = 'none';
        input.focus();
    }
    function closeWidget() {
        container.style.display = 'none';
        toggleBtn.style.display = 'flex';
    }

    toggleBtn.addEventListener('click', openWidget);
    closeBtn.addEventListener('click', closeWidget);
});