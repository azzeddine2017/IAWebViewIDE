# ===================================================================
# مثال شامل على استخدام نظام ربط الطرق مع RingWebView
# ===================================================================

load "src/webview_method_wrapper.ring"
load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"

# ===================================================================
# تشغيل المثال
# ===================================================================
func main()
    oApp = new RingIDEExample()
    oApp.start()



# ===================================================================
# مثال على تطبيق كامل باستخدام النظام الجديد
# ===================================================================
class RingIDEExample
    
    oWebView = NULL
    oFileHandler = NULL
    oProjectHandler = NULL
    oCodeHandler = NULL
    
    func init()
        see "تهيئة Ring IDE مع نظام الطرق الجديد..." + nl
    
    func start()
        try
            # إنشاء WebView
            this.oWebView = new WebView()
            
            # إنشاء معالجات الطرق
            oFileHandler = new AdvancedFileHandler(this.oWebView)
            oProjectHandler = new ProjectHandler(this.oWebView)
            oCodeHandler = new CodeHandler(this.oWebView)
            
            this.oWebView {
                setTitle("Ring IDE - Method Wrapper Example")
                setSize(1200, 800, WEBVIEW_HINT_NONE)
                
                # ربط طرق معالج الملفات
                aFileMethodsList = [
                    ["saveFile", "saveFile"],
                    ["loadFile", "loadFile"],
                    ["createFile", "createFile"],
                    ["deleteFile", "deleteFile"],
                    ["getFileList", "getFileList"]
                ]
                BindObjectMethods(this.oWebView, this.oFileHandler, aFileMethodsList)
                
                # ربط طرق معالج المشاريع
                aProjectMethodsList = [
                    ["createProject", "createProject"],
                    ["openProject", "openProject"],
                    ["saveProject", "saveProject"],
                    ["getProjectInfo", "getProjectInfo"]
                ]
                BindObjectMethods(this.oWebView, this.oProjectHandler, aProjectMethodsList)
                
                # ربط طرق معالج الكود
                aCodeMethodsList = [
                    ["runCode", "runCode"],
                    ["formatCode", "formatCode"],
                    ["analyzeCode", "analyzeCode"],
                    ["debugCode", "debugCode"]
                ]
                BindObjectMethods(this.oWebView, this.oCodeHandler, aCodeMethodsList)
                
                see "تم ربط جميع الطرق بنجاح!" + nl
                
                # تحميل واجهة HTML
                cHtmlContent = this.generateHTML()
                setHtml(cHtmlContent)
                
                # بدء التطبيق
                run()
            }
            
        catch
            see "خطأ في بدء التطبيق: " + cCatchError + nl
        done
    
    func generateHTML()
        return `
        <!DOCTYPE html>
        <html dir="rtl">
        <head>
            <meta charset="UTF-8">
            <title>Ring IDE - Method Wrapper Example</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
                button { margin: 5px; padding: 10px; }
                textarea { width: 100%; height: 200px; }
            </style>
        </head>
        <body>
            <h1>مثال على نظام ربط الطرق</h1>
            
            <div class="section">
                <h2>عمليات الملفات</h2>
                <button onclick="testSaveFile()">حفظ ملف</button>
                <button onclick="testLoadFile()">تحميل ملف</button>
                <button onclick="testCreateFile()">إنشاء ملف</button>
                <button onclick="testGetFileList()">قائمة الملفات</button>
            </div>
            
            <div class="section">
                <h2>عمليات المشاريع</h2>
                <button onclick="testCreateProject()">إنشاء مشروع</button>
                <button onclick="testOpenProject()">فتح مشروع</button>
                <button onclick="testSaveProject()">حفظ مشروع</button>
            </div>
            
            <div class="section">
                <h2>عمليات الكود</h2>
                <textarea id="codeArea">see "مرحباً من Ring!"</textarea><br>
                <button onclick="testRunCode()">تشغيل الكود</button>
                <button onclick="testFormatCode()">تنسيق الكود</button>
                <button onclick="testAnalyzeCode()">تحليل الكود</button>
            </div>
            
            <div class="section">
                <h2>النتائج</h2>
                <div id="results" style="background: #f0f0f0; padding: 10px; height: 200px; overflow-y: scroll;"></div>
            </div>
            
            <script>
                function addResult(message) {
                    const results = document.getElementById('results');
                    results.innerHTML += '<div>' + new Date().toLocaleTimeString() + ': ' + message + '</div>';
                    results.scrollTop = results.scrollHeight;
                }
                
                function testSaveFile() {
                    saveFile(["test.ring", "see 'Hello World!'"]).then(result => {
                        addResult('حفظ الملف: ' + JSON.stringify(result));
                    });
                }
                
                function testLoadFile() {
                    loadFile(["test.ring"]).then(result => {
                        addResult('تحميل الملف: ' + JSON.stringify(result));
                    });
                }
                
                function testCreateFile() {
                    createFile(["new_file.ring"]).then(result => {
                        addResult('إنشاء الملف: ' + JSON.stringify(result));
                    });
                }
                
                function testGetFileList() {
                    getFileList([]).then(result => {
                        addResult('قائمة الملفات: ' + JSON.stringify(result));
                    });
                }
                
                function testCreateProject() {
                    createProject(["مشروع جديد"]).then(result => {
                        addResult('إنشاء المشروع: ' + JSON.stringify(result));
                    });
                }
                
                function testOpenProject() {
                    openProject([]).then(result => {
                        addResult('فتح المشروع: ' + JSON.stringify(result));
                    });
                }
                
                function testSaveProject() {
                    saveProject([]).then(result => {
                        addResult('حفظ المشروع: ' + JSON.stringify(result));
                    });
                }
                
                function testRunCode() {
                    const code = document.getElementById('codeArea').value;
                    runCode([code]).then(result => {
                        addResult('تشغيل الكود: ' + JSON.stringify(result));
                    });
                }
                
                function testFormatCode() {
                    const code = document.getElementById('codeArea').value;
                    formatCode([code]).then(result => {
                        addResult('تنسيق الكود: ' + JSON.stringify(result));
                        if (result.formatted_code) {
                            document.getElementById('codeArea').value = result.formatted_code;
                        }
                    });
                }
                
                function testAnalyzeCode() {
                    const code = document.getElementById('codeArea').value;
                    analyzeCode([code]).then(result => {
                        addResult('تحليل الكود: ' + JSON.stringify(result));
                    });
                }
                
                // إضافة رسالة ترحيب
                addResult('مرحباً بك في مثال نظام ربط الطرق!');
            </script>
        </body>
        </html>
        `

