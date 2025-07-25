# Test file to check if webview library is working
load "webview.ring"

see "Testing WebView library..." + nl

try
    oWebView = new WebView()
    see "WebView object created successfully!" + nl

    oWebView {
        setTitle("Test WebView")
        setSize(400, 300, WEBVIEW_HINT_NONE)
        setHtml("<h1>Hello from Ring WebView!</h1><p>Test successful!</p>")
        # Don't run() here to avoid blocking
    }

    see "WebView configured successfully!" + nl
    see "You can now run the main application." + nl

catch
    see "Error: " + cCatchError + nl
    see "Make sure webview library is properly installed." + nl
done
