# ===================================================================
# Ring Programming IDE with AI Chat Assistant
# Main Application Entry Point
# ===================================================================

# Load required libraries
load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"

# Global variables
oWebView = NULL
cCurrentProject = ""
aOpenFiles = []
cCurrentCode = ""

# ===================================================================
# Main Application Function
# ===================================================================
func main()
    see "Starting Ring Programming IDE..." + nl
    
    # Create webview instance
    oWebView = new WebView()
    
    # Configure webview
    oWebView {
        setTitle("Ring Programming IDE - AI Assistant")
        setSize(1400, 900, WEBVIEW_HINT_NONE)
        
        # Bind Ring functions to JavaScript
        bind("saveFile", :saveFile)
        bind("loadFile", :loadFile)
        bind("runCode", :runCode)
        bind("chatWithAI", :chatWithAI)
        bind("getFileList", :getFileList)
        bind("createNewFile", :createNewFile)
        bind("deleteFile", :deleteFile)
        bind("analyzeCode", :analyzeCode)
        bind("formatCode", :formatCode)
        bind("getCodeSuggestions", :getCodeSuggestions)
        
        # Load the main HTML interface
        setHtml(getMainHTML())
        
        # Start the application
        run()
    }
    
    see "Ring Programming IDE closed." + nl

