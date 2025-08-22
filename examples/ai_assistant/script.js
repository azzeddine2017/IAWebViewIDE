// --- العناصر الرئيسية ---
const messageInput = document.getElementById('messageInput');
const messagesContainer = document.getElementById('messages');
const typingIndicator = document.getElementById('typingIndicator');

// --- إرسال الرسالة عند الضغط على Enter ---
messageInput.addEventListener('keypress', function(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        sendMessage();
    }
});

// --- الدالة الرئيسية لإرسال الرسالة ---
async function sendMessage() {
    const messageText = messageInput.value.trim();
    if (!messageText) return;

    // إضافة رسالة المستخدم إلى الواجهة
    addMessage(messageText, 'user-message');
    messageInput.value = '';

    // إظهار مؤشر الكتابة
    typingIndicator.style.display = 'block';
    messagesContainer.scrollTop = messagesContainer.scrollHeight;

    try {
        // استدعاء دالة Ring وانتظار الرد
        const aiResponse = await window.sendAIMessage(messageText);
        addMessage(aiResponse, 'ai-message');
    } catch (error) {
        console.error('Error:', error);
        addMessage(`❌ عذراً، حدث خطأ: ${error.message}`, 'ai-message');
    } finally {
        // إخفاء مؤشر الكتابة
        typingIndicator.style.display = 'none';
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
}

// --- دالة إضافة الرسائل وتحليل الماركداون ---
function addMessage(text, className) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message ' + className;

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.innerHTML = parseMarkdown(text);
    
    // إضافة زر النسخ لكتل الكود
    contentDiv.querySelectorAll('pre').forEach(pre => {
        const wrapper = document.createElement('div');
        wrapper.className = 'code-block-wrapper';
        
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-btn';
        copyButton.textContent = 'نسخ';
        copyButton.onclick = () => {
            const code = pre.querySelector('code').innerText;
            navigator.clipboard.writeText(code);
            copyButton.textContent = 'تم النسخ!';
            setTimeout(() => { copyButton.textContent = 'نسخ'; }, 2000);
        };
        
        wrapper.appendChild(pre.cloneNode(true));
        wrapper.appendChild(copyButton);
        pre.parentNode.replaceChild(wrapper, pre);
    });
    
    messageDiv.appendChild(contentDiv);
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// --- دالة تحليل الماركداون ---
function parseMarkdown(text) {
    // الأمان أولاً
    let safeText = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");

    // كتل الكود ```code```
    let formattedText = safeText.replace(/```(\w*)\n([\s\S]*?)```/g, function(match, lang, codeContent) {
        return `<pre><code class="language-${lang}">${codeContent.trim()}</code></pre>`;
    });

    // القواعد الأخرى (عريض, مائل, إلخ)
    formattedText = formattedText.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    formattedText = formattedText.replace(/\*(.*?)\*/g, '<em>$1</em>');
    formattedText = formattedText.replace(/`(.*?)`/g, '<code>$1</code>');

    // تحويل الأسطر الجديدة إلى <br> خارج كتل الكود
    return formattedText.split('\n').map(line => {
        if (line.startsWith('<pre>')) return line;
        return line + '<br>';
    }).join('');
}