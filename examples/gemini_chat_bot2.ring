# Gemini Powered Chat Bot v2.4 - Final Backend
# ===================================================================
load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"
load "src/http_client.ring" # تأكد من أن هذا المسار صحيح

# -- المتغيرات العامة --
oWebView = NULL
cSettingsFile = "chat_settings.json"
cHistoryFile = "chat_history.json"
aSettings = []
aConversationHistory = []
cApiKey = "AIzaSyAisNXkhbaKM3qhl-v3hxRsSf17wJDAMbU"  #"YOUR_GEMINI_API_KEY_HERE" # <--- ضع مفتاح API الخاص بك هنا

# ===================================================================
# الدالة الرئيسية
# ===================================================================
func main()
    aSettings = loadSettings()
    aConversationHistory = loadHistory()
    //? list2code(aConversationHistory)
    oWebView = new WebView()
    oWebView {
        setTitle("Gemini Chat Bot")
        setSize(450, 650, WEBVIEW_HINT_NONE)

        bind("getInitialState", :handleGetInitialState)
        bind("sendMessageToAI", :handleSendMessageToAI)
        bind("saveSettings", :handleSaveSettings)
        bind("clearChatHistory", :handleClearChatHistory)

        # تحميل الواجهة من ملف منفصل
        cHtmlPath = "file://" + currentdir() + "/index1.html"
        navigate(cHtmlPath)
        run()
    }

# ===================================================================
# معالجات WebView
# ===================================================================
func handleGetInitialState(id, req)
    oInitialState = [
        :settings = list2map(aSettings),
        :history = aConversationHistory
    ]
    oWebView.wreturn(id, 0, list2json(oInitialState))

func handleSendMessageToAI(id, req)
    try
        aParams = json2list(req)
        cUserMessage = aParams[1][1]
        cLang = aParams[1][2]
        
        addToHistory("user", cUserMessage)
        cBotReply = callGeminiAPI(cUserMessage, cLang, aConversationHistory)
        addToHistory("model", escapeJson(cBotReply))
        
        oWebView.wreturn(id, 0, '"' + escapeJson(cBotReply) + '"')
    catch
        cErrorMsg = "عذرًا، حدث خطأ أثناء الاتصال بالذكاء الاصطناعي: " + cCatchError
        oWebView.wreturn(id, 0, '"' + escapeJson(cErrorMsg) + '"')
    done

func handleSaveSettings(id, req)
    req = json2list(req)[1]
    aSettings[1][2] = req[1]
    aSettings[2][2] = req[2]
    saveSettings()
    oWebView.wreturn(id, 0, '{}')

func handleClearChatHistory(id, req)
    aConversationHistory = []
    saveHistory()
    oWebView.wreturn(id, 0, '"ok"')

# ===================================================================
# منطق الذكاء الاصطناعي
# ===================================================================
func callGeminiAPI(cUserMessage, cLang, aHistory)
    try
        if cApiKey = "YOUR_GEMINI_API_KEY_HERE" or len(cApiKey) < 10
            if cLang = "ar" return "يرجى تعيين مفتاح Gemini API الصحيح في ملف Ring." ok
            return "Please set a valid Gemini API key in the Ring script."
        ok

        cURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + cApiKey
        
        cSystemPrompt = "أنت مساعد ذكي ومفيد. أجب دائمًا باللغة " + iif(cLang="ar", "العربية.", "English.") +
                      " قم بتنسيق إجاباتك باستخدام ماركداون، خاصةً عند عرض الكود."
        
        aRequestContents = [[:role="user", :parts=[[:text=cSystemPrompt]]], [:role="model", :parts=[[:text="حسنًا، فهمت."]]]]
        
        nHistoryStart = max(1, len(aHistory) - 10)
        for i = nHistoryStart to len(aHistory) { aRequestContents + aHistory[i] }
        aRequestContents + [[:role="user", :parts=[[:text=cUserMessage]]]]

        oRequestData = [:contents = aRequestContents]
        cRequestJSON = list2json(oRequestData)
        
        oClient = new HTTPClient()
        oClient.setTimeout(45)
        oClient.setVerifySSL(false)
        aHeaders = ["Content-Type: application/json"]
        
        oResponse = oClient.post(cURL, cRequestJSON, aHeaders)
        ? oResponse
        if oResponse[:success] { return parseGeminiResponse(oResponse[:content]) }
        return "Error: " + oResponse[:status_code] + " - " + oResponse[:error]
        
    catch
        return "Exception in callGeminiAPI: " + cCatchError
    done

func parseGeminiResponse(cResponseJSON)
    try
        oResponse = json2list(cResponseJSON)
        if islist(oResponse) 
            return oResponse[:candidates][1][:content][:parts][1][:text]
        else
            return "Could not parse AI response: " + substr(cResponseJSON, 1, 200)
        ok
    catch
        return "Error parsing JSON response from Gemini."
    done

# ===================================================================
# إدارة الحالة
# ===================================================================
func loadSettings()
    if fexists(cSettingsFile)
        try return json2list(read(cSettingsFile)) catch return createDefaultSettings() end
    ok
    return createDefaultSettings()

func createDefaultSettings()
    return [["theme", "dark"], ["language", "en"]]

func saveSettings()
    write(cSettingsFile, list2json(aSettings))

func loadHistory()
    if fexists(cHistoryFile)
        try
            aLoadedHistory = json2list(read(cHistoryFile))[1]
            if not islist(aLoadedHistory) { raise("Corrupted history") }
            return aLoadedHistory
        catch 
            remove(cHistoryFile)
            return [] 
        done
    ok
    return []

func saveHistory()
    write(cHistoryFile, list2json([aConversationHistory]))

func addToHistory(cRole, cContent)
    aConversationHistory + [[:role = cRole, :parts = [[:text = cContent]]]]
    if len(aConversationHistory) > 50 { del(aConversationHistory, 1) }
    saveHistory()

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
