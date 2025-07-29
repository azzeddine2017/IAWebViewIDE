# اختبار أساسي للنظام الجديد
load "stdlib.ring"
load "src/webview_method_wrapper.ring"


func main
    see "=== اختبار أساسي للنظام الجديد ===" + nl
    
    # إنشاء WebView وهمي
    oWebView = new MockWebView
    
    # إنشاء معالج الاختبار
    oHandler = new TestHandler(oWebView)
    
    # إنشاء دالة مُغلفة للطريقة
    see "إنشاء دالة مُغلفة..." + nl
    cWrapperFunc = Method(oHandler, "testMethod")
    
    # ربط الدالة مع WebView
    see "ربط الدالة مع WebView..." + nl
    oWebView.bind("testFunction", cWrapperFunc)
    
    # اختبار استدعاء الدالة
    see "اختبار استدعاء الدالة..." + nl
    call cWrapperFunc(1, "test request")
    
    see "=== انتهى الاختبار بنجاح! ===" + nl


# فئة WebView وهمية للاختبار
class MockWebView
    WEBVIEW_ERROR_OK = 0
    
    func wreturn id, status, response
        see "WebView Response: " + response + nl
    
    func bind cFunctionName, cFunction
        see "Bound: " + cFunctionName + nl

# فئة بسيطة للاختبار
class TestHandler
    oWebView
    func init oWebViewRef
        oWebView = oWebViewRef
    
    func testMethod id, req
        see "Test method called with ID: " + id + " and request: " + req + nl
        oWebView.wreturn(id, 0, "Success!")
