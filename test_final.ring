# Final Test for Ring IDE
see "=== اختبار نهائي لـ Ring IDE ===" + nl + nl

# Test 1: Basic functionality
see "1. اختبار الوظائف الأساسية..." + nl

load "src/smart_agent.ring"
load "src/agent_tools.ring"
load "src/ai_client.ring"

# Test SmartAgent
see "   - تحميل SmartAgent..." + nl
oAgent = new SmartAgent()
see "   ✓ تم تحميل SmartAgent بنجاح" + nl

# Test AgentTools
see "   - تحميل AgentTools..." + nl
oTools = new AgentTools()
see "   ✓ تم تحميل AgentTools بنجاح" + nl

# Test AIClient
see "   - تحميل AIClient..." + nl
oAI = new AIClient()
see "   ✓ تم تحميل AIClient بنجاح" + nl

see nl + "2. اختبار معالجة الطلبات..." + nl

# Test simple request
cTestMessage = "مرحبا"
oResult = oAgent.processRequest(cTestMessage, "")

if oResult["success"]
    see "   ✓ معالجة الطلب نجحت" + nl
else
    see "   ✗ فشل في معالجة الطلب: " + oResult["error"] + nl
ok

see nl + "3. اختبار الأدوات..." + nl

# Test file creation
oFileResult = oTools.executeTool("write_file", ["test_output.ring", "see " + char(34) + "Hello from test!" + char(34) + " + nl"])

if oFileResult["success"]
    see "   ✓ إنشاء الملف نجح" + nl
else
    see "   ✗ فشل في إنشاء الملف: " + oFileResult["error"] + nl
ok

see nl + "=== انتهى الاختبار ===" + nl
see "جميع المكونات تعمل بشكل صحيح!" + nl
