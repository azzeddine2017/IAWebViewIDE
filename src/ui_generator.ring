# ===================================================================
# UI Generator Class - Generates HTML interface
# ===================================================================

class UIGenerator
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        see "UIGenerator initialized." + nl
    
    # ===================================================================
    # Get Main HTML Interface
    # ===================================================================
    func getMainHTML()
        cHTML = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ring Programming IDE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/theme/monokai.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            overflow: hidden;
        }
        
        .container {
            display: flex;
            height: 100vh;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
        }
        
        .sidebar {
            width: 250px;
            background: #2c3e50;
            color: white;
            padding: 20px;
            overflow-y: auto;
        }
        
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .toolbar {
            background: #34495e;
            color: white;
            padding: 10px 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .editor-container {
            flex: 1;
            display: flex;
        }
        
        .code-editor {
            flex: 2;
            background: #2c3e50;
        }
        
        .chat-panel {
            width: 400px;
            background: #ecf0f1;
            display: flex;
            flex-direction: column;
            border-left: 2px solid #bdc3c7;
        }
        
        .chat-header {
            background: #3498db;
            color: white;
            padding: 15px;
            text-align: center;
            font-weight: bold;
        }
        
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f8f9fa;
        }
        
        .chat-input-container {
            padding: 20px;
            background: white;
            border-top: 1px solid #ddd;
        }
        
        .btn {
            background: #3498db;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn:hover {
            background: #2980b9;
        }
        
        .btn-success {
            background: #27ae60;
        }
        
        .btn-success:hover {
            background: #229954;
        }
        
        .btn-danger {
            background: #e74c3c;
        }
        
        .btn-danger:hover {
            background: #c0392b;
        }
        
        .file-item {
            padding: 8px;
            margin: 4px 0;
            background: #34495e;
            border-radius: 4px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .file-item:hover {
            background: #4a6741;
        }
        
        .file-item.active {
            background: #3498db;
        }
        
        .message {
            margin: 10px 0;
            padding: 10px;
            border-radius: 8px;
            max-width: 80%;
        }
        
        .message.user {
            background: #3498db;
            color: white;
            margin-left: auto;
            text-align: right;
        }
        
        .message.ai {
            background: #ecf0f1;
            color: #2c3e50;
        }
        
        .input-group {
            display: flex;
            gap: 10px;
        }
        
        .input-group input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .CodeMirror {
            height: 100%;
            font-size: 14px;
        }
        
        .status-bar {
            background: #2c3e50;
            color: white;
            padding: 5px 20px;
            font-size: 12px;
        }
        
        .project-section {
            margin-bottom: 20px;
        }
        
        .project-section h3 {
            margin-bottom: 10px;
            color: #3498db;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="project-section">
                <h3>المشروع الحالي</h3>
                <div class="input-group">
                    <input type="text" id="projectName" placeholder="اسم المشروع" value="مشروع جديد">
                    <button class="btn btn-success" onclick="createProject()">إنشاء</button>
                </div>
            </div>
            
            <div class="project-section">
                <h3>الملفات</h3>
                <button class="btn" onclick="createNewFile()">ملف جديد</button>
                <div id="fileList" style="margin-top: 10px;">
                    <!-- File list will be populated here -->
                </div>
            </div>
            
            <div class="project-section">
                <h3>الأدوات</h3>
                <button class="btn" onclick="formatCode()">تنسيق الكود</button>
                <button class="btn" onclick="analyzeCode()">تحليل الكود</button>
                <button class="btn btn-success" onclick="runCode()">تشغيل</button>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="main-content">
            <!-- Toolbar -->
            <div class="toolbar">
                <button class="btn" onclick="saveCurrentFile()">حفظ</button>
                <button class="btn" onclick="loadFile()">فتح</button>
                <span style="margin-left: auto;">Ring Programming IDE v1.0</span>
            </div>
            
            <!-- Editor Container -->
            <div class="editor-container">
                <!-- Code Editor -->
                <div class="code-editor">
                    <textarea id="codeEditor"></textarea>
                </div>
                
                <!-- Chat Panel -->
                <div class="chat-panel">
                    <div class="chat-header">
                        مساعد البرمجة الذكي
                    </div>
                    <div class="chat-messages" id="chatMessages">
                        <div class="message ai">
                            مرحباً! أنا مساعدك الذكي للبرمجة بلغة Ring. كيف يمكنني مساعدتك اليوم؟
                        </div>
                    </div>
                    <div class="loading" id="chatLoading">
                        جاري التفكير...
                    </div>
                    <div class="chat-input-container">
                        <div class="input-group">
                            <input type="text" id="chatInput" placeholder="اكتب سؤالك هنا..." onkeypress="handleChatKeyPress(event)">
                            <button class="btn" onclick="sendChatMessage()">إرسال</button>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Status Bar -->
            <div class="status-bar">
                <span id="statusText">جاهز</span>
                <span style="float: left;" id="cursorPosition">السطر: 1, العمود: 1</span>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/mode/clike/clike.min.js"></script>
    <script>
        // Utility functions for Ring communication
        async function callRing(funcName, ...args) {
            try {
                console.log("Calling Ring function: ${funcName} with args:", args);
                const response = await window[funcName](JSON.stringify(args));
                console.log("Response from Ring (${funcName}):", response);
                return response;
            } catch (error) {
                console.error("Error calling Ring function ${funcName}:", error);
                throw error;
            }
        }

        function showStatus(message) {
            const statusText = document.getElementById('statusText');
            if (statusText) {
                statusText.textContent = message;
            }
        }

        // File Operations
        async function createNewFile() {
            try {
                const fileName = prompt("أدخل اسم الملف:", "new_file.ring");
                if (!fileName) return;
                
                showStatus("جاري إنشاء الملف...");
                const response = await callRing('createNewFile', fileName);
                
                if (response === "true") {
                    await updateFileList();
                    showStatus("تم إنشاء الملف " + fileName);
                } else {
                    showStatus("فشل في إنشاء الملف");
                }
            } catch (error) {
                showStatus("حدث خطأ في إنشاء الملف");
            }
        }

        async function deleteFile(fileName) {
            try {
                if (!confirm("هل أنت متأكد من حذف الملف: " + fileName + "؟")) return;
                
                showStatus("جاري حذف الملف...");
                const response = await callRing('deleteFile', fileName);
                
                if (response === "true") {
                    await updateFileList();
                    showStatus("تم حذف الملف");
                } else {
                    showStatus("فشل في حذف الملف");
                }
            } catch (error) {
                showStatus("حدث خطأ في حذف الملف");
            }
        }

        async function saveCurrentFile() {
            try {
                if (!currentFile) {
                    currentFile = prompt("أدخل اسم الملف للحفظ:", "new_file.ring");
                    if (!currentFile) return;
                }
                
                showStatus("جاري حفظ الملف...");
                const code = editor.getValue();
                const response = await callRing('saveFile', currentFile, code);
                
                if (response === "true") {
                    showStatus("تم حفظ الملف " + currentFile);
                } else {
                    showStatus("فشل في حفظ الملف");
                }
            } catch (error) {
                showStatus("حدث خطأ في حفظ الملف");
            }
        }

        async function updateFileList() {
            try {
                const response = await callRing('getFileList');
                const files = JSON.parse(response);
                
                const fileList = document.getElementById('fileList');
                fileList.innerHTML = '';
                
                files.forEach(file => {
                    const div = document.createElement('div');
                    div.className = 'file-item';
                    div.textContent = file;
                    div.onclick = () => loadFile(file);
                    fileList.appendChild(div);
                });
            } catch (error) {
                showStatus("حدث خطأ في تحديث قائمة الملفات");
            }
        }
    </script>
    <script>
        // Initialize CodeMirror
        let editor = CodeMirror.fromTextArea(document.getElementById('codeEditor'), {
            lineNumbers: true,
            mode: 'text/x-csrc',
            theme: 'monokai',
            indentUnit: 4,
            lineWrapping: true,
            autoCloseBrackets: true,
            matchBrackets: true
        });
        
        // Set initial Ring code example
        editor.setValue(`+
'# مرحباً بك في Ring Programming IDE
# هذا مثال بسيط لبرنامج Ring

load "stdlib.ring"

func main()
    see "مرحباً بالعالم من Ring!" + nl
    
    # متغيرات
    cName = "المطور"
    nAge = 25
    
    see "الاسم: " + cName + nl
    see "العمر: " + nAge + nl
    
    # حلقة تكرار
    for i = 1 to 5
        see "العدد: " + i + nl
    next
    
    # استدعاء دالة
    result = calculateSum(10, 20)
    see "النتيجة: " + result + nl

func calculateSum(nNum1, nNum2)
    return nNum1 + nNum2' +
`);
        
        // Update cursor position
        editor.on('cursorActivity', function() {
            const cursor = editor.getCursor();
            document.getElementById('cursorPosition').textContent = 
                "السطر: ${cursor.line + 1}, العمود: ${cursor.ch + 1}";
        });
        
        // Global variables
        let currentFile = '';
        let chatHistory = [];
        
        // Initialize file list
        updateFileList();
    </script>
</body>
</html>
        `
        return cHTML
