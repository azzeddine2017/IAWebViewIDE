# ===================================================================
# اختبار بسيط للذكاء الاصطناعي مع WebView
# ===================================================================

load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"
load "http_client.ring"

# تهيئة WebView
oWebView = null

func main
    oWebView = new WebView()
    
    # تهيئة النافذة وربط الدوال
    oWebView {
        setTitle("اختبار الذكاء الاصطناعي")
        setSize(500, 700, WEBVIEW_HINT_NONE)
        
        # ربط دالة Ring مع JavaScript
        bind("sendAIMessage", :sendAIMessage)
        bind("testConnection", :testConnection)
        
         # تحميل صفحة الاختبار
            cHtmlPath = "file://" + currentdir() + "/index.html"
        
            navigate(cHtmlPath)
            
       
        run()
    }

# دالة اختبار الاتصال
func testConnection(id, req)
    try
        see "=== Test Connection Called ===" + nl
        
        # اختبار بسيط
        cResult = "الاتصال يعمل بشكل صحيح! ✅"
        
        # إرجاع النتيجة
        oWebView.wreturn(id, 0, '"' + cResult + '"')
        see "Test connection response sent" + nl
        
    catch
        see "Error in testConnection: " + cCatchError + nl
        oWebView.wreturn(id, 0, '"خطأ في اختبار الاتصال"')
    done

# دالة إرسال رسالة للذكاء الاصطناعي
func sendAIMessage(id, req)
    try
        see "=== AI Message Called ===" + nl
        see "Request: " + req + nl
        
        aParams = json2list(req)
        cMessage = aParams[1][1]
        see "User message: " + cMessage + nl
        
        # محاولة الاتصال بالذكاء الاصطناعي
        cResponse = callGeminiAPI(cMessage)
        //see "AI response: " + cResponse + nl
        
        # تهيئة الرد ليكون صالحًا كـ JSON
        cEscapedResponse = escapeJson(cResponse)
        see "Escaped AI response: " + cEscapedResponse + nl
        # إرجاع الرد بعد تهيئته
        oWebView.wreturn(id, 0, '"' + cEscapedResponse + '"')
        see "AI response sent successfully" + nl
        
    catch
        see "Error in sendAIMessage: " + cCatchError + nl
        oWebView.wreturn(id, 0, '"عذراً، حدث خطأ في معالجة الرسالة"')
    done

# دالة الاتصال بـ Gemini API
func callGeminiAPI(cMessage)
    try
        see "Calling Gemini API..." + nl
        
        # إعداد البيانات
        cAPIKey = "AIzaSyAisNXkhbaKM3qhl-v3hxRsSf17wJDAMbU"  # استخدم مفتاحك الصحيح
        cURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + cAPIKey
        
        # إعداد البيانات للإرسال
        oRequestData = [
                :contents = [
                    [
                        :parts = [
                            [
                                :text = cMessage
                            ]
                        ]
                    ]
                ]
        ]
        
        cRequestJSON = list2json(oRequestData)
        see "Request JSON: " + cRequestJSON + nl
        
        # إنشاء عميل HTTP
        oClient = new HTTPClient()
        oClient.setTimeout(30)
        oClient.setVerifySSL(false)
        
        # إعداد الرؤوس
        aHeaders = [
            "Content-Type: application/json"
        ]
        
        # إرسال الطلب
        oResponse = oClient.post(cURL, cRequestJSON, aHeaders)
        oClient.cleanup()
        
        see "HTTP Response status: " + oResponse[:status_code] + nl
        see "HTTP Response success: " + oResponse[:success] + nl
        
        if oResponse[:success]
            see "Response content: " + oResponse[:content]//substr(oResponse[:content], 1, 200) + "..." + nl
            return parseGeminiResponse(oResponse[:content])
        else
            see "HTTP Error: " + oResponse[:error] + nl
            return "عذراً، فشل في الاتصال بخدمة الذكاء الاصطناعي"
        ok
        
    catch
        see "Error in callGeminiAPI: " + cCatchError + nl
        return "عذراً، حدث خطأ في الاتصال: " + cCatchError
    done

# تحليل استجابة Gemini
func parseGeminiResponse(cResponse)
    try
        oResponse = json2list(cResponse)

        if type(oResponse) = "LIST" and len(oResponse) > 0
            cText = oResponse[:candidates][1][:content][:parts][1][:text]
            ? cText
            return cText
        ok
        
        return "تم استلام رد من الذكاء الاصطناعي لكن لا يمكن تحليله"
        
    catch
        see "Error parsing Gemini response: " + cCatchError + nl
        return "خطأ في تحليل رد الذكاء الاصطناعي"
    done

func escapeJson str
    if str = NULL { return "" }
    escaped = ""
    for i = 1 to len(str) {
        char = str[i]
        c_ascii = ascii(char)

        if char = '"' {
            escaped += '\"'
        elseif char = "\"   // تمت إضافة معالجة الشرطة المائلة العكسية
            escaped += '\\'
        elseif char = '/' 
            escaped += '\/'
        elseif c_ascii = 8 
            escaped += '\b'
        elseif c_ascii = 12 
            escaped += '\f'
        elseif c_ascii = 10 
            escaped += '\n'
        elseif c_ascii = 13 
            escaped += '\r'
        elseif c_ascii = 9 
            escaped += '\t'
        elseif c_ascii < 32 
            escaped += '\u' + right('0000' + hex(c_ascii), 4)
        else 
            // هذا هو الجزء الأهم الذي كان لا يعمل
            escaped += char
        }
    }
    return escaped