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
                ["getCodeSuggestions", :getCodeSuggestions]
                ]
                
                bindMany(BindList)

                # Load the main HTML interface
                //setHtml(this.oUIGenerator.getMainHTML())

                # Navigate the webview to a local HTML file.
	            # Prepend "file://" to the absolute path for local file access.
	            navigate("file://" + currentdir() + "/assets/html/index.html")

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
        oFileManager.saveFile(id, req, this.oWebView)
    
    func loadFile(id, req)
        oFileManager.loadFile(id, req, this.oWebView)

    func createNewFile(id, req)
        see "CreateNewFile - Request Data: " + req + nl
        see "CreateNewFile - Request Type: " + type(req) + nl
        if req = NULL or len(req) = 0
            see "Warning: Empty request received in createNewFile" + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
            return
        ok
        oFileManager.createNewFile(id, req, this.oWebView)

    func deleteFile(id, req)
        see "DeleteFile - Request Data: " + req + nl
        if req = NULL or len(req) = 0
            see "Warning: Empty request received in deleteFile" + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
            return
        ok
        oFileManager.deleteFile(id, req, this.oWebView)

    func getFileList(id, req)
        see "GetFileList - Request Data: " + req + nl
        oFileManager.getFileList(id, req, this.oWebView)

    # ===================================================================
    # Code Operations - Delegate to CodeRunner
    # ===================================================================
    func runCode(id, req)
        oCodeRunner.runCode(id, req, this.oWebView)
    
    func formatCode(id, req)
        oCodeRunner.formatCode(id, req, this.oWebView)

    func analyzeCode(id, req)
        oCodeRunner.analyzeCode(id, req, this.oWebView)

    func getCodeSuggestions(id, req)
        # Legacy function - redirect to Smart Agent
        try
            aParams = json2list(req)
            cCode = aParams[1][1]
            oResponse = oSmartAgent.processRequest("اقترح تحسينات للكود", cCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            else
                cJsonError = list2json(["خطأ في الحصول على الاقتراحات"])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
            ok
        catch
            cJsonError = list2json(["خطأ في معالجة الطلب"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # Smart Agent Functions
    # ===================================================================
    func processRequest(id, req)
        try
            aParams = json2list(req)
            cUserMessage = aParams[1][1]
            cCurrentCode = aParams[1][2]

            # Process request through Smart Agent
            oResponse = oSmartAgent.processRequest(cUserMessage, cCurrentCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            else
                cErrorMsg = "خطأ: " + oResponse["error"]
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
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
            aParams = json2list(req)
            cProjectName = aParams[1][1]
            oSmartAgent.setCurrentProject(cProjectName)
            cCurrentProject = cProjectName
            cJsonResponse = list2json(["تم تعيين المشروع: " + cProjectName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json(["خطأ في تعيين المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func setCurrentFile(id, req)
        try
            aParams = json2list(req)
            cFileName = aParams[1][1]
            oSmartAgent.setCurrentFile(cFileName)
            cJsonResponse = list2json(["تم تعيين الملف: " + cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json(["خطأ في تعيين الملف"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    # ===================================================================
    # AI Chat Handler (Enhanced with Smart Agent)
    # ===================================================================
    func chatWithAI(id, req)
        try
            aParams = json2list(req)
            cMessage = aParams[1][1]
            cCurrentCode = aParams[1][2]

            # Use Smart Agent for chat
            oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            else
                cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
            ok

        catch
            see "Error in AI chat: " + cCatchError + nl
            cErrorMsg = "خطأ في المحادثة: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
