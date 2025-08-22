# ===================================================================
# اختبار التطبيق الرئيسي المبسط
# Simple Main Application Test
# ===================================================================

load "webview.ring"
load "stdlib.ring"
load "jsonlib.ring"

func main()
    see "Starting Simple Ring IDE Test..." + nl
    
    try
        # Create webview instance
        oWebView = new WebView()
        
        # Configure webview
        oWebView {
            setTitle("Ring IDE - Simple Test")
            setSize(1200, 800, WEBVIEW_HINT_NONE)

            # Create simple handlers
            oFileHandler = new SimpleFileHandler(oWebView)
            oCodeHandler = new SimpleCodeHandler(oWebView)
            oSystemHandler = new SimpleSystemHandler(oWebView)

            # Bind methods directly
            see "Binding file methods..." + nl
            bind(oFileHandler, [
                ["createNewFile", "createNewFile"],
                ["saveFile", "saveFile"],
                ["loadFile", "loadFile"],
                ["deleteFile", "deleteFile"]
            ])

            see "Binding code methods..." + nl
            bind(oCodeHandler, [
                ["runCode", "runCode"],
                ["formatCode", "formatCode"]
            ])

            see "Binding system methods..." + nl
            bind(oSystemHandler, [
                ["testConnection", "testConnection"]
            ])

            see "All methods bound successfully!" + nl

            # Load the HTML interface
            cHtmlPath = "file://" + currentdir() + "/assets/html/new_index.html"
            see "Loading HTML interface: " + cHtmlPath + nl
            navigate(cHtmlPath)
            
            # Start the application
            see "Starting application..." + nl
            run()
        }
        
    catch
        see "Error starting application: " + cCatchError + nl
    done

# Simple File Handler
class SimpleFileHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
        see "SimpleFileHandler initialized" + nl
    
    func createNewFile id, req
        see "=== createNewFile called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            
            # Simulate file creation
            cResponse = list2json([
                :success= true,
                :message= "تم إنشاء الملف بنجاح: " + cFileName,
                :filename= cFileName
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ File creation response sent" + nl
            
        catch
            cError = list2json([:error= "خطأ في إنشاء الملف: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ Error in createNewFile: " + cCatchError + nl
        done
    
    func saveFile id, req
        see "=== saveFile called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cContent = ""
            if len(aParams) > 1
                cContent = aParams[2]
            ok
            
            cResponse = list2json([
                :success= true,
                :message= "تم حفظ الملف بنجاح: " + cFileName,
                :filename= cFileName
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ File save response sent" + nl
            
        catch
            cError = list2json([:error= "خطأ في حفظ الملف: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ Error in saveFile: " + cCatchError + nl
        done
    
    func loadFile id, req
        see "=== loadFile called ===" + nl
        try
            cSampleCode = "# مثال على كود Ring" + nl + "see " + char(34) + "Hello World!" + char(34) + " + nl"
            cResponse = list2json([
                :success= true,
                :content= cSampleCode,
                :filename= "example.ring"
            ])
            oWebView.wreturn(id, 0, cResponse)
        catch
            cError = list2json([:error= "خطأ في تحميل الملف"])
            oWebView.wreturn(id, 0, cError)
        done
    
    func deleteFile id, req
        see "=== deleteFile called ===" + nl
        try
            cResponse = list2json([:success= true, :message= "تم حذف الملف"])
            oWebView.wreturn(id, 0, cResponse)
        catch
            cError = list2json([:error= "خطأ في حذف الملف"])
            oWebView.wreturn(id, 0, cError)
        done

# Simple Code Handler
class SimpleCodeHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
        see "SimpleCodeHandler initialized" + nl
    
    func runCode id, req
        see "=== runCode called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            aParams = json2list(req)
            cCode = aParams[1]
            
            cResponse = list2json([
                :success= true,
                :output= "Hello World from Ring!\nCode executed successfully!",
                :code= cCode
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ Code execution response sent" + nl
            
        catch
            cError = list2json([:error= "خطأ في تشغيل الكود: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ Error in runCode: " + cCatchError + nl
        done
    
    func formatCode id, req
        see "=== formatCode called ===" + nl
        try
            cFormattedCode = "# Formatted Ring Code" + nl + "see " + char(34) + "Hello World!" + char(34) + " + nl"
            cResponse = list2json([
                :success= true,
                :formatted_code= cFormattedCode
            ])
            oWebView.wreturn(id, 0, cResponse)
        catch
            cError = list2json([:error= "خطأ في تنسيق الكود"])
            oWebView.wreturn(id, 0, cError)
        done

# Simple System Handler
class SimpleSystemHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
        see "SimpleSystemHandler initialized" + nl
    
    func testConnection id, req
        see "=== testConnection called ===" + nl
        see "ID: " + id + ", Request: " + req + nl
        
        try
            cResponse = list2json([
                :success= true,
                :message= "الاتصال يعمل بشكل مثالي!",
                :timestamp= date() + " " + time(),
                :version= "Ring WebView v1.0"
            ])
            
            oWebView.wreturn(id, 0, cResponse)
            see "✓ Connection test response sent" + nl
            
        catch
            cError = list2json([:error= "خطأ في اختبار الاتصال: " + cCatchError])
            oWebView.wreturn(id, 0, cError)
            see "✗ Error in testConnection: " + cCatchError + nl
        done
