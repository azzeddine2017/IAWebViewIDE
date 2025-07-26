# ===================================================================
# Simple Test for Agent Tools
# ===================================================================

func main()
    see "=== اختبار بسيط للأدوات ===" + nl + nl
    
    //try
        load "src/agent_tools.ring"
        see "✓ تم تحميل agent_tools.ring بنجاح" + nl
        
        oTools = new AgentTools()
        see "✓ تم إنشاء كائن AgentTools بنجاح" + nl
        
        # اختبار كتابة ملف
        aParams = ["test_hello.ring", "see 'Hello World!' + nl"]
        oResult = oTools.executeTool("write_file", aParams)
        
        if oResult["success"]
            see "✓ تم إنشاء الملف: " + oResult["message"] + nl
        else
            see "✗ خطأ في إنشاء الملف: " + oResult["error"] + nl
        ok
        
        # اختبار قراءة الملف
        aParams = ["test_hello.ring"]
        oResult = oTools.executeTool("read_file", aParams)
        
        if oResult["success"]
            see "✓ تم قراءة الملف بنجاح" + nl
        else
            see "✗ خطأ في قراءة الملف: " + oResult["error"] + nl
        ok
        
        # اختبار تشغيل الكود
        cTestCode = "see 'Hello from Ring Agent!' + nl"
        aParams = [cTestCode]
        oResult = oTools.executeTool("run_ring_code", aParams)
        
        if oResult["success"]
            see "✓ تم تشغيل الكود بنجاح" + nl
        else
            see "✗ خطأ في تشغيل الكود: " + oResult["error"] + nl
        ok
        
    /*catch
        see "✗ خطأ في الاختبار: " + cCatchError + nl
    done
    */
    see nl + "=== انتهى الاختبار ===" + nl
