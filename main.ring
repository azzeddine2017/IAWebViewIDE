# ===================================================================
# Ring Programming IDE with AI Chat Assistant
# Main Application Entry Point
# ===================================================================

# Load required libraries
load "webview.ring"
load "src/app.ring"

# ===================================================================
# Main Application Function
# ===================================================================
func main()
    see "Starting Ring Programming IDE..." + nl
    
    # Create and start the application
    oApp = new RingIDE()
    oApp.start()
    
    see "Ring Programming IDE closed." + nl


