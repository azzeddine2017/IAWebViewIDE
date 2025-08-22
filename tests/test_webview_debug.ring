# اختبار مفصل لمكتبة WebView لتشخيص المشاكل
load "webview.ring"
load "jsonlib.ring"


# إنشاء WebView والمعالج
see "Creating WebView and handler..." + nl
oWebView = new WebView()
oHandler = new DebugHandler(oWebView)

oWebView {
    setTitle("اختبار WebView - تشخيص المشاكل")
    setSize(900, 700, WEBVIEW_HINT_NONE)
    
    see "Binding methods..." + nl
    # ربط الطرق
    bind(oHandler, [
        ["testMethod", "testMethod"],
        ["simpleTest", "simpleTest"]
    ])
    see "Methods bound successfully!" + nl
    
    # HTML محسن للاختبار
    cHTML = `
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="UTF-8">
        <title>اختبار WebView - تشخيص</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
            button { padding: 10px 20px; margin: 10px; font-size: 16px; border: none; border-radius: 5px; cursor: pointer; }
            .btn-primary { background: #007bff; color: white; }
            .btn-success { background: #28a745; color: white; }
            .btn-warning { background: #ffc107; color: black; }
            #result { margin-top: 20px; padding: 15px; border-radius: 5px; min-height: 100px; }
            .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
            .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
            .info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; }
            pre { background: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔧 اختبار WebView - تشخيص المشاكل</h1>
            
            <div>
                <h3>اختبارات الربط:</h3>
                <button class="btn-primary" onclick="testSimple()">اختبار بسيط</button>
                <button class="btn-success" onclick="testWithData()">اختبار مع بيانات</button>
                <button class="btn-warning" onclick="testFunctionAvailability()">فحص الوظائف</button>
            </div>
            
            <div id="result" class="info">
                <strong>جاهز للاختبار...</strong><br>
                انقر على أي زر لبدء الاختبار
            </div>
        </div>
        
        <script>
        console.log('🚀 JavaScript loaded');
        
        // فحص توفر الوظائف
        function testFunctionAvailability() {
            updateResult('info', 'فحص الوظائف المتاحة...');
            
            const functions = ['testMethod', 'simpleTest'];
            let results = '<h4>📋 نتائج فحص الوظائف:</h4>';
            
            functions.forEach(func => {
                const available = typeof window[func] === 'function';
                const status = available ? '✅ متاح' : '❌ غير متاح';
                results += '<div>' + func + ': ' + status + '</div>';
                console.log(func + ':', typeof window[func]);
            });
            
            updateResult('info', results);
        }
        
        // اختبار بسيط بدون بيانات
        async function testSimple() {
            updateResult('info', '🔄 تشغيل الاختبار البسيط...');
            
            try {
                console.log('Calling simpleTest...');
                const result = await window.simpleTest('');
                console.log('Simple test result:', result);
                
                updateResult('success', 
                    '<h4>✅ الاختبار البسيط نجح!</h4>' +
                    '<pre>' + JSON.stringify(result, null, 2) + '</pre>'
                );
            } catch (error) {
                console.error('Simple test error:', error);
                updateResult('error', 
                    '<h4>❌ فشل الاختبار البسيط</h4>' +
                    '<div>الخطأ: ' + error.message + '</div>'
                );
            }
        }
        
        // اختبار مع بيانات
        async function testWithData() {
            updateResult('info', '🔄 تشغيل الاختبار مع البيانات...');
            
            try {
                const testData = ['test', 'data', 123];
                const jsonData = JSON.stringify(testData);
                
                console.log('Calling testMethod with data:', jsonData);
                const result = await window.testMethod(jsonData);
                console.log('Test with data result:', result);
                
                updateResult('success', 
                    '<h4>✅ الاختبار مع البيانات نجح!</h4>' +
                    '<div><strong>البيانات المرسلة:</strong> ' + jsonData + '</div>' +
                    '<div><strong>النتيجة:</strong></div>' +
                    '<pre>' + JSON.stringify(result, null, 2) + '</pre>'
                );
            } catch (error) {
                console.error('Test with data error:', error);
                updateResult('error', 
                    '<h4>❌ فشل الاختبار مع البيانات</h4>' +
                    '<div>الخطأ: ' + error.message + '</div>'
                );
            }
        }
        
        // تحديث منطقة النتائج
        function updateResult(type, content) {
            const resultDiv = document.getElementById('result');
            resultDiv.className = type;
            resultDiv.innerHTML = content;
        }
        
        // اختبار تلقائي عند التحميل
        window.addEventListener('load', function() {
            console.log('🎯 Page loaded, running automatic tests...');
            setTimeout(testFunctionAvailability, 1000);
        });
        </script>
    </body>
    </html>
    `
    
    setHtml(cHTML)
    
    see "🚀 WebView started with debug handler" + nl
    see "Check the browser console for detailed logs" + nl
    run()
}

see "🏁 WebView closed" + nl


# كلاس للاختبار مع تشخيص مفصل
class DebugHandler
    oWebView 
    
    func init oWebViewRef
        oWebView = oWebViewRef
        see "DebugHandler initialized" + nl
    
    func testMethod id, req
        see "=== Test Method Called ===" + nl
        see "ID: " + id + " (type: " + type(id) + ")" + nl
        see "Request: " + req + " (type: " + type(req) + ")" + nl
        
        if req != NULL
            see "Request length: " + len(req) + nl
        else
            see "Request is NULL" + nl
        ok
        
        try
            # محاولة تحليل JSON إذا كان موجود
            if req != NULL and len(req) > 0
                see "Attempting to parse JSON..." + nl
                aParams = json2list(req)
                see "Parsed successfully!" + nl
                see "Params type: " + type(aParams) + nl
                see "Params content: " + list2str(aParams) + nl
            else
                see "No JSON to parse" + nl
            ok
            
            # إرسال رد ناجح
            aResult = [
                :message= "تم استلام الطلب بنجاح!",
                :success= true,
                :timestamp= date() + " " + time(),
                :received_id= id,
                :received_req= req
            ]
            cJsonResponse = list2json(aResult)
            see "Sending response: " + cJsonResponse + nl
            
            oWebView.wreturn(id, 0, cJsonResponse)
            see "✓ Response sent successfully!" + nl
            
        catch
            see "✗ Error in testMethod: " + cCatchError + nl
            aError = [
                :error= cCatchError,
                :details= "خطأ في معالجة الطلب",
                :received_id= id,
                :received_req= req
            ]
            cJsonError = list2json(aError)
            see "Sending error response: " + cJsonError + nl
            oWebView.wreturn(id, 0, cJsonError)
        done
    
    func simpleTest id, req
        see "=== Simple Test Called ===" + nl
        try
            aResult = [:message= "اختبار بسيط نجح!", :success= true]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, 0, cJsonResponse)
            see "Simple test response sent" + nl
        catch
            see "Error in simpleTest: " + cCatchError + nl
        done

