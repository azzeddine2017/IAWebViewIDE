# ===================================================================
# Gemini Powered Chat Bot Application using Ring and WebView
# ===================================================================

load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"
load "src/http_client.ring" # تأكد من أن هذا المسار صحيح

# -- المتغيرات العامة --
oWebView = NULL
cSettingsFile = "chat_settings.json"
aSettings = []
aConversationHistory = [] # ذاكرة المحادثة
cApiKey = "AIzaSyAisNXkhbaKM3qhl-v3hxRsSf17wJDAMbU"  #"YOUR_GEMINI_API_KEY_HERE" # <--- ضع مفتاح API الخاص بك هنا

# ===================================================================
# الدالة الرئيسية - Main Function
# ===================================================================
func main()
    aSettings = loadSettings()
    cList ="aConversationHistory =" + loadHistory()
//? "cList: " + cList
    eval(cList) # تحميل سجل المحادثة عند بدء التشغيل
    //see "aConversationHistory:" ?  aConversationHistory
    oWebView = new WebView()
    oWebView {
        setTitle("Gemini Chat Bot")
        setSize(450, 650, WEBVIEW_HINT_NONE)

        # ربط الدوال الجديدة والمحسنة
        bind("getInitialState", :GetInitialState) # اسم جديد وأكثر وضوحًا
        bind("sendMessageToAI", :handleSendMessageToAI) # اسم جديد للتعامل مع الذكاء الاصطناعي
        bind("saveSettings", :handleSaveSettings)

        setHtml(getChatHTML())
        run()
    }
    
# ===================================================================
# معالجات WebView (الربط مع JavaScript)
# ===================================================================
# يرسل الإعدادات وسجل المحادثة عند تحميل الواجهة
func GetInitialState(id, req)
    oInitialState = [
        :settings = list2map(aSettings),
        :history = aConversationHistory
    ]
    oWebView.wreturn(id, 0, list2json(oInitialState))
? list2json(oInitialState)
# يستقبل الرسائل من الواجهة، يتصل بـ Gemini، ويرسل الرد
func handleSendMessageToAI(id, req)
    try
        aParams = json2list(req)[1]
        cUserMessage = aParams[1]
        cLang = aParams[2]
        
        # إضافة رسالة المستخدم إلى سجل المحادثة
        addToHistory(:user, cUserMessage)

        # استدعاء Gemini API
        cBotReply = callGeminiAPI(cUserMessage, cLang)
        
        # إضافة رد الذكاء الاصطناعي إلى سجل المحادثة
        addToHistory(:model, escapeJson(cBotReply))
        
        # إرجاع الرد إلى JavaScript
        oWebView.wreturn(id, 0, '"' + escapeJson(cBotReply) + '"')
    catch
        cErrorMsg = "عذرًا، حدث خطأ أثناء الاتصال بالذكاء الاصطناعي."
        oWebView.wreturn(id, 0, '"' + escapeJson(cErrorMsg) + '"')
    done

# يحفظ الإعدادات
func handleSaveSettings(id, req)
    aReq = json2list(req)[1]
    cTheme = aReq[1]
    cLang = aReq[2]
    
    aSettings[1][2] = cTheme
    aSettings[2][2] = cLang
    
    saveSettings()
    oWebView.wreturn(id, 0, '{}')

# ===================================================================
# منطق الذكاء الاصطناعي (الاتصال بـ Gemini)
# ===================================================================
func callGeminiAPI(cUserMessage, cLang)
    try
        if cApiKey = "YOUR_GEMINI_API_KEY_HERE"
            return "Please set your Gemini API key in the Ring script."
        ok

        cURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + cApiKey
        
        # إضافة التعليمات الأولية (System Prompt)
        cSystemPrompt = "أنت مساعد ذكي ومفيد. أجب دائمًا باللغة " + iif(cLang="ar", "العربية.", "English.")
        
        # بناء جسم الطلب مع سجل المحادثة
        aRequestContents = [[:role="user", :parts=[[:text=cSystemPrompt]]], [:role="model", :parts=[[:text="حسنًا، فهمت."]]]]
        
        // إضافة آخر 10 رسائل من السجل
        nHistoryStart = max(1, len(aConversationHistory) - 10)
        for i = nHistoryStart to len(aConversationHistory)
            aRequestContents + aConversationHistory[i]
        next
        aRequestContents + [:role="user",:parts=[[:text=cUserMessage]]]
        //? aRequestContents
        oRequestData = [:contents = aRequestContents]
        cRequestJSON = list2json(oRequestData)
       // ? "cRequestJSON: " + cRequestJSON
        oClient = new HTTPClient()
        oClient.setTimeout(45)
        oClient.setVerifySSL(false)
        aHeaders = ["Content-Type: application/json"]
        
        oResponse = oClient.post(cURL, cRequestJSON, aHeaders)
       
        if oResponse[:success]
            return parseGeminiResponse(oResponse[:content])
        else
            return "Error: " + oResponse[:status_code] + " - " + oResponse[:error]
        ok
        
    catch
        return "Exception in callGeminiAPI: " + cCatchError
    done

