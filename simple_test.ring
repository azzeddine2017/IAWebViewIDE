load "src/agent_tools.ring"
# Simple Test for Agent Tools
see "=== اختبار بسيط للوكيل الذكي ===" + nl

# Test basic functionality
//try
    
    see "✓ تم تحميل agent_tools.ring بنجاح" + nl
    
    oTools = new AgentTools()
    see "✓ تم إنشاء كائن AgentTools بنجاح" + nl
    
    # Test write file
    oResult = oTools.executeTool("write_file", ["test_hello.ring", 'see \"Hello World!\" + nl'])
    if oResult["success"]
        see "✓ تم إنشاء ملف الاختبار بنجاح" + nl
    else
        see "✗ فشل في إنشاء الملف: " + oResult["error"] + nl
    ok
    
    # Test read file
    oResult = oTools.executeTool("read_file", ["test_hello.ring"])
    if oResult["success"]
        see "✓ تم قراءة الملف بنجاح: " + oResult["message"] + nl
    else
        see "✗ فشل في قراءة الملف: " + oResult["error"] + nl
    ok
    
/*catch
    see "✗ خطأ في الاختبار: " + cCatchError + nl
done*/

see "=== انتهى الاختبار ===" + nl
