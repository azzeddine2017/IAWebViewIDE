# ===================================================================
# Basic Test for Agent Tools
# ===================================================================

func main()
    see "=== اختبار أساسي للأدوات ===" + nl + nl
    
    try
        load "src/agent_tools.ring"
        see "✓ تم تحميل agent_tools.ring بنجاح" + nl
        
        oTools = new AgentTools()
        see "✓ تم إنشاء كائن AgentTools بنجاح" + nl
        
        # اختبار مباشر لدالة writeFile
        see "=== اختبار كتابة الملف مباشرة ===" + nl
        oResult = oTools.writeFile("test_basic.txt", "Hello World!")
        
        see "النتيجة: " + nl
        see "Success: " + oResult["success"] + nl
        see "Message: " + oResult["message"] + nl
        see "Error: " + oResult["error"] + nl + nl
        
        # اختبار مباشر لدالة readFile
        see "=== اختبار قراءة الملف مباشرة ===" + nl
        oResult = oTools.readFile("test_basic.txt")
        
        see "النتيجة: " + nl
        see "Success: " + oResult["success"] + nl
        see "Message: " + oResult["message"] + nl
        see "Error: " + oResult["error"] + nl + nl
        
        # اختبار executeTool
        see "=== اختبار executeTool ===" + nl
        aParams = ["test_via_tool.txt", "Hello via Tool!"]
        oResult = oTools.executeTool("write_file", aParams)
        
        see "النتيجة: " + nl
        see "Success: " + oResult["success"] + nl
        see "Message: " + oResult["message"] + nl
        see "Error: " + oResult["error"] + nl + nl
        
    catch
        see "✗ خطأ في الاختبار: " + cCatchError + nl
    done
    
    see "=== انتهى الاختبار ===" + nl