# ===================================================================
# HTML Interface Generator
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
        editor.setValue(\`# مرحباً بك في Ring Programming IDE
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
    return nNum1 + nNum2\`);
        
        // Update cursor position
        editor.on('cursorActivity', function() {
            const cursor = editor.getCursor();
            document.getElementById('cursorPosition').textContent = 
                \`السطر: \${cursor.line + 1}, العمود: \${cursor.ch + 1}\`;
        });
        
        // Global variables
        let currentFile = '';
        let chatHistory = [];
        
        // Initialize file list
        updateFileList();
        
        // ===================================================================
        // JavaScript Functions for UI Interaction
        // ===================================================================

        function createProject() {
            const projectName = document.getElementById('projectName').value;
            if (projectName.trim()) {
                updateStatus('تم إنشاء المشروع: ' + projectName);
                updateFileList();
            }
        }

        function createNewFile() {
            const fileName = prompt('اسم الملف الجديد (مع الامتداد):');
            if (fileName) {
                window.createNewFile(fileName).then(result => {
                    if (result) {
                        updateFileList();
                        updateStatus('تم إنشاء الملف: ' + fileName);
                    }
                });
            }
        }

        function saveCurrentFile() {
            if (currentFile) {
                const code = editor.getValue();
                window.saveFile(currentFile, code).then(result => {
                    if (result) {
                        updateStatus('تم حفظ الملف: ' + currentFile);
                    } else {
                        updateStatus('خطأ في حفظ الملف');
                    }
                });
            } else {
                const fileName = prompt('اسم الملف للحفظ:');
                if (fileName) {
                    const code = editor.getValue();
                    window.saveFile(fileName, code).then(result => {
                        if (result) {
                            currentFile = fileName;
                            updateFileList();
                            updateStatus('تم حفظ الملف: ' + fileName);
                        }
                    });
                }
            }
        }

        function loadFile(fileName) {
            if (!fileName) {
                fileName = prompt('اسم الملف للفتح:');
            }
            if (fileName) {
                window.loadFile(fileName).then(content => {
                    if (content) {
                        editor.setValue(content);
                        currentFile = fileName;
                        updateStatus('تم فتح الملف: ' + fileName);
                        highlightActiveFile(fileName);
                    } else {
                        updateStatus('خطأ في فتح الملف');
                    }
                });
            }
        }

        function runCode() {
            const code = editor.getValue();
            updateStatus('جاري تشغيل الكود...');
            window.runCode(code).then(result => {
                addChatMessage('ai', 'نتيجة التشغيل:\\n' + result);
                updateStatus('تم تشغيل الكود');
            });
        }

        function formatCode() {
            const code = editor.getValue();
            window.formatCode(code).then(formattedCode => {
                if (formattedCode) {
                    editor.setValue(formattedCode);
                    updateStatus('تم تنسيق الكود');
                }
            });
        }

        function analyzeCode() {
            const code = editor.getValue();
            updateStatus('جاري تحليل الكود...');
            window.analyzeCode(code).then(analysis => {
                addChatMessage('ai', 'تحليل الكود:\\n' + analysis);
                updateStatus('تم تحليل الكود');
            });
        }

        function sendChatMessage() {
            const input = document.getElementById('chatInput');
            const message = input.value.trim();
            if (message) {
                addChatMessage('user', message);
                input.value = '';

                showChatLoading(true);
                const currentCode = editor.getValue();
                window.chatWithAI(message, currentCode).then(response => {
                    showChatLoading(false);
                    addChatMessage('ai', response);
                });
            }
        }

        function handleChatKeyPress(event) {
            if (event.key === 'Enter') {
                sendChatMessage();
            }
        }

        function addChatMessage(sender, message) {
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + sender;
            messageDiv.textContent = message;
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function showChatLoading(show) {
            const loading = document.getElementById('chatLoading');
            loading.style.display = show ? 'block' : 'none';
        }

        function updateStatus(message) {
            document.getElementById('statusText').textContent = message;
        }

        function updateFileList() {
            window.getFileList().then(files => {
                const fileList = document.getElementById('fileList');
                fileList.innerHTML = '';

                if (files && files.length > 0) {
                    files.forEach(file => {
                        const fileDiv = document.createElement('div');
                        fileDiv.className = 'file-item';
                        fileDiv.textContent = file;
                        fileDiv.onclick = () => loadFile(file);
                        fileList.appendChild(fileDiv);
                    });
                } else {
                    fileList.innerHTML = '<div style="color: #7f8c8d; text-align: center; padding: 10px;">لا توجد ملفات</div>';
                }
            });
        }

        function highlightActiveFile(fileName) {
            const fileItems = document.querySelectorAll('.file-item');
            fileItems.forEach(item => {
                item.classList.remove('active');
                if (item.textContent === fileName) {
                    item.classList.add('active');
                }
            });
        }
    </script>
</body>
</html>
    `
    return cHTML

# ===================================================================
# Ring Backend Functions - File Operations
# ===================================================================

func saveFile(id, req)
    try
        aParams = json2list(req)
        cFileName = aParams[1]
        cContent = aParams[2]

        # Create files directory if it doesn't exist
        if not fexists("files")
            system("mkdir files")
        ok

        # Save file
        cFilePath = "files/" + cFileName
        write(cFilePath, cContent)

        # Add to open files list if not already there
        if find(aOpenFiles, cFileName) = 0
            aOpenFiles + cFileName
        ok

        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
        see "File saved: " + cFileName + nl

    catch
        see "Error saving file: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
    done

func loadFile(id, req)
    try
        aParams = json2list(req)
        cFileName = aParams[1]
        cFilePath = "files/" + cFileName

        if fexists(cFilePath)
            cContent = read(cFilePath)
            cJsonContent = list2json([cContent])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonContent)
            see "File loaded: " + cFileName + nl
        else
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "null")
            see "File not found: " + cFileName + nl
        ok

    catch
        see "Error loading file: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "null")
    done

func createNewFile(id, req)
    try
        aParams = json2list(req)
        cFileName = aParams[1]

        # Create files directory if it doesn't exist
        if not fexists("files")
            system("mkdir files")
        ok

        cFilePath = "files/" + cFileName

        # Create empty file if it doesn't exist
        if not fexists(cFilePath)
            write(cFilePath, "# " + cFileName + nl + "# Created: " + date() + " " + time() + nl + nl)
            aOpenFiles + cFileName
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
            see "New file created: " + cFileName + nl
        else
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
            see "File already exists: " + cFileName + nl
        ok

    catch
        see "Error creating file: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
    done

