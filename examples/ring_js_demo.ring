# ===================================================================
# Ring-JavaScript Integration Example
# ===================================================================

load "webview.ring"
load "jsonlib.ring"

oWebView = new WebView()

# تعريف المتغيرات العامة قبل تحميل الصفحة
oWebView.injectJS(`
    window.ringVersion = '1.0';
    window.debugMode = true;
    console.log('Ring WebView initialized with version:', window.ringVersion);
`)

# دالة Ring للترحيب
func greet(id, req)
    see "Received request from JavaScript" + nl
    aArgs = json2list(req)
    cName = aArgs[1]
    
    # تحديث واجهة المستخدم من Ring
    oWebView.evalJS("document.getElementById('response').innerText = 'Ring says: مرحباً يا " + cName + "!';")
    
    # إرجاع رد إلى JavaScript
    oWebView.wreturn(id, WEBVIEW_ERROR_OK, '"تم استلام التحية!"')

# دالة Ring تعمل في الخلفية
func updateStatus()
    oWebView.evalJS("document.getElementById('status').innerText = 'تم التحديث في: " + time() + "';")

oWebView {
    setTitle("مثال على الربط بين Ring و JavaScript")
    setSize(800, 600, WEBVIEW_HINT_NONE)
    
    # ربط دالة Ring مع JavaScript
    bind("greet", :greet)
    
    setHtml(`
        <!DOCTYPE html>
        <html dir="rtl" lang="ar">
        <head>
            <meta charset="UTF-8">
            <title>Ring-JS Demo</title>
            <style>
                body { font-family: 'Segoe UI', Tahoma; padding: 20px; }
                .container { max-width: 600px; margin: 0 auto; }
                .card { background: #f0f0f0; padding: 20px; margin: 10px 0; border-radius: 8px; }
                button { padding: 10px 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="card">
                    <h2>اختبار الربط بين Ring و JavaScript</h2>
                    <input type="text" id="nameInput" placeholder="أدخل اسمك">
                    <button onclick="callRing()">إرسال إلى Ring</button>
                    <div id="response"></div>
                </div>
                
                <div class="card">
                    <h3>حالة النظام</h3>
                    <div id="status">جارٍ التحميل...</div>
                </div>
            </div>

            <script>
                // دالة لاستدعاء Ring
                async function callRing() {
                    const name = document.getElementById('nameInput').value;
                    try {
                        const response = await window.greet(name);
                        console.log('Ring response:', response);
                    } catch (error) {
                        console.error('Error calling Ring:', error);
                    }
                }

                // طباعة المتغيرات العامة التي تم حقنها من Ring
                console.log('Debug mode:', window.debugMode);
            </script>
        </body>
        </html>
    `)
    
    # تحديث الحالة كل ثانيتين
    see "Starting update thread..." + nl
    dispatch("updateStatus()")
}

# تشغيل الحلقة الرئيسية
oWebView.run()
