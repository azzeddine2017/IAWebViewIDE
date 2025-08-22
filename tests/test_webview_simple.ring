# اختبار بسيط لمكتبة WebView
load "webview.ring"
load "jsonlib.ring"

# إنشاء WebView
oWebView = new WebView()
oHandler = new TestHandler(oWebView)

oWebView {
    setTitle("اختبار WebView")
    setSize(800, 600, WEBVIEW_HINT_NONE)
    
    # ربط الطريقة
    bind(oHandler, [["testMethod", "testMethod"]])
    
    # HTML بسيط للاختبار
    cHTML = `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>اختبار WebView</title>
    </head>
    <body>
        <h1>اختبار WebView</h1>
        <button onclick="testFunction()">اختبار الوظيفة</button>
        <div id="result"></div>
        
        <script>
        async function testFunction() {
            try {
                console.log('Calling testMethod...');
                const result = await window.testMethod('[]');
                console.log('Result:', result);
                document.getElementById('result').innerHTML = 
                    '<p>النتيجة: ' + JSON.stringify(result) + '</p>';
            } catch (error) {
                console.error('Error:', error);
                document.getElementById('result').innerHTML = 
                    '<p>خطأ: ' + error.message + '</p>';
            }
        }
        
        // اختبار توفر الوظيفة
        window.addEventListener('load', function() {
            console.log('Window loaded');
            console.log('testMethod available:', typeof window.testMethod);
        });
        </script>
    </body>
    </html>
    `
    
    setHtml(cHTML)
    
    see "WebView started with test handler" + nl
    run()
}

see "WebView closed" + nl
# كلاس بسيط للاختبار
class TestHandler
    oWebView 
    
    func init oWebViewRef
        oWebView = oWebViewRef
    
    func testMethod id, req
        see "=== Test Method Called ===" + nl
        see "ID: " + id + nl
        see "Request: " + req + nl
        
        try
            aResult = [:message= "مرحباً من Ring!", :success= true]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, 0, cJsonResponse)
            see "Response sent successfully" + nl
        catch
            see "Error: " + cCatchError + nl
            aError = [:error= cCatchError]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, 0, cJsonError)
        done