func deleteFile(id, req)
    try
        aParams = json2list(req)
        cFileName = aParams[1]
        cFilePath = "files/" + cFileName

        if fexists(cFilePath)
            remove(cFilePath)
            # Remove from open files list
            nIndex = find(aOpenFiles, cFileName)
            if nIndex > 0
                del(aOpenFiles, nIndex)
            ok
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
            see "File deleted: " + cFileName + nl
        else
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
        ok

    catch
        see "Error deleting file: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
    done

func getFileList(id, req)
    try {
        aFiles = []

        if fexists("files")
            # Get list of files in the files directory
            cCommand = ""
            if iswindows()
                cCommand = "dir files /b"
            else
                cCommand = "ls files"
            ok

            cResult = system(cCommand)
            aLines = str2list(cResult)

            for cLine in aLines
                cLine = trim(cLine)
                if len(cLine) > 0 and not substr(cLine, ".")
                    aFiles + cLine
                ok
            next
        ok

        cJsonFiles = list2json(aFiles)
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonFiles)

    } catch {
        see "Error getting file list: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "[]")
    }

# ===================================================================
# Ring Backend Functions - Code Operations
# ===================================================================

func runCode(id, req)
    try {
        aParams = json2list(req)
        cCode = aParams[1]

        # Save code to temporary file
        cTempFile = "temp_code.ring"
        write(cTempFile, cCode)

        # Execute the code
        cCommand = "ring " + cTempFile
        cResult = system(cCommand)

        # Clean up
        if fexists(cTempFile)
            remove(cTempFile)
        ok

        # Return result
        cJsonResult = list2json([cResult])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
        see "Code executed successfully" + nl

    } catch {
        see "Error running code: " + cCatchError + nl
        cErrorMsg = "خطأ في تشغيل الكود: " + cCatchError
        cJsonError = list2json([cErrorMsg])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
    }

func formatCode(id, req)
    try {
        aParams = json2list(req)
        cCode = aParams[1]

        # Basic code formatting for Ring
        cFormattedCode = formatRingCode(cCode)

        cJsonResult = list2json([cFormattedCode])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
        see "Code formatted successfully" + nl

    } catch {
        see "Error formatting code: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "null")
    }

func analyzeCode(id, req)
    try {
        aParams = json2list(req)
        cCode = aParams[1]

        # Analyze Ring code
        cAnalysis = analyzeRingCode(cCode)

        cJsonResult = list2json([cAnalysis])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
        see "Code analyzed successfully" + nl

    } catch {
        see "Error analyzing code: " + cCatchError + nl
        cErrorMsg = "خطأ في تحليل الكود"
        cJsonError = list2json([cErrorMsg])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
    }

func getCodeSuggestions(id, req)
    try {
        aParams = json2list(req)
        cCode = aParams[1]
        cCursor = aParams[2]

        # Generate code suggestions
        aSuggestions = generateRingSuggestions(cCode, cCursor)

        cJsonResult = list2json(aSuggestions)
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)

    } catch {
        see "Error getting suggestions: " + cCatchError + nl
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, "[]")
    }

# ===================================================================
# AI Chat Function
# ===================================================================

func chatWithAI(id, req)
    try {
        aParams = json2list(req)
        cMessage = aParams[1]
        cCurrentCode = aParams[2]

        # Process the AI chat request
        cResponse = processAIChat(cMessage, cCurrentCode)

        cJsonResponse = list2json([cResponse])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        see "AI chat processed: " + cMessage + nl

    } catch {
        see "Error in AI chat: " + cCatchError + nl
        cErrorMsg = "عذراً، حدث خطأ في معالجة طلبك. يرجى المحاولة مرة أخرى."
        cJsonError = list2json([cErrorMsg])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
    }

