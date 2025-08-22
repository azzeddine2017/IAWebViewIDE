# ===================================================================
# اختبار اتصال الواجهة
# Test UI Connection
# ===================================================================
load "jsonlib.ring"
load "webview.ring"
load "src/webview_method_wrapper.ring"

func main
    see "=== اختبار اتصال الواجهة ===" + nl + nl
    
    try
        # إنشاء WebView
        oWebView = new WebView()
        
        # إعداد WebView
        oWebView {
            setTitle("اختبار ربط WebView")
            setSize(600, 500, WEBVIEW_HINT_NONE)
            
            # إنشاء معالج اختبار
            oTestHandler = new UITestHandler(oWebView)
            
            # ربط الدوال
            aTestMethods = [
                ["createNewFile", "createNewFile"],
                ["saveFile", "saveFile"],
                ["testConnection", "testConnection"],
                ["runCode", "runCode"],
                ["chatWithAI", "chatWithAI"]
            ]
            
            see "ربط " + len(aTestMethods) + " دوال..." + nl
            bind(oTestHandler, aTestMethods)
            
            for aMethod in aTestMethods
                see "✓ تم ربط: " + aMethod[1] + nl
            next
            
            # تحميل صفحة الاختبار
            cHtmlPath = "file://" + currentdir() + "/test_webview_ui.html"
            see nl + "تحميل صفحة الاختبار: " + cHtmlPath + nl
            navigate(cHtmlPath)
            
            see "بدء التطبيق..." + nl
            run()
        }
        
    catch
        see "خطأ في بدء التطبيق: " + cCatchError + nl
    done

# معالج اختبار الواجهة
class UITestHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
        see "UITestHandler initialized" + nl
    
    func createNewFile id, req
        see "=== createNewFile called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cFileName = aParams[1][1]
            cFileName = substr(cFileName, '"', '\"')
            cResponse = list2json([
                :success= true,
                :message= "تم إنشاء الملف بنجاح: " + cFileName,
                :filename= cFileName
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ تم إرسال رد إنشاء الملف" + nl
            
        catch
            cError = list2json([:error= "خطأ في إنشاء الملف: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ خطأ في إنشاء الملف: " + cCatchError + nl
        done
    
    func saveFile id, req
        see "=== saveFile called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cContent = aParams[2]
            
            cResponse = list2json([
                :success= true,
                :message= "تم حفظ الملف بنجاح: " + cFileName,
                :filename= cFileName,
                :size= len(cContent)
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ تم إرسال رد حفظ الملف" + nl
            
        catch
            cError = list2json([:error= "خطأ في حفظ الملف: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ خطأ في حفظ الملف: " + cCatchError + nl
        done
    
    func testConnection id, req
        see "=== testConnection called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            cResponse = list2json([
                :success= true,
                :message= "الاتصال يعمل بشكل مثالي!",
                :timestamp= date() + " " + time(),
                :version= "Ring WebView Test v1.0"
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ تم إرسال رد اختبار الاتصال" + nl
            
        catch
            cError = list2json([:error= "خطأ في اختبار الاتصال: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ خطأ في اختبار الاتصال: " + cCatchError + nl
        done
    
    func runCode id, req
        see "=== runCode called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cCode = aParams[1]
            cCode = substr(cCode, '"', '\"')
            cResponse = list2json([
                :success= true,
                :message= "تم تشغيل الكود بنجاح",
                :output= "Hello World from Ring!",
                :code= cCode
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ تم إرسال رد تشغيل الكود" + nl
            
        catch
            cError = list2json([:error= "خطأ في تشغيل الكود: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ خطأ في تشغيل الكود: " + cCatchError + nl
        done
    
    func chatWithAI id, req
        see "=== chatWithAI called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cMessage = aParams[1]
             cMessage = substr(cMessage, '"', '\"')
            cResponse = list2json([
                :success= true,
                :message= "مرحباً! أنا مساعد الذكاء الاصطناعي. كيف يمكنني مساعدتك؟",
                :user_message= cMessage,
                :ai_provider= "test"
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ تم إرسال رد الذكاء الاصطناعي" + nl
            
        catch
            cError = list2json([:error= "خطأ في الذكاء الاصطناعي: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ خطأ في الذكاء الاصطناعي: " + cCatchError + nl
        done
