# ===================================================================
# Ring AI Agent - Setup Script
# ===================================================================

func main()
    see "=== إعداد Ring AI Agent ===" + nl + nl
    
    # التحقق من متطلبات النظام
    checkRequirements()
    
    # إنشاء المجلدات المطلوبة
    createDirectories()
    
    # التحقق من ملفات التكوين
    checkConfigFiles()
    
    # اختبار النظام
    testSystem()
    
    see nl + "=== تم الإعداد بنجاح! ===" + nl
    see "يمكنك الآن تشغيل: ring main.ring" + nl
    # تشغيل الإعداد

    showNextSteps()

func checkRequirements()
    see "🔍 التحقق من المتطلبات..." + nl
    
    # التحقق من Ring
    try
        see "✓ Ring Programming Language متوفر" + nl
    catch
        see "✗ خطأ: Ring غير مثبت" + nl
        return false
    done
    
    # التحقق من WebView
    try
        load "webview.ring"
        see "✓ مكتبة WebView متوفرة" + nl
    catch
        see "⚠️  تحذير: مكتبة WebView غير متوفرة" + nl
        see "   قم بتثبيتها: ringpm install webview" + nl
    done
    
    return true

func createDirectories()
    see "📁 إنشاء المجلدات..." + nl
    
    aDirs = ["config", "assets", "assets/css", "assets/js", "src", "files", "logs"]
    
    for cDir in aDirs
        if not isdir(cDir)
            try
                system("mkdir " + cDir)
                see "✓ تم إنشاء مجلد: " + cDir + nl
            catch
                see "✗ فشل في إنشاء مجلد: " + cDir + nl
            done
        else
            see "✓ مجلد موجود: " + cDir + nl
        ok
    next

func checkConfigFiles()
    see "⚙️  التحقق من ملفات التكوين..." + nl
    
    # التحقق من api_keys.json
    if not isfile("config/api_keys.json")
        see "⚠️  إنشاء ملف api_keys.json افتراضي..." + nl
        createDefaultApiConfig()
    else
        see "✓ ملف api_keys.json موجود" + nl
    ok
    
    # التحقق من prompt_templates.json
    if not isfile("config/prompt_templates.json")
        see "⚠️  إنشاء ملف prompt_templates.json افتراضي..." + nl
        createDefaultPromptTemplates()
    else
        see "✓ ملف prompt_templates.json موجود" + nl
    ok

func createDefaultApiConfig()
    cConfig = '{
    "gemini": {
        "api_key": "YOUR_GEMINI_API_KEY_HERE",
        "base_url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent",
        "model": "gemini-pro",
        "enabled": false
    },
    "openai": {
        "api_key": "YOUR_OPENAI_API_KEY_HERE",
        "base_url": "https://api.openai.com/v1/chat/completions",
        "model": "gpt-3.5-turbo",
        "enabled": false
    },
    "claude": {
        "api_key": "YOUR_CLAUDE_API_KEY_HERE",
        "base_url": "https://api.anthropic.com/v1/messages",
        "model": "claude-3-sonnet-20240229",
        "enabled": false
    },
    "default_provider": "gemini",
    "demo_mode": true,
    "max_tokens": 4000,
    "temperature": 0.7,
    "timeout": 30
}'
    
    try
        write("config/api_keys.json", cConfig)
        see "✓ تم إنشاء ملف api_keys.json" + nl
    catch
        see "✗ فشل في إنشاء ملف api_keys.json" + nl
    done

func createDefaultPromptTemplates()
    cTemplates = '{
    "system_prompts": {
        "general_chat": "أنت مساعد ذكي متخصص في البرمجة بلغة Ring.",
        "code_analysis": "أنت خبير في تحليل الكود البرمجي بلغة Ring.",
        "file_operation": "أنت مساعد متخصص في إدارة الملفات والمشاريع البرمجية."
    },
    "response_formats": {
        "code_suggestion": "اقتراح الكود:\\n```ring\\n{code}\\n```\\n\\nالشرح: {explanation}"
    }
}'
    
    try
        write("config/prompt_templates.json", cTemplates)
        see "✓ تم إنشاء ملف prompt_templates.json" + nl
    catch
        see "✗ فشل في إنشاء ملف prompt_templates.json" + nl
    done

func testSystem()
    see "🧪 اختبار النظام..." + nl
    
    # اختبار تحميل الملفات الأساسية
    try
        if isfile("src/agent_tools.ring")
            load "src/agent_tools.ring"
            see "✓ تم تحميل agent_tools.ring" + nl
        else
            see "⚠️  ملف agent_tools.ring غير موجود" + nl
        ok
        
        if isfile("src/smart_agent.ring")
            see "✓ ملف smart_agent.ring موجود" + nl
        else
            see "⚠️  ملف smart_agent.ring غير موجود" + nl
        ok
        
    catch
        see "⚠️  تحذير: بعض الملفات قد تحتاج إعداد إضافي" + nl
    done

func showNextSteps()
    see nl + "📋 الخطوات التالية:" + nl
    see "1. عدل ملف config/api_keys.json وأضف مفاتيح API الحقيقية" + nl
    see "2. شغل الاختبار البسيط: ring simple_test.ring" + nl
    see "3. شغل التطبيق الكامل: ring main.ring" + nl
    see "4. راجع ملف QUICK_START.md للمزيد من التفاصيل" + nl


