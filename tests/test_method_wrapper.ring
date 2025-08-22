# ===================================================================
# اختبار نظام ربط الطرق مع RingWebView
# ===================================================================

load "src/webview_method_wrapper.ring"
load "jsonlib.ring"
load "stdlib.ring"

# تعريف ثوابت WebView للاختبار
WEBVIEW_ERROR_OK = 0

# تشغيل الاختبارات
runAllTests()

# ===================================================================
# تشغيل جميع الاختبارات
# ===================================================================
func runAllTests()
    see "بدء اختبارات نظام ربط الطرق..." + nl + nl
    
    testBasicMethodWrapper()
    testMultipleMethodBinding()
    testFileHandler()
    
    see "=== انتهت جميع الاختبارات بنجاح! ===" + nl


# ===================================================================
# اختبار الحل الأساسي
# ===================================================================
func testBasicMethodWrapper()
    see "=== اختبار الحل الأساسي للطرق ===" + nl
    
    # إنشاء كائن تجريبي
    oTestObject = new TestClass
    
    # إنشاء دالة مُغلفة للطريقة
    cWrapperFunc = Method(oTestObject, "testMethod")
    
    # اختبار استدعاء الدالة المُغلفة
    see "استدعاء الدالة المُغلفة..." + nl
    call cWrapperFunc(1, "test request")
    
    see "تم الاختبار الأساسي بنجاح!" + nl + nl

# ===================================================================
# اختبار ربط متعدد الطرق
# ===================================================================
func testMultipleMethodBinding()
    see "=== اختبار ربط متعدد الطرق ===" + nl
    
    # إنشاء كائن تجريبي
    oTestObject = new TestClass
    
    # تعريف قائمة الطرق
    aMethodsList = [
        ["testMethod", "testMethod"],
        ["anotherMethod", "anotherMethod"]
    ]
    
    # محاكاة WebView (بدون إنشاء فعلي)
    oMockWebView = new MockWebView
    
    # ربط الطرق
    aBindList = BindObjectMethods(oMockWebView, oTestObject, aMethodsList)
    
    see "تم ربط " + len(aBindList) + " طريقة بنجاح!" + nl
    for aBinding in aBindList
        see "  - " + aBinding[1] + nl
    next
    
    see "تم اختبار الربط المتعدد بنجاح!" + nl + nl

# ===================================================================
# اختبار معالج الملفات
# ===================================================================
func testFileHandler()
    see "=== اختبار معالج الملفات ===" + nl
    
    # إنشاء WebView وهمي
    oMockWebView = new MockWebView
    
    # إنشاء معالج الملفات
    oFileHandler = new FileHandler(oMockWebView)
    
    # اختبار حفظ الملف
    cSaveRequest = list2json(["test.ring", "see 'Hello World!'"])
    oFileHandler.saveFile(1, cSaveRequest)
    
    # اختبار تحميل الملف
    cLoadRequest = list2json(["test.ring"])
    oFileHandler.loadFile(2, cLoadRequest)
    
    # اختبار تشغيل الكود
    cRunRequest = list2json(["see 'Hello from Ring!'"])
    oFileHandler.runCode(3, cRunRequest)
    
    see "تم اختبار معالج الملفات بنجاح!" + nl + nl

# ===================================================================
# كلاس تجريبي للاختبار
# ===================================================================
class TestClass
    
    func testMethod id, req
        see "تم استدعاء testMethod!" + nl
        see "ID: " + id + nl
        see "Request: " + req + nl
        return "نجح الاختبار!"
    
    func anotherMethod id, req
        see "تم استدعاء anotherMethod!" + nl
        see "ID: " + id + nl
        see "Request: " + req + nl
        return "نجح اختبار آخر!"

# ===================================================================
# كلاس WebView وهمي للاختبار
# ===================================================================
class MockWebView
    
    func bindMany aBindList
        see "MockWebView: ربط " + len(aBindList) + " دالة" + nl
        for aBinding in aBindList
            see "  - ربط: " + aBinding[1] + nl
        next
    
    func bind cName, cFunc
        see "MockWebView: ربط دالة واحدة: " + cName + nl
    
    func wreturn id, status, response
        see "MockWebView: إرجاع استجابة" + nl
        see "  ID: " + id + nl
        see "  Status: " + status + nl
        see "  Response: " + response + nl