# ===================================================================
# Helper Functions - Code Processing
# ===================================================================

func formatRingCode(cCode)
    # Basic Ring code formatting
    aLines = str2list(cCode)
    aFormattedLines = []
    nIndentLevel = 0

    for cLine in aLines
        cTrimmedLine = trim(cLine)

        # Handle closing braces and keywords
        if substr(cTrimmedLine, "}") or
           substr(cTrimmedLine, "next") or
           substr(cTrimmedLine, "ok") or
           substr(cTrimmedLine, "else")
            nIndentLevel--
            if nIndentLevel < 0
                nIndentLevel = 0
            ok
        ok

        # Add indentation
        cIndent = copy("    ", nIndentLevel)
        if len(cTrimmedLine) > 0
            aFormattedLines + cIndent + cTrimmedLine
        else
            aFormattedLines + ""
        ok

        # Handle opening braces and keywords
        if substr(cTrimmedLine, "{") or
           substr(cTrimmedLine, "for ") or
           substr(cTrimmedLine, "while ") or
           substr(cTrimmedLine, "if ") or
           substr(cTrimmedLine, "func ") or
           substr(cTrimmedLine, "class ") or
           substr(cTrimmedLine, "else")
            nIndentLevel++
        ok
    next

    return list2str(aFormattedLines)

func analyzeRingCode(cCode)
    cAnalysis = "تحليل الكود:" + nl + nl

    # Count lines
    aLines = str2list(cCode)
    nLines = len(aLines)
    cAnalysis += "عدد الأسطر: " + nLines + nl

    # Count functions
    nFunctions = 0
    for cLine in aLines
        if substr(trim(cLine), "func ")
            nFunctions++
        ok
    next
    cAnalysis += "عدد الدوال: " + nFunctions + nl

    # Count classes
    nClasses = 0
    for cLine in aLines
        if substr(trim(cLine), "class ")
            nClasses++
        ok
    next
    cAnalysis += "عدد الكلاسات: " + nClasses + nl

    # Check for common patterns
    bHasLoops = false
    bHasConditions = false

    for cLine in aLines
        cTrimmedLine = trim(cLine)
        if substr(cTrimmedLine, "for ") or substr(cTrimmedLine, "while ")
            bHasLoops = true
        ok
        if substr(cTrimmedLine, "if ") or substr(cTrimmedLine, "switch ")
            bHasConditions = true
        ok
    next

    cAnalysis += nl + "الميزات المستخدمة:" + nl
    if bHasLoops
        cAnalysis += "- حلقات التكرار" + nl
    ok
    if bHasConditions
        cAnalysis += "- الشروط والتحكم" + nl
    ok
    if nFunctions > 0
        cAnalysis += "- الدوال المخصصة" + nl
    ok
    if nClasses > 0
        cAnalysis += "- البرمجة الكائنية" + nl
    ok

    # Basic syntax check
    cAnalysis += nl + "فحص الصيغة:" + nl
    nOpenBraces = 0
    nCloseBraces = 0

    for cLine in aLines
        nOpenBraces += substr_count(cLine, "{")
        nCloseBraces += substr_count(cLine, "}")
    next

    if nOpenBraces = nCloseBraces
        cAnalysis += "✓ الأقواس متوازنة" + nl
    else
        cAnalysis += "⚠ الأقواس غير متوازنة" + nl
    ok

    return cAnalysis