func parseGeminiResponse(cResponseJSON)
    try
        oResponse = json2list(cResponseJSON)
        if islist(oResponse) and oResponse[:candidates] != NULL
            return oResponse[:candidates][1][:content][:parts][1][:text]
        else
			if islist(oResponse) and oResponse[:error] != NULL
				return "Error from API: " + oResponse[:error][:message]
			ok
            return "Could not parse AI response."
        ok
    catch
        return "Error parsing JSON: " + cCatchError
    done

# ===================================================================
# إدارة الحالة (الإعدادات وسجل المحادثة)
# ===================================================================
func loadSettings()
    if fexists(cSettingsFile) { return json2list(read(cSettingsFile)) }
    return [[:theme, "dark"], [:language, "en"]]

func saveSettings()
    write(cSettingsFile, list2json(aSettings))

func loadHistory()
    cHistoryFile = "chat_history.ring"
    if fexists(cHistoryFile) { 
		try
			return read(cHistoryFile)
		catch
			return "[]"
		done
	}
    return "[]"

func saveHistory()
    write("chat_history.ring", list2code(aConversationHistory))

func addToHistory(cRole, cContent)
    aConversationHistory + [:role = cRole, :parts = [[:text = cContent]]]
    // إبقاء السجل بحجم معقول
    if len(aConversationHistory) > 50 { del(aConversationHistory, 1) }
    saveHistory() // حفظ السجل بعد كل رسالة

# ===================================================================
# الدوال المساعدة
# ===================================================================
func escapeJson(str)
    if str = NULL { return "" }
    escaped = ""
    for i = 1 to len(str) {
        char = str[i]
        if char = '"' { escaped += '\"' 
        elseif char = "\"  escaped += '\\' 
        elseif char = '/'  escaped += '\/' 
        elseif ascii(char) = 8  escaped += '\b' 
        elseif ascii(char) = 12  escaped += '\f' 
        elseif ascii(char) = 10  escaped += '\n' 
        elseif ascii(char) = 13  escaped += '\r' 
        elseif ascii(char) = 9  escaped += '\t' 
        else  escaped += char }
    }
    return escaped

func list2map(aList)
    oMap = []
    for item in aList { oMap[item[1]] = item[2] }
    return oMap

func iif(bCondition, vTrue, vFalse)
    if bCondition { return vTrue }
    return vFalse

