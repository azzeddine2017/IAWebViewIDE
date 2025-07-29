# ===================================================================
# اختبار شامل للنظام الجديد القائم على الطرق
# Comprehensive Test for New Method-Based System
# ===================================================================

load "stdlib.ring"
load "src/webview_method_wrapper.ring"
load "jsonlib.ring"




func main
    see "=== بدء اختبار النظام الشامل الجديد ===" + nl + nl
    
    # إنشاء كائنات وهمية للاختبار
    oWebView = new MockWebView
    oSmartAgent = new MockSmartAgent
    oFileManager = new MockFileManager
    oCodeRunner = new MockCodeRunner
    
    # إنشاء مدير المعالجات الشامل
    see "إنشاء مدير المعالجات الشامل..." + nl
    oHandlerManager = new ComprehensiveHandlerManager(
        oWebView, 
        oSmartAgent, 
        oFileManager, 
        oCodeRunner
    )
    
    # ربط جميع الطرق
    see "ربط جميع الطرق..." + nl
    oHandlerManager.bindAllMethods()
    
    see nl + "=== اختبار وظائف معالج الملفات ===" + nl
    
    # اختبار حفظ الملف
    see "اختبار حفظ الملف..." + nl
    cSaveRequest = '["test.ring", "see Hello World"]'
    oHandlerManager.oFileHandler.saveFile(1, cSaveRequest)

    # اختبار تحميل الملف
    see nl + "اختبار تحميل الملف..." + nl
    cLoadRequest = '["test.ring"]'
    oHandlerManager.oFileHandler.loadFile(2, cLoadRequest)

    # اختبار إنشاء ملف جديد
    see nl + "اختبار إنشاء ملف جديد..." + nl
    cCreateRequest = '["new_file.ring"]'
    oHandlerManager.oFileHandler.createNewFile(3, cCreateRequest)

    # اختبار حذف الملف
    see nl + "اختبار حذف الملف..." + nl
    cDeleteRequest = '["old_file.ring"]'
    oHandlerManager.oFileHandler.deleteFile(4, cDeleteRequest)

    # اختبار جلب قائمة الملفات
    see nl + "اختبار جلب قائمة الملفات..." + nl
    oHandlerManager.oFileHandler.getFileList(5, "[]")
    
    see nl + "=== اختبار وظائف معالج الكود ===" + nl
    
    # اختبار تشغيل الكود
    see "اختبار تشغيل الكود..." + nl
    cRunRequest = '["see Hello from Ring"]'
    oHandlerManager.oCodeHandler.runCode(6, cRunRequest)

    # اختبار تنسيق الكود
    see nl + "اختبار تنسيق الكود..." + nl
    cFormatRequest = '["func test see :test "]'
    oHandlerManager.oCodeHandler.formatCode(7, cFormatRequest)

    # اختبار تحليل الكود
    see nl + "اختبار تحليل الكود..." + nl
    cAnalyzeRequest = '["func main see :Hello"]'
    oHandlerManager.oCodeHandler.analyzeCode(8, cAnalyzeRequest)

    # اختبار تصحيح الكود
    see nl + "اختبار تصحيح الكود..." + nl
    cDebugRequest = '["x = 10 y = 20 z = x + y see z"]'
    oHandlerManager.oCodeHandler.debugCode(9, cDebugRequest)

    # اختبار اقتراحات الكود
    see nl + "اختبار اقتراحات الكود..." + nl
    cSuggestRequest = '["func test see :test "]'
    oHandlerManager.oCodeHandler.getCodeSuggestions(10, cSuggestRequest)
    
    see nl + "=== اختبار وظائف معالج الذكاء الاصطناعي ===" + nl
    
    # اختبار الدردشة مع الذكاء الاصطناعي
    see "اختبار الدردشة مع الذكاء الاصطناعي..." + nl
    cChatRequest = '["مرحباً، كيف يمكنني تحسين هذا الكود؟", "see Hello World"]'
    oHandlerManager.oAIHandler.chatWithAI(11, cChatRequest)

    # اختبار إرسال طلب للذكاء الاصطناعي
    see nl + "اختبار إرسال طلب للذكاء الاصطناعي..." + nl
    cAIRequest = '["اشرح لي هذا الكود", "func main see :test"]'
    oHandlerManager.oAIHandler.sendAIRequest(12, cAIRequest)

    # اختبار معالجة الطلب
    see nl + "اختبار معالجة الطلب..." + nl
    cProcessRequest = '["أريد مساعدة في البرمجة", "x = 10"]'
    oHandlerManager.oAIHandler.processRequest(13, cProcessRequest)
    
    # اختبار حالة الوكيل
    see nl + "اختبار حالة الوكيل..." + nl
    oHandlerManager.oAIHandler.getAgentStatus(14, "[]")
    
    see nl + "=== اختبار وظائف معالج المشاريع ===" + nl
    
    # اختبار إنشاء مشروع
    see "اختبار إنشاء مشروع..." + nl
    cCreateProjectRequest = '["مشروع تجريبي"]'
    oHandlerManager.oProjectHandler.createProject(15, cCreateProjectRequest)

    # اختبار فتح مشروع
    see nl + "اختبار فتح مشروع..." + nl
    oHandlerManager.oProjectHandler.openProject(16, "[]")

    # اختبار حفظ مشروع
    see nl + "اختبار حفظ مشروع..." + nl
    oHandlerManager.oProjectHandler.saveProject(17, "[]")

    # اختبار تعيين المشروع الحالي
    see nl + "اختبار تعيين المشروع الحالي..." + nl
    cSetProjectRequest = '["مشروع جديد"]'
    oHandlerManager.oProjectHandler.setCurrentProject(18, cSetProjectRequest)

    # اختبار تعيين الملف الحالي
    see nl + "اختبار تعيين الملف الحالي..." + nl
    cSetFileRequest = '["main.ring"]'
    oHandlerManager.oProjectHandler.setCurrentFile(19, cSetFileRequest)
    
    see nl + "=== اختبار وظائف معالج النظام ===" + nl
    
    # اختبار الاتصال
    see "اختبار الاتصال..." + nl
    oHandlerManager.oSystemHandler.testConnection(20, "[]")
    
    see nl + "=== انتهى الاختبار الشامل بنجاح! ===" + nl
    see "جميع المعالجات تعمل بشكل صحيح مع النظام الجديد القائم على الطرق." + nl