func generateRingSuggestions(cCode, cCursor)
    aSuggestions = []

    # Basic Ring keywords and functions
    aKeywords = [
        "func", "class", "if", "else", "elseif", "switch", "on", "other", "off",
        "for", "while", "do", "again", "loop", "exit", "return", "break", "continue",
        "and", "or", "not", "true", "false", "null",
        "load", "import", "package", "see", "give", "put", "get",
        "new", "call", "eval", "raise", "try", "catch", "done"
    ]

    aBuiltinFunctions = [
        "len()", "substr()", "left()", "right()", "trim()", "upper()", "lower()",
        "str2list()", "list2str()", "add()", "find()", "del()", "sort()",
        "read()", "write()", "fexists()", "remove()", "rename()",
        "date()", "time()", "clock()", "random()", "srandom()",
        "sin()", "cos()", "tan()", "sqrt()", "pow()", "floor()", "ceil()"
    ]

    # Add keywords to suggestions
    for cKeyword in aKeywords
        aSuggestions + cKeyword
    next

    # Add built-in functions to suggestions
    for cFunc in aBuiltinFunctions
        aSuggestions + cFunc
    next

    return aSuggestions

# ===================================================================
# AI Chat Processing Function
# ===================================================================

func processAIChat(cMessage, cCurrentCode)
    cResponse = ""
    cLowerMessage = lower(cMessage)

    # Analyze the message and provide appropriate response
    if substr(cLowerMessage, "مساعدة") or substr(cLowerMessage, "help")
        cResponse = getHelpResponse()

    elseif substr(cLowerMessage, "خطأ") or substr(cLowerMessage, "error")
        cResponse = getErrorHelpResponse(cCurrentCode)

    elseif substr(cLowerMessage, "كيف") or substr(cLowerMessage, "how")
        cResponse = getHowToResponse(cMessage)

    elseif substr(cLowerMessage, "مثال") or substr(cLowerMessage, "example")
        cResponse = getExampleResponse(cMessage)

    elseif substr(cLowerMessage, "تحسين") or substr(cLowerMessage, "optimize")
        cResponse = getOptimizationResponse(cCurrentCode)

    elseif substr(cLowerMessage, "شرح") or substr(cLowerMessage, "explain")
        cResponse = getExplanationResponse(cCurrentCode)

    else
        cResponse = getGeneralResponse(cMessage, cCurrentCode)
    ok

    return cResponse

func getHelpResponse()
    return "مرحباً! أنا مساعدك الذكي للبرمجة بلغة Ring. يمكنني مساعدتك في:" + nl +
           "• شرح أكواد Ring" + nl +
           "• إصلاح الأخطاء" + nl +
           "• تقديم أمثلة برمجية" + nl +
           "• تحسين الكود" + nl +
           "• الإجابة على أسئلة البرمجة" + nl +
           "• اقتراح حلول برمجية" + nl + nl +
           "اكتب سؤالك أو اطلب مساعدة محددة!"

func getErrorHelpResponse(cCode)
    cResponse = "دعني أساعدك في إصلاح الأخطاء:" + nl + nl

    if len(cCode) > 0
        # Basic error checking
        if not substr(cCode, "func main")
            cResponse += "• تأكد من وجود دالة main() في برنامجك" + nl
        ok

        nOpenBraces = substr_count(cCode, "{")
        nCloseBraces = substr_count(cCode, "}")
        if nOpenBraces != nCloseBraces
            cResponse += "• تحقق من توازن الأقواس المجعدة { }" + nl
        ok

        if not substr(cCode, "load") and not substr(cCode, "import")
            cResponse += "• قد تحتاج لتحميل مكتبات باستخدام load" + nl
        ok
    else
        cResponse += "لا يوجد كود للفحص. اكتب الكود أولاً ثم اطلب المساعدة."
    ok

    return cResponse

