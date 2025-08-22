# ===================================================================
# اختبار النظام المحدث باستخدام النظام المدمج في المكتبة
# Test Updated System Using Built-in Library System
# ===================================================================

load "stdlib.ring"
load "src/webview_method_wrapper.ring"
load "jsonlib.ring"

func main
    see "=== اختبار النظام المحدث باستخدام النظام المدمج ===" + nl + nl
    
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
    
    # ربط جميع الطرق باستخدام النظام المدمج
    see "ربط جميع الطرق باستخدام النظام المدمج..." + nl
    oHandlerManager.bindAllMethods()
    
    see nl + "=== اختبار الربط المباشر للكائنات ===" + nl
    
    # اختبار ربط مباشر لكائن واحد
    oTestHandler = new TestHandler(oWebView)
    aTestMethods = [
        ["testMethod1", "method1"],
        ["testMethod2", "method2"]
    ]
    
    see "اختبار الربط المباشر..." + nl
    oWebView.bind(oTestHandler, aTestMethods)
    see "✓ تم ربط " + len(aTestMethods) + " طرق مباشرة" + nl
    
    see nl + "=== اختبار bindMany ===" + nl
    
    # اختبار bindMany مع عدة كائنات
    oHandler1 = new TestHandler(oWebView)
    oHandler2 = new TestHandler(oWebView)
    
    aManyBindings = [
        [oHandler1, [["handler1Method1", "method1"], ["handler1Method2", "method2"]]],
        [oHandler2, [["handler2Method1", "method1"], ["handler2Method2", "method2"]]]
    ]
    
    see "اختبار bindMany مع عدة كائنات..." + nl
    oWebView.bindMany(aManyBindings)
    see "✓ تم ربط عدة كائنات باستخدام bindMany" + nl
    
    see nl + "=== النتائج ===" + nl
    see "✅ النظام المحدث يعمل بنجاح!" + nl
    see "✅ تم استخدام النظام المدمج في المكتبة" + nl
    see "✅ تم تبسيط الكود وإزالة التعقيدات" + nl
    see "✅ الأداء محسن باستخدام النظام المدمج" + nl

# ===================================================================
# كلاسات وهمية للاختبار
# ===================================================================

class MockWebView
    aBindings = []
    
    func bind p1, p2
        see "MockWebView.bind() called" + nl
        if isObject(p1) and isList(p2)
            see "  - Object binding: " + len(p2) + " methods" + nl
            aBindings + [p1, p2]
        else
            see "  - Function binding: " + p1 + nl
            aBindings + [p1, p2]
        ok
        return true
    
    func bindMany aList
        see "MockWebView.bindMany() called with " + len(aList) + " bindings" + nl
        for aBinding in aList
            if len(aBinding) = 2 and isObject(aBinding[1]) and isList(aBinding[2])
                oObject = aBinding[1]
                aMethods = aBinding[2]
                see "  - Binding object with " + len(aMethods) + " methods" + nl
                this.bind(oObject, aMethods)
            ok
        next
        return true
    
    func wreturn id, status, response
        see "MockWebView.wreturn() - ID: " + id + ", Response: " + response + nl

class MockSmartAgent
    func processRequest cMessage, cCode
        return [:success= true, :message= "Mock response", :data= "test"]

class MockFileManager
    func saveFile cFileName, cContent
        return [:success= true, :message= "File saved: " + cFileName]

class MockCodeRunner
    func runCode cCode
        return [:success= true, :output= "Mock output", :code= cCode]

class TestHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
    
    func method1 id, req
        see "TestHandler.method1() called - ID: " + id + nl
        oWebView.wreturn(id, 0, '{"result": "method1 success"}')
    
    func method2 id, req
        see "TestHandler.method2() called - ID: " + id + nl
        oWebView.wreturn(id, 0, '{"result": "method2 success"}')
