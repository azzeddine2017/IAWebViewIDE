# ===================================================================
# اختبار مبسط لنظام ربط الطرق
# ===================================================================

load "src/webview_method_wrapper.ring"
load "jsonlib.ring"
load "stdlib.ring"
# تشغيل الاختبارات
runSimpleTests()

# ===================================================================
# تشغيل الاختبارات
# ===================================================================
func runSimpleTests()
    see "بدء الاختبارات المبسطة..." + nl + nl
    
    testBasicWrapper()
    testSimpleBinding()
    
    see "=== انتهت جميع الاختبارات المبسطة بنجاح! ===" + nl

# ===================================================================
# اختبار الحل الأساسي فقط
# ===================================================================
func testBasicWrapper()
    see "=== اختبار الحل الأساسي ===" + nl
    
    # إنشاء كائن تجريبي
    oTestObject = new SimpleTestClass
    
    # إنشاء دالة مُغلفة للطريقة
    cWrapperFunc = Method(oTestObject, "testMethod")
    
    # اختبار استدعاء الدالة المُغلفة
    see "استدعاء الدالة المُغلفة..." + nl
    call cWrapperFunc(1, "test request")
    
    see "تم الاختبار الأساسي بنجاح!" + nl + nl

# ===================================================================
# اختبار ربط متعدد مبسط
# ===================================================================
func testSimpleBinding()
    see "=== اختبار الربط المتعدد ===" + nl
    
    # إنشاء كائن تجريبي
    oTestObject = new SimpleTestClass
    
    # تعريف قائمة الطرق
    aMethodsList = [
        ["testMethod", "testMethod"],
        ["anotherMethod", "anotherMethod"]
    ]
    
    # محاكاة WebView بسيطة
    oMockWebView = new SimpleWebView
    
    # ربط الطرق
    aBindList = BindObjectMethods(oMockWebView, oTestObject, aMethodsList)
    
    see "تم ربط " + len(aBindList) + " طريقة بنجاح!" + nl
    for aBinding in aBindList
        see "  - " + aBinding[1] + nl
    next
    
    see "تم اختبار الربط المتعدد بنجاح!" + nl + nl

# ===================================================================
# كلاس تجريبي بسيط
# ===================================================================
class SimpleTestClass
    
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
# كلاس WebView بسيط للاختبار
# ===================================================================
class SimpleWebView
    
    func bindMany aBindList
        see "SimpleWebView: ربط " + len(aBindList) + " دالة" + nl
        for aBinding in aBindList
            see "  - ربط: " + aBinding[1] + nl
        next
    
    func bind cName, cFunc
        see "SimpleWebView: ربط دالة واحدة: " + cName + nl

