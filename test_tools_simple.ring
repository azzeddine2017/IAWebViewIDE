# Test Tools Simple
load "src/agent_tools.ring"

func main()
    see "=== اختبار بسيط للأدوات ===" + nl
    
    oTools = new AgentTools()
    
    see "عدد الأدوات: " + len(oTools.aAvailableTools) + nl + nl
    
    # طباعة أول 3 أدوات
    for i = 1 to 3
        if i <= len(oTools.aAvailableTools)
            oTool = oTools.aAvailableTools[i]
            see "الأداة " + i + ":" + nl
            see "  الاسم: " + oTool["name"] + nl
            see "  الوصف: " + oTool["description"] + nl
            see "  الفئة: " + oTool["category"] + nl
            see nl
        ok
    next
    
    see "=== اختبار getToolsList ===" + nl
    cList = oTools.getToolsList()
    see cList + nl