func getHowToResponse(cMessage)
    cResponse = "إليك بعض الأمثلة الشائعة في Ring:" + nl + nl

    if substr(cMessage, "متغير") or substr(cMessage, "variable")
        cResponse += "إنشاء المتغيرات:" + nl +
                    "cName = \"أحمد\"  # نص" + nl +
                    "nAge = 25        # رقم" + nl +
                    "bActive = true   # منطقي" + nl +
                    "aList = [1,2,3]  # قائمة" + nl

    elseif substr(cMessage, "دالة") or substr(cMessage, "function")
        cResponse += "إنشاء الدوال:" + nl +
                    "func myFunction(param1, param2)" + nl +
                    "    # كود الدالة" + nl +
                    "    return result" + nl

    elseif substr(cMessage, "حلقة") or substr(cMessage, "loop")
        cResponse += "حلقات التكرار:" + nl +
                    "for i = 1 to 10" + nl +
                    "    see i + nl" + nl +
                    "next" + nl + nl +
                    "while condition" + nl +
                    "    # كود" + nl +
                    "end"
    else
        cResponse += "حدد ما تريد تعلمه: متغيرات، دوال، حلقات، شروط، كلاسات..."
    ok

    return cResponse

func getExampleResponse(cMessage)
    return "مثال برمجي بسيط:" + nl + nl +
           "# برنامج حساب المتوسط" + nl +
           "func main()" + nl +
           "    aNumbers = [10, 20, 30, 40, 50]" + nl +
           "    nSum = 0" + nl +
           "    " + nl +
           "    for nNum in aNumbers" + nl +
           "        nSum += nNum" + nl +
           "    next" + nl +
           "    " + nl +
           "    nAverage = nSum / len(aNumbers)" + nl +
           "    see \"المتوسط: \" + nAverage + nl" + nl + nl +
           "هل تريد مثالاً على موضوع محدد؟"

func getOptimizationResponse(cCode)
    cResponse = "اقتراحات لتحسين الكود:" + nl + nl

    if len(cCode) > 0
        # Check for optimization opportunities
        if substr(cCode, "for") and substr(cCode, "see")
            cResponse += "• استخدم list2str() بدلاً من حلقة for للطباعة" + nl
        ok

        if substr_count(cCode, "if") > 3
            cResponse += "• فكر في استخدام switch بدلاً من if متعددة" + nl
        ok

        cResponse += "• استخدم أسماء متغيرات وصفية" + nl +
                    "• قسم الكود إلى دوال صغيرة" + nl +
                    "• أضف تعليقات توضيحية" + nl
    else
        cResponse = "اكتب الكود أولاً لأتمكن من اقتراح تحسينات."
    ok

    return cResponse

func getExplanationResponse(cCode)
    if len(cCode) = 0
        return "اكتب الكود أولاً لأتمكن من شرحه لك."
    ok

    cResponse = "شرح الكود:" + nl + nl
    aLines = str2list(cCode)

    for i = 1 to len(aLines)
        cLine = trim(aLines[i])
        if len(cLine) > 0 and not substr(cLine, "#")
            cResponse += "السطر " + i + ": "

            if substr(cLine, "func ")
                cResponse += "تعريف دالة جديدة"
            elseif substr(cLine, "for ")
                cResponse += "بداية حلقة تكرار"
            elseif substr(cLine, "if ")
                cResponse += "شرط منطقي"
            elseif substr(cLine, "see ")
                cResponse += "طباعة نص أو متغير"
            elseif substr(cLine, "=")
                cResponse += "إسناد قيمة لمتغير"
            else
                cResponse += "تنفيذ عملية"
            ok

            cResponse += nl
        ok
    next

    return cResponse

func getGeneralResponse(cMessage, cCurrentCode)
    return "شكراً لسؤالك! أحاول فهم طلبك..." + nl + nl +
           "يمكنني مساعدتك في:" + nl +
           "• كتابة كود Ring" + nl +
           "• شرح المفاهيم البرمجية" + nl +
           "• إصلاح الأخطاء" + nl +
           "• تحسين الأداء" + nl + nl +
           "اطرح سؤالاً أكثر تحديداً لأتمكن من مساعدتك بشكل أفضل."

# ===================================================================
# Utility Functions
# ===================================================================

func substr_count(cString, cSubString)
    nCount = 0
    nPos = 1
    while true
        nPos = substr(cString, cSubString, nPos)
        if nPos = 0
            exit
        ok
        nCount++
        nPos++
    end
    return nCount
