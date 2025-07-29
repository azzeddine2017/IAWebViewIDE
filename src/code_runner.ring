# ===================================================================
# Code Runner Class - Handles code execution and analysis
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"

class CodeRunner
    
    # Private properties
    cTempDirectory = "temp"
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        # Create temp directory if it doesn't exist
        if not fexists(cTempDirectory)
            system("mkdir " + cTempDirectory)
        ok
        see "CodeRunner initialized." + nl
    
    # ===================================================================
    # Run Code
    # ===================================================================
    func runCode(id, req, oWebView)
        try
            see "Running code request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cErrorMsg = "معاملات غير صحيحة لتشغيل الكود"
                cJsonError = list2json([cErrorMsg])
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
                cErrorMsg = "لا يوجد كود للتشغيل"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            see "Code to execute: " + left(cCode, 100) + "..." + nl

            # Save code to temporary file
            cTempFile = cTempDirectory + "/temp_code.ring"
            write(cTempFile, cCode)

            # Execute the code
            cCommand = "ring " + cTempFile
            cResult = systemcmd(cCommand)

            # Clean up
            if fexists(cTempFile)
                remove(cTempFile)
            ok

            # Return result
            cJsonResult = list2json([cResult])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
            see "Code executed successfully" + nl

        catch
            see "Error running code: " + cCatchError + nl
            cErrorMsg = "خطأ في تشغيل الكود: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    # ===================================================================
    # Format Code
    # ===================================================================
    func formatCode(id, req, oWebView)
        try
            see "Formatting code request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cErrorMsg = "معاملات غير صحيحة لتنسيق الكود"
                cJsonError = list2json([cErrorMsg])
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
                cErrorMsg = "لا يوجد كود للتنسيق"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # Basic code formatting for Ring
            cFormattedCode = formatRingCode(cCode)

            cJsonResult = list2json([cFormattedCode])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
            see "Code formatted successfully" + nl

        catch
            see "Error formatting code: " + cCatchError + nl
            cErrorMsg = "خطأ في تنسيق الكود: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    # ===================================================================
    # Analyze Code
    # ===================================================================
    func analyzeCode(id, req, oWebView)
        try
            see "Analyzing code request: " + req + nl

            aParams = json2list(req)
            if type(aParams) != "LIST" or len(aParams) = 0
                cErrorMsg = "معاملات غير صحيحة لتحليل الكود"
                cJsonError = list2json([cErrorMsg])
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
                cErrorMsg = "لا يوجد كود للتحليل"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # Analyze Ring code
            cAnalysis = analyzeRingCode(cCode)

            cJsonResult = list2json([cAnalysis])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
            see "Code analyzed successfully" + nl

        catch
            see "Error analyzing code: " + cCatchError + nl
            cErrorMsg = "خطأ في تحليل الكود: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    # ===================================================================
    # Get Code Suggestions
    # ===================================================================
    func getCodeSuggestions(id, req, oWebView)
        try
            aParams = json2list(req)
            cCode = aParams[1][1]
            cCursor = aParams[1][2]
            
            # Generate code suggestions
            aSuggestions = generateRingSuggestions(cCode, cCursor)
            
            cJsonResult = list2json(aSuggestions)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResult)
            
        catch
            see "Error getting suggestions: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "[]")
        done
    
    # ===================================================================
    # Format Ring Code
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
               substr(cTrimmedLine, "else") or
               substr(cTrimmedLine, "done")
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
               substr(cTrimmedLine, "else") or
               substr(cTrimmedLine, "try")
                nIndentLevel++
            ok
        next
        
        return list2str(aFormattedLines)
    
    # ===================================================================
    # Analyze Ring Code
    # ===================================================================
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
    
    # ===================================================================
    # Generate Ring Suggestions
    # ===================================================================
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
    # Utility function to count substring occurrences
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
