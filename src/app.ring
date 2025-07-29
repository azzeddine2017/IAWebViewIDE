# ===================================================================
# Ring IDE Application Class
# ===================================================================

load "webview.ring"
load "jsonlib.ring"
load "stdlib.ring"
load "smart_agent.ring"
load "ui_generator.ring"
load "file_manager.ring"
load "code_runner.ring"

# ===================================================================
# Main Application Class
# ===================================================================
class RingIDE
    
    # Public properties
    oWebView = NULL
    oSmartAgent = NULL
    oUIGenerator = NULL
    oFileManager = NULL
    oCodeRunner = NULL
    cCurrentProject = ""
    oWebView = NULL
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        see "Initializing Ring IDE with Smart Agent..." + nl

        # Initialize components
        oSmartAgent = new SmartAgent()
        oUIGenerator = new UIGenerator()
        oFileManager = new FileManager()
        oCodeRunner = new CodeRunner()
        
        see "All components initialized successfully." + nl
    
    # ===================================================================
    # Start Application
    # ===================================================================
    func start()
        try
            # Create webview instance
            this.oWebView = new WebView()
            
            # Configure webview
            this.oWebView {
                setTitle("Ring Programming IDE - AI Powered Agent")
                setSize(1400, 900, WEBVIEW_HINT_NONE)
                
                 # You can also use bindMany(BindList) to explicitly bind the list.
                 # Like this: 
                BindList = [
                # Bind Ring functions to JavaScript
               ["processRequest", :processRequest],
               ["chatWithAI", :chatWithAI],
               ["sendAIRequest", :sendAIRequest],
               ["getAgentStatus", :getAgentStatus],
               ["setCurrentProject", :setCurrentProject],
               ["setCurrentFile", :setCurrentFile],

                # Legacy functions for backward compatibility
                ["saveFile", :saveFile],
                ["loadFile", :loadFile],
                ["runCode", :runCode],
                ["getFileList", :getFileList],
                ["createNewFile", :createNewFile],
                ["deleteFile", :deleteFile],
                ["analyzeCode", :analyzeCode],
                ["formatCode", :formatCode],
                ["getCodeSuggestions", :getCodeSuggestions],
                ["openFile", :openFile],
                ["createProject", :createProject],
                ["openProject", :openProject],
                ["saveProject", :saveProject],
                ["debugCode", :debugCode],
                ["testConnection", :testConnection]
                ]
                
                # Bind all functions to JavaScript
                bindMany(BindList)
                see "Functions bound to JavaScript successfully" + nl

                # Print bound functions for debugging
                see "Bound functions:" + nl
                for aFunc in BindList
                    see "  - " + aFunc[1] + nl
                next

                # Load the main HTML interface
                //setHtml(this.oUIGenerator.getMainHTML())

                # Navigate the webview to a local HTML file.
	            # Prepend "file://" to the absolute path for local file access.
	            cHtmlPath = "file://" + currentdir() + "/assets/html/new_index.html"
	            see "Loading HTML interface: " + cHtmlPath + nl
	            navigate(cHtmlPath)
                
                # Start the application
                run()
            }
            
        catch
            see "Error starting application: " + cCatchError + nl
        done
    
    # ===================================================================
    # File Operations - Delegate to FileManager
    # ===================================================================
    func saveFile(id, req)
        see "=== SaveFile Function Called ===" + nl
        see "ID: " + id + nl
        see "Request Data: " + req + nl

        try
            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات حفظ الملف غير صحيحة"
                cJsonError = list2json(["error": cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1]
            cContent = aParams[2]
            see "Saving file: " + cFileName + nl

            # Simple file save simulation for now
            cJsonResponse = list2json(["success": "تم حفظ الملف بنجاح", "fileName": cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File saved successfully: " + cFileName + nl

        catch
            see "Error in saveFile: " + cCatchError + nl
            cErrorMsg = "خطأ في حفظ الملف: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    func loadFile(id, req)
        see "=== LoadFile Function Called ===" + nl
        see "ID: " + id + nl
        see "Request Data: " + req + nl

        try
            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تحميل الملف غير صحيحة"
                cJsonError = list2json(["error": cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1]
            see "Loading file: " + cFileName + nl

            # Simple file load simulation for now
            cSampleContent = "# مرحباً بك في Ring Programming IDE" + nl +
                           "# هذا محتوى تجريبي للملف: " + cFileName + nl + nl +
                           "load " + char(34) + "stdlib.ring" + char(34) + nl + nl +
                           "func main" + nl +
                           "    see " + char(34) + "مرحباً من " + cFileName + "!" + char(34) + " + nl" + nl +
                           "main()"

            cJsonResponse = list2json(["content": cSampleContent, "fileName": cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File loaded successfully: " + cFileName + nl

        catch
            see "Error in loadFile: " + cCatchError + nl
            cErrorMsg = "خطأ في تحميل الملف: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func createNewFile(id, req)
        see "=== CreateNewFile Function Called ===" + nl
        see "ID: " + id + nl
        see "Request Data: " + req + nl
        see "Request Type: " + type(req) + nl

        try
            if req = NULL or len(req) = 0
                see "Warning: Empty request received in createNewFile" + nl
                cJsonError = list2json(["error": "طلب فارغ"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات إنشاء الملف غير صحيحة"
                cJsonError = list2json(["error": cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                see "Error: Invalid parameters" + nl
                return
            ok

            cFileName = aParams[1]
            see "Creating file: " + cFileName + nl

            # Simple file creation for now
            cJsonResponse = list2json(["success": "تم إنشاء الملف بنجاح", "fileName": cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File created successfully: " + cFileName + nl

        catch
            see "Error in createNewFile: " + cCatchError + nl
            cErrorMsg = "خطأ في إنشاء الملف: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func deleteFile(id, req)
        see "DeleteFile - Request Data: " + req + nl
        if req = NULL or len(req) = 0
            see "Warning: Empty request received in deleteFile" + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
            return
        ok
        oFileManager.deleteFile(id, req, this.oWebView)

    func getFileList(id, req)
        try
            see "GetFileList - Request Data: " + req + nl

            # Return a simple file list for now
            aFileList = [
                ["name": "main.ring", "active": true],
                ["name": "test.ring", "active": false],
                ["name": "example.ring", "active": false]
            ]

            cResult = ["files": aFileList]
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File list sent successfully" + nl

        catch
            see "Error in getFileList: " + cCatchError + nl
            cErrorMsg = "خطأ في جلب قائمة الملفات: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # Code Operations - Delegate to CodeRunner
    # ===================================================================
    func runCode(id, req)
        see "=== RunCode Function Called ===" + nl
        see "ID: " + id + nl
        see "Request Data: " + req + nl

        try
            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تشغيل الكود غير صحيحة"
                cJsonError = list2json(["error": cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1]
            see "Running code: " + substr(cCode, 1, 100) + "..." + nl

            # Simple code execution simulation for now
            cOutput = "تم تشغيل الكود بنجاح!" + nl + "الكود: " + nl + cCode
            cJsonResponse = list2json(["output": cOutput])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "Code executed successfully" + nl

        catch
            see "Error in runCode: " + cCatchError + nl
            cErrorMsg = "خطأ في تشغيل الكود: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    func formatCode(id, req)
        oCodeRunner.formatCode(id, req, this.oWebView)

    func analyzeCode(id, req)
        oCodeRunner.analyzeCode(id, req, this.oWebView)

    func getCodeSuggestions(id, req)
        # Legacy function - redirect to Smart Agent
        try
            see "Code suggestions request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cJsonError = list2json(["معاملات غير صحيحة للاقتراحات"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # Extract code - handle different parameter formats
            cCode = ""
            if len(aParams) >= 1
                if type(aParams[1]) = "LIST" and len(aParams[1]) >= 1
                    cCode = aParams[1][1]  # Format: [["code"]]
                else
                    cCode = aParams[1]     # Format: ["code"]
                ok
            ok

            if cCode = "" or cCode = null
                cJsonError = list2json(["لا يوجد كود للاقتراحات"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            oResponse = oSmartAgent.processRequest("اقترح تحسينات للكود", cCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            else
                cJsonError = list2json(["خطأ في الحصول على الاقتراحات: " + oResponse["error"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
            ok
        catch
            cJsonError = list2json(["خطأ في معالجة الطلب: " + cCatchError])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # Smart Agent Functions
    # ===================================================================
    func processRequest(id, req)
        try
            see "Processing request from JavaScript: " + req + nl

            # Parse JSON parameters
            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات غير صحيحة"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cUserMessage = aParams[1]
            cCurrentCode = aParams[2]

            see "User message: " + cUserMessage + nl
            see "Current code length: " + len(cCurrentCode) + nl

            # Process request through Smart Agent
            oResponse = oSmartAgent.processRequest(cUserMessage, cCurrentCode)
            see "Agent response: " + list2code(oResponse) + nl

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "Success response sent" + nl
            else
                cErrorMsg = "خطأ: " + oResponse["error"]
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                see "Error response sent: " + cErrorMsg + nl
            ok

        catch
            see "Error processing request: " + cCatchError + nl
            cErrorMsg = "خطأ في معالجة الطلب: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getAgentStatus(id, req)
        try
            cStatus = oSmartAgent.getAgentStatus()
            cJsonResponse = list2json([cStatus])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json(["خطأ في الحصول على حالة الوكيل"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func setCurrentProject(id, req)
        try
            see "Set project request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cJsonError = list2json(["معاملات غير صحيحة لتعيين المشروع"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # Extract project name - handle different parameter formats
            cProjectName = ""
            if len(aParams) >= 1
                if type(aParams[1]) = "LIST" and len(aParams[1]) >= 1
                    cProjectName = aParams[1][1]  # Format: [["name"]]
                else
                    cProjectName = aParams[1]     # Format: ["name"]
                ok
            ok

            if cProjectName = "" or cProjectName = null
                cJsonError = list2json(["اسم المشروع فارغ"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            oSmartAgent.setCurrentProject(cProjectName)
            cCurrentProject = cProjectName
            cJsonResponse = list2json(["تم تعيين المشروع: " + cProjectName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json(["خطأ في تعيين المشروع: " + cCatchError])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func setCurrentFile(id, req)
        try
            see "Set file request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cJsonError = list2json(["معاملات غير صحيحة لتعيين الملف"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # Extract file name - handle different parameter formats
            cFileName = ""
            if len(aParams) >= 1
                if type(aParams[1]) = "LIST" and len(aParams[1]) >= 1
                    cFileName = aParams[1][1]  # Format: [["name"]]
                else
                    cFileName = aParams[1]     # Format: ["name"]
                ok
            ok

            if cFileName = "" or cFileName = null
                cJsonError = list2json(["اسم الملف فارغ"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            oSmartAgent.setCurrentFile(cFileName)
            cJsonResponse = list2json(["تم تعيين الملف: " + cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json(["خطأ في تعيين الملف: " + cCatchError])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # AI Chat Handler (Enhanced with Smart Agent)
    # ===================================================================
    func chatWithAI(id, req)
        try
            see "Chat request from JavaScript: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات الدردشة غير صحيحة"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cMessage = aParams[1]
            cCurrentCode = aParams[2]

            see "Chat message: " + cMessage + nl

            # Use Smart Agent for chat
            oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "Chat response sent successfully" + nl
            else
                cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                see "Chat error response sent: " + cErrorMsg + nl
            ok

        catch
            see "Error in AI chat: " + cCatchError + nl
            cErrorMsg = "خطأ في المحادثة: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # Send AI Request (Alias for chatWithAI for compatibility)
    # ===================================================================
    func sendAIRequest(id, req)
        try
            see "AI request from JavaScript: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات الطلب غير صحيحة"
                cResult = ["error": cErrorMsg]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                return
            ok

            cMessage = aParams[1]
            cCurrentCode = aParams[2]

            see "AI message: " + cMessage + nl

            # Use Smart Agent for AI request
            oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

            if oResponse["success"]
                cResult = ["response": oResponse["message"]]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "AI response sent successfully" + nl
            else
                cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                cResult = ["error": cErrorMsg]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "AI error response sent: " + cErrorMsg + nl
            ok

        catch
            see "Error in AI request: " + cCatchError + nl
            cErrorMsg = "خطأ في طلب الذكاء الاصطناعي: " + cCatchError
            cResult = ["error": cErrorMsg]
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        done

    # ===================================================================
    # Additional Functions for New Interface
    # ===================================================================
    func openFile(id, req)
        try
            see "Open file request: " + req + nl
            # Use file manager to open file
            cResult = oFileManager.openFile()
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في فتح الملف: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func createProject(id, req)
        try
            see "Create project request: " + req + nl
            aParams = json2list(req)
            if type(aParams) = "LIST" and len(aParams) > 0
                cProjectName = aParams[1]
                cResult = oFileManager.createProject(cProjectName)
            else
                cResult = ["error": "اسم المشروع مطلوب"]
            ok
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في إنشاء المشروع: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func openProject(id, req)
        try
            see "Open project request: " + req + nl
            cResult = oFileManager.openProject()
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في فتح المشروع: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func saveProject(id, req)
        try
            see "Save project request: " + req + nl
            cResult = oFileManager.saveProject()
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في حفظ المشروع: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func debugCode(id, req)
        try
            see "Debug code request: " + req + nl
            aParams = json2list(req)
            if type(aParams) = "LIST" and len(aParams) > 0
                cCode = aParams[1]
                cResult = oCodeRunner.debugCode(cCode)
            else
                cResult = ["error": "الكود مطلوب للتصحيح"]
            ok
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في تصحيح الكود: " + cCatchError
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # Test Connection Function
    func testConnection(id, req)
        see "=== Test Connection Function Called ===" + nl
        see "ID: " + id + nl
        see "Request Data: " + req + nl

        try
            # Test basic connection
            cResult = [
                "status": "success",
                "message": "✅ Ring Backend متصل بنجاح!",
                "functions_available": [
                    "createNewFile", "runCode", "sendAIRequest",
                    "getFileList", "saveFile", "loadFile",
                    "chatWithAI", "testConnection"
                ],
                "timestamp": date() + " " + time()
            ]

            cJsonResponse = list2json(cResult)
            see "Test connection response: " + cJsonResponse + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            cErrorMsg = "خطأ في اختبار الاتصال: " + cCatchError
            see "Error in testConnection: " + cErrorMsg + nl
            cJsonError = list2json(["error": cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