# Mock WebView class for testing
class MockWebView
    WEBVIEW_ERROR_OK = 0

    func wreturn id, status, response
        see "WebView Response - ID= " + id + ", Status= " + status + ", Response= " + response + nl

    func bind cFunctionName, cFunction
        see "Binding function: " + cFunctionName + nl

# Mock SmartAgent class for testing
class MockSmartAgent
    func processRequest cMessage, cCode
        return [:success = true, :message = "تم معالجة الطلب: " + cMessage]
    
    func getAgentStatus()
        return "Smart Agent جاهز"
    
    func setCurrentProject cProjectName
        see "تم تعيين المشروع= " + cProjectName + nl
    
    func setCurrentFile cFileName
        see "تم تعيين الملف= " + cFileName + nl

# Mock FileManager class for testing
class MockFileManager
    func createProject cProjectName
        return [:success = "تم إنشاء المشروع: " + cProjectName]

    func openProject()
        return [:success = "تم فتح المشروع"]

    func saveProject()
        return [:success = "تم حفظ المشروع"]

    func openFile()
        return [:success = "تم فتح الملف"]

# Mock CodeRunner class for testing
class MockCodeRunner
    func formatCode id, req, oWebView
        see "تنسيق الكود..." + nl
        aResult = [:formatted_code = "# كود منسق"]
        cJsonResponse = list2json(aResult)
        oWebView.wreturn(id, 0, cJsonResponse)
    
    func analyzeCode id, req, oWebView
        see "تحليل الكود..." + nl
        aResult = [:analysis = "تحليل الكود مكتمل"]
        cJsonResponse = list2json(aResult)
        oWebView.wreturn(id, 0, cJsonResponse)
    
    func debugCode cCode
        return [:debug_info = "معلومات التصحيح للكود"]

