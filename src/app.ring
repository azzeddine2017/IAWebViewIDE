# ===================================================================
# Ring IDE Application Class
# ===================================================================


load "jsonlib.ring"
load "stdlib.ring"
load "smart_agent.ring"
load "ui_generator.ring"
load "file_manager.ring"
load "code_runner.ring"
load "webview_method_wrapper.ring"

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

    # معالجات الطرق الجديدة - النظام الشامل
    oHandlerManager = NULL
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

        # Initialize method binder
        oMethodBinder = new WebViewMethodBinder

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
                setSize(1300, 800, WEBVIEW_HINT_NONE)

                # إنشاء معالجات الطرق الجديدة
                # إنشاء مدير المعالجات الشامل الجديد
                oHandlerManager = new ComprehensiveHandlerManager(
                    this.oWebView,
                    this.oSmartAgent,
                    this.oFileManager,
                    this.oCodeRunner
                )

                # ربط جميع الطرق باستخدام النظام الجديد
                oHandlerManager.bindAllMethods()

                see "=== Comprehensive method-based system fully activated! ===" + nl
                see "All legacy functions have been migrated to object methods." + nl



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
    
    
    # All functions have been migrated to the new method-based system
    # ===================================================================
