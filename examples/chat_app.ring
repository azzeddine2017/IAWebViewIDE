# ===================================================================
# Chat Application Example - Using WebView with Ring and JavaScript
# ===================================================================

load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"

# تهيئة WebView مع الربط بين Ring و JavaScript
oWebView = null
oChatApp = new ChatApp()

class ChatApp


func init 

oWebView = new WebView()
# تهيئة النافذة وربط الدوال
oWebView {
    setTitle("تطبيق المحادثة")
    setSize(800, 600, WEBVIEW_HINT_NONE)
    
    # ربط دالة Ring مع JavaScript
    bind("sendMessage", :sendMessage)
    
    # تعيين محتوى HTML
    setHtml(`
        <!DOCTYPE html>
        <html dir="rtl" lang="ar">
        <head>
            <meta charset="UTF-8">
            <title>تطبيق المحادثة</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background: #f0f2f5;
                }
                .chat-container {
                    max-width: 600px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 10px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    padding: 20px;
                }
                .messages {
                    height: 400px;
                    overflow-y: auto;
                    padding: 10px;
                    border: 1px solid #ddd;
                    border-radius: 5px;
                    margin-bottom: 20px;
                }
                .message {
                    margin: 10px 0;
                    padding: 10px;
                    border-radius: 10px;
                    max-width: 80%;
                }
                .user-message {
                    background: #0084ff;
                    color: white;
                    margin-left: auto;
                }
                .ai-message {
                    background: #f0f0f0;
                    margin-right: auto;
                }
                .input-container {
                    display: flex;
                    gap: 10px;
                }
                input {
                    flex: 1;
                    padding: 10px;
                    border: 1px solid #ddd;
                    border-radius: 5px;
                    font-size: 16px;
                }
                button {
                    padding: 10px 20px;
                    background: #0084ff;
                    color: white;
                    border: none;
                    border-radius: 5px;
                    cursor: pointer;
                }
                button:hover {
                    background: #0073e6;
                }
            </style>
        </head>
        <body>
            <div class="chat-container">
                <div class="messages" id="messages">
                    <div class="message ai-message">
                        مرحباً! كيف يمكنني مساعدتك اليوم؟
                    </div>
                </div>
                <div class="input-container">
                    <input type="text" id="messageInput" placeholder="اكتب رسالتك هنا..." 
                           onkeypress="if(event.key === 'Enter') sendMessageToRing()">
                    <button onclick="sendMessageToRing()">إرسال</button>
                </div>
            </div>

            <script>
                async function sendMessageToRing() {
                    const input = document.getElementById('messageInput');
                    const message = input.value.trim();
                    
                    if (!message) return;
                    
                    // إضافة رسالة المستخدم
                    addMessage(message, 'user-message');
                    input.value = '';
                    
                    try {
                        // استدعاء دالة Ring
                        const response = await window.sendMessage(message);
                        
                        // إضافة رد الذكاء الاصطناعي
                        addMessage(response, 'ai-message');
                    } catch (error) {
                        addMessage('عذراً، حدث خطأ في معالجة الرسالة', 'ai-message');
                    }
                }

                function addMessage(text, className) {
                    const messages = document.getElementById('messages');
                    const div = document.createElement('div');
                    div.className = 'message ' + className;
                    div.textContent = text;
                    messages.appendChild(div);
                    messages.scrollTop = messages.scrollHeight;
                }
            </script>
        </body>
        </html>
    `)
    
    run()
}
# تعريف الدوال التي سيتم ربطها مع JavaScript
func sendMessage(id, req)
    try
        aParams = json2list(req)
        cMessage = aParams[1][1]
        
        # هنا يمكنك معالجة الرسالة (مثلاً إرسالها للذكاء الاصطناعي)
        cResponse = "مرحباً! تلقيت رسالتك: " + cMessage
        ? cResponse
        # إرجاع الرد إلى JavaScript
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"' + cResponse + '"')
        
    catch
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"حدث خطأ في معالجة الرسالة"')
    done