# ===================================================================
# واجهة HTML (مع تعديلات طفيفة في JavaScript)
# ===================================================================
func getChatHTML()
    return `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Ring Gemini Bot</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            /* نفس كود CSS بدون تغيير */
            @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&family=Tajawal:wght@400;500;700&display=swap');
            :root {
                --bg-color: #e5ddd5; --bg-image: url('https://i.pinimg.com/originals/97/c0/0e/97c00e6242483875335e21b8141663f5.jpg');
                --card-bg-color: rgba(240, 242, 245, 0.9); --header-bg-color: #f0f2f5; --footer-bg-color: #f0f2f5;
                --border-color: rgba(0, 0, 0, 0.1); --user-bubble-bg: linear-gradient(135deg, #dcf8c6, #c5eab3);
                --bot-bubble-bg: #ffffff; --text-primary: #111b21; --text-secondary: #667781;
                --accent-green: #008069; --icon-color: #54656f;
            }
            html[data-theme="dark"] {
                --bg-color: #0c141a; --bg-image: none; --card-bg-color: rgba(17, 27, 33, 0.8);
                --header-bg-color: #202c33; --footer-bg-color: #111b21; --border-color: rgba(255, 255, 255, 0.15);
                --user-bubble-bg: linear-gradient(135deg, #005c4b, #008069); --bot-bubble-bg: #202c33;
                --text-primary: #e9edef; --text-secondary: #8696a0; --accent-green: #00a884; --icon-color: #aebac1;
            }
            body { font-family: 'Inter', sans-serif; margin: 0; height: 100vh; overflow: hidden; background-color: var(--bg-color);
                   background-image: var(--bg-image); background-size: cover; background-position: center; display: flex;
                   align-items: center; justify-content: center; padding: 1em; box-sizing: border-box; transition: background-color 0.5s ease; }
            html[lang="ar"] body { font-family: 'Tajawal', sans-serif; }
            .chat-window { width: 100%; height: 100%; max-width: 450px; max-height: 95vh; display: flex; flex-direction: column;
                           background-color: var(--card-bg-color); border-radius: 16px; border: 1px solid var(--border-color);
                           backdrop-filter: blur(25px); -webkit-backdrop-filter: blur(25px); box-shadow: 0 15px 35px rgba(0,0,0,0.3);
                           animation: fadeIn 0.5s ease-out; overflow: hidden; }
            @keyframes fadeIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }
            .chat-header { display: flex; justify-content: space-between; align-items: center; padding: 10px 15px;
                           background-color: var(--header-bg-color); flex-shrink: 0; }
            .header-title { display: flex; align-items: center; gap: 1em; }
            .header-title i { font-size: 1.5em; color: var(--accent-green); }
            .header-title h2 { margin: 0; font-size: 1.1em; font-weight: 500; color: var(--text-primary); }
            .header-controls { display: flex; gap: 1em; }
            .control-btn { background: none; border: none; font-size: 1.2em; cursor: pointer; color: var(--icon-color); }
            #chat-log { flex-grow: 1; padding: 10px 15px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
            .message { max-width: 75%; padding: 10px 15px; border-radius: 12px; line-height: 1.5; color: var(--text-primary);
                       animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); word-wrap: break-word; }
            @keyframes popIn { from { opacity: 0; transform: translateY(10px) scale(0.9); } to { opacity: 1; transform: translateY(0) scale(1); } }
            .user { background: var(--user-bubble-bg); align-self: flex-end; border-bottom-right-radius: 3px; }
            html[dir="rtl"] .user { align-self: flex-start; border-bottom-right-radius: 12px; border-bottom-left-radius: 3px; }
            .bot { background: var(--bot-bubble-bg); align-self: flex-start; border-bottom-left-radius: 3px; }
            html[dir="rtl"] .bot { align-self: flex-end; border-bottom-left-radius: 12px; border-bottom-right-radius: 3px; }
            .typing-indicator { align-self: flex-start; color: var(--text-secondary); font-style: italic; }
            html[dir="rtl"] .typing-indicator { align-self: flex-end; }
            #input-bar { display: flex; padding: 12px; background: var(--footer-bg-color); flex-shrink: 0; align-items: center; }
            #msg-input { flex-grow: 1; background: var(--bot-bubble-bg); border: 1px solid var(--border-color);
                         border-radius: 22px; padding: 12px 18px; font-size: 15px; color: var(--text-primary);
                         outline: none; transition: border-color 0.2s; }
            #msg-input:focus { border-color: var(--accent-green); }
            #send-btn { background: var(--accent-green); color: white; border: none; border-radius: 50%; width: 45px;
                        height: 45px; margin: 0 12px; cursor: pointer; font-size: 18px; display: flex;
                        align-items: center; justify-content: center; transition: transform 0.2s, background-color 0.2s; }
            html[dir="ltr"] #send-btn { order: 2; }
            #send-btn:hover { transform: scale(1.1); background-color: #008a6e; }
        </style>
    </head>
    <body>
        <div class="chat-window">
            <div class="chat-header">
                <div class="header-title"><i class="fa-solid fa-robot"></i><h2 id="ui-title"></h2></div>
                <div class="header-controls">
                    <button id="theme-toggle" class="control-btn"></button>
                    <button id="lang-toggle" class="control-btn"></button>
                </div>
            </div>
            <div id="chat-log"></div>
            <div id="input-bar">
                <input type="text" id="msg-input"><button id="send-btn"><i class="fa-solid fa-paper-plane"></i></button>
            </div>
        </div>

        <script>
            // === JavaScript مُحدّث للتعامل مع الحالة الجديدة ===
            let currentTheme, currentLang;
            const uiStrings = {
                en: { title: "Gemini Bot", placeholder: "Ask Gemini anything...", typing: "Gemini is thinking..." },
                ar: { title: "بوت Gemini", placeholder: "اسأل Gemini أي شيء...", typing: "Gemini يفكر الآن..." }
            };

            function setTheme(theme) {
                currentTheme = theme;
                document.documentElement.setAttribute('data-theme', theme);
                document.getElementById('theme-toggle').innerHTML = theme === 'dark' ? '<i class="fa-solid fa-sun"></i>' : '<i class="fa-solid fa-moon"></i>';
            }

            function setLanguage(lang) {
                currentLang = lang;
                const strings = uiStrings[lang];
                document.documentElement.lang = lang;
                document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
                document.getElementById('ui-title').textContent = strings.title;
                document.getElementById('msg-input').placeholder = strings.placeholder;
                document.getElementById('lang-toggle').textContent = lang === 'en' ? 'AR' : 'EN';
            }

            function addMessage(text, sender) {
                const log = document.getElementById('chat-log');
                const msgDiv = document.createElement('div');
                const safeText = text.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\\n/g, '<br>');
                msgDiv.className = 'message ' + sender;
                msgDiv.innerHTML = safeText;
                log.appendChild(msgDiv);
                log.scrollTop = log.scrollHeight;
            }

            function setTyping(isTyping) {
                let indicator = document.getElementById('typing-indicator');
                if (isTyping) {
                    if (!indicator) {
                        indicator = document.createElement('div');
                        indicator.id = 'typing-indicator';
                        indicator.className = 'message bot typing-indicator';
                        indicator.innerHTML = '<i>' + uiStrings[currentLang].typing + '</i>';
                        document.getElementById('chat-log').appendChild(indicator);
                        document.getElementById('chat-log').scrollTop = document.getElementById('chat-log').scrollHeight;
                    }
                } else { if (indicator) indicator.remove(); }
            }

            async function sendMessage() {
                const input = document.getElementById('msg-input');
                const text = input.value.trim();
                if (text) {
                    addMessage(text, 'user');
                    input.value = '';
                    setTyping(true);
                    // استدعاء الدالة الجديدة
                    const botReply = await window.sendMessageToAI(text, currentLang);
                    setTyping(false);
                    addMessage(botReply, 'bot');
                }
            }
            
            // --- دالة تحميل الحالة الأولية ---
            window.onload = async () => {
                // استدعاء الدالة الجديدة للحصول على الإعدادات والسجل
                const initialState = await window.getInitialState();
                
                setTheme(initialState.settings.theme);
                setLanguage(initialState.settings.language);

                // تحميل سجل المحادثة وعرضه
                const log = document.getElementById('chat-log');
                log.innerHTML = ''; // مسح أي رسائل افتراضية
                initialState.history.forEach(item => {
                    const sender = item.role === 'user' ? 'user' : 'bot';
                    addMessage(item.parts[0].text, sender);
                });

                document.getElementById('theme-toggle').addEventListener('click', () => {
                    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
                    setTheme(newTheme);
                    window.saveSettings(newTheme, currentLang);
                });
                document.getElementById('lang-toggle').addEventListener('click', () => {
                    const newLang = currentLang === 'en' ? 'ar' : 'en';
                    setLanguage(newLang);
                    // إعادة تحميل السجل باللغة الجديدة (اختياري، أو يمكن بدء محادثة جديدة)
                    log.innerHTML = '';
                    window.saveSettings(currentTheme, newLang);
                });
                document.getElementById('send-btn').addEventListener('click', sendMessage);
                document.getElementById('msg-input').addEventListener('keypress', (e) => {
                    if (e.key === 'Enter') sendMessage();
                });
            };
        </script>
    </body>
    </html>
    `
