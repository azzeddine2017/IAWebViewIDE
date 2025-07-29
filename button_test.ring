# ===================================================================
# Simple Button Test - Ring WebView
# ===================================================================

load "webview.ring"
load "jsonlib.ring"

oWebView = new WebView()

oWebView {
    setTitle("اختبار الأزرار - Ring WebView")
    setSize(800, 600, WEBVIEW_HINT_NONE)
    
    # ربط الدوال
    bind("testFunction", :testFunction)
    bind("createProject", :createProject)
    bind("saveFile", :saveFile)
    
    setHtml(`
        <!DOCTYPE html>
        <html dir="rtl" lang="ar">
        <head>
            <meta charset="UTF-8">
            <title>اختبار الأزرار</title>
            <style>
                body { font-family: Arial; padding: 20px; }
                button { 
                    padding: 15px 30px; 
                    margin: 10px; 
                    font-size: 16px;
                    background: #007bff;
                    color: white;
                    border: none;
                    border-radius: 5px;
                    cursor: pointer;
                }
                button:hover { background: #0056b3; }
                .result { 
                    margin: 20px 0; 
                    padding: 15px; 
                    background: #f8f9fa; 
                    border: 1px solid #dee2e6;
                    border-radius: 5px;
                }
            </style>
        </head>
        <body>
            <h1>اختبار الأزرار مع Ring</h1>
            
            <button onclick="callRingFunction()">اختبار دالة Ring</button>
            <button onclick="callCreateProject()">إنشاء مشروع</button>
            <button onclick="callSaveFile()">حفظ ملف</button>
            
            <div id="result" class="result">اضغط على أي زر لاختبار الوظيفة...</div>
            
            <script>
                async function callRingFunction() {
                    try {
                        document.getElementById('result').innerHTML = 'جاري استدعاء دالة Ring...';
                        const response = await window.testFunction('مرحباً من JavaScript!');
                        document.getElementById('result').innerHTML = 'استجابة Ring: ' + response;
                        console.log('Ring response:', response);
                    } catch (error) {
                        document.getElementById('result').innerHTML = 'خطأ: ' + error.message;
                        console.error('Error:', error);
                    }
                }
                
                async function callCreateProject() {
                    try {
                        document.getElementById('result').innerHTML = 'جاري إنشاء المشروع...';
                        const response = await window.createProject('مشروع تجريبي');
                        document.getElementById('result').innerHTML = 'تم إنشاء المشروع: ' + response;
                        console.log('Create project response:', response);
                    } catch (error) {
                        document.getElementById('result').innerHTML = 'خطأ في إنشاء المشروع: ' + error.message;
                        console.error('Error:', error);
                    }
                }
                
                async function callSaveFile() {
                    try {
                        document.getElementById('result').innerHTML = 'جاري حفظ الملف...';
                        const response = await window.saveFile('test.ring', 'see "Hello World!" + nl');
                        document.getElementById('result').innerHTML = 'تم حفظ الملف: ' + response;
                        console.log('Save file response:', response);
                    } catch (error) {
                        document.getElementById('result').innerHTML = 'خطأ في حفظ الملف: ' + error.message;
                        console.error('Error:', error);
                    }
                }
                
                // Test function availability on load
                window.addEventListener('load', function() {
                    console.log('Testing Ring functions:');
                    console.log('testFunction:', typeof window.testFunction);
                    console.log('createProject:', typeof window.createProject);
                    console.log('saveFile:', typeof window.saveFile);
                });
            </script>
        </body>
        </html>
    `)
    
    run()
}

# تعريف دوال Ring
func testFunction(id, req)
    try
        aParams = json2list(req)
        cMessage = aParams[1][1]
        cResponse = "تم استلام الرسالة: " + cMessage + " - الوقت: " + time()
       ? cResponse
	oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"' + cResponse + '"')
    catch
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"خطأ في معالجة الطلب"')
    done

func createProject(id, req)
    try
        aParams = json2list(req)
        cProjectName = aParams[1][1]
        cResponse = "تم إنشاء المشروع: " + cProjectName
	? cResponse
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"' + cResponse + '"')
    catch
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"خطأ في إنشاء المشروع"')
    done

func saveFile(id, req)
    try
        aParams = json2list(req)
        cFileName = aParams[1][1]
        cContent = aParams[1][2]
        cResponse = "تم حفظ الملف: " + cFileName + " بحجم " + len(cContent) + " حرف"
        ? cResponse
	oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"' + cResponse + '"')
    catch
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"خطأ في حفظ الملف"')
    done
