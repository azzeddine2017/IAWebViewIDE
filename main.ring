# ===================================================================
# Ring Programming IDE with AI Chat Assistant
# Main Application Entry Point
# ===================================================================

# Load required libraries
load "webview.ring"
load "stdlib.ring"
# تحميل التطبيق الرئيسي
load "src/app.ring"

# ===================================================================
# Main Application Function
# ===================================================================
func main()
    see "Starting Ring Programming IDE..." + nl
    
    # Create and start the application
    oApp = new RingIDE()
    oApp.start() # ثم بدء التطبيق
    
    see "Ring Programming IDE closed." + nl


