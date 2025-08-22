# ===================================================================
# اختبار عميل الذكاء الاصطناعي
# Test AI Client
# ===================================================================

load "src/ai_client.ring"

func main
    see "=== اختبار عميل الذكاء الاصطناعي ===" + nl + nl
    
    # إنشاء عميل الذكاء الاصطناعي
    see "إنشاء عميل الذكاء الاصطناعي..." + nl
    oAIClient = new AIClient()
    ? "Gemini API Key: " + oAIClient.cGeminiAPIKey + nl
    see "مقدم الخدمة الحالي: " + oAIClient.cCurrentProvider + nl
    see "مفتاح Gemini: " + left(oAIClient.cGeminiAPIKey, 10) + "..." + nl + nl
    
    # اختبار طلب بسيط
    see "إرسال طلب اختبار..." + nl
    cMessage = "مرحباً، كيف حالك؟"
    cSystemPrompt = "أنت مساعد ذكي ودود."
    aContext = []
    
    oResult = oAIClient.sendChatRequest(cMessage, cSystemPrompt, aContext)
    ? oResult
    see "نتيجة الطلب:" + nl
    if oResult["success"]
        see "✓ نجح الطلب!" + nl
        see "الرد: " + oResult["message"] + nl
    else
        see "✗ فشل الطلب!" + nl
        see "الخطأ: " + oResult["error"] + nl
    ok
    
    see nl + "=== انتهى الاختبار ===" + nl

