# ===================================================================
# Test Smart Agent - Quick Test Script
# ===================================================================

load "src/smart_agent.ring"

func main()
    # تشغيل الاختبارات

   
    see "=== اختبار الوكيل الذكي ===" + nl + nl
    
    # إنشاء الوكيل الذكي
    oAgent = new SmartAgent()
    
    see "تم إنشاء الوكيل الذكي بنجاح!" + nl
    see oAgent.getAgentStatus() + nl + nl
    
    # اختبار الأدوات
    see "=== اختبار الأدوات المتاحة ===" + nl
    cToolsList = oAgent.oAgentTools.getToolsList()
    see cToolsList + nl + nl
    
    # اختبار إنشاء ملف
    see "=== اختبار إنشاء ملف ===" + nl
    oResult = oAgent.processRequest("اكتب ملف جديد باسم hello.ring مع كود بسيط", "")
    
    if oResult["success"]
        see "✓ نجح الاختبار: " + oResult["message"] + nl
    else
        see "✗ فشل الاختبار: " + oResult["error"] + nl
    ok
    
    see nl + "=== انتهى الاختبار ===" + nl

     test_tools()
func test_tools()
    see "=== اختبار الأدوات مباشرة ===" + nl
    
    load "src/agent_tools.ring"
    oTools = new AgentTools()
    
    # اختبار كتابة ملف
    aParams = ['test_output.ring', 'see \"Hello from Agent!\" + nl']
    oResult = oTools.executeTool("write_file", aParams)
    
    if oResult["success"]
        see "✓ تم إنشاء الملف: " + oResult["message"] + nl
    else
        see "✗ خطأ في إنشاء الملف: " + oResult["error"] + nl
    ok
    
    # اختبار قراءة الملف
    aParams = ["test_output.ring"]
    oResult = oTools.executeTool("read_file", aParams)
    
    if oResult["success"]
        see "✓ تم قراءة الملف: " + nl + oResult["message"] + nl
    else
        see "✗ خطأ في قراءة الملف: " + oResult["error"] + nl
    ok
    
    # اختبار تشغيل الكود
    cTestCode = 'see "Hello from Ring Agent!" + nl'
    aParams = [cTestCode]
    oResult = oTools.executeTool("run_ring_code", aParams)
    
    if oResult["success"]
        see "✓ تم تشغيل الكود: " + nl + oResult["message"] + nl
    else
        see "✗ خطأ في تشغيل الكود: " + oResult["error"] + nl
    ok


