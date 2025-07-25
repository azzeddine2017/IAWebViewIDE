# دليل البدء السريع - Ring AI Agent

## 🚀 البدء السريع

### 1. التحقق من التثبيت
```bash
# تحقق من وجود Ring
ring --version

# تحقق من مكتبة WebView
ring -c "load 'webview.ring'"
```

### 2. اختبار الوكيل الذكي
```bash
# اختبار بسيط
ring simple_test.ring

# اختبار شامل
ring test_agent.ring
```

### 3. تشغيل التطبيق
```bash
# تشغيل التطبيق الكامل
ring main.ring
```

## 🔧 إعداد مفاتيح API

### خطوات الإعداد:
1. احصل على مفتاح API من أحد المقدمين:
   - **Gemini**: https://makersuite.google.com/app/apikey
   - **OpenAI**: https://platform.openai.com/api-keys
   - **Claude**: https://console.anthropic.com/

2. عدل ملف `config/api_keys.json`:
```json
{
    "gemini": {
        "api_key": "YOUR_REAL_API_KEY_HERE",
        "enabled": true
    }
}
```

## 🛠️ الأدوات المتاحة

### عمليات الملفات:
- `write_file(filename, content)` - كتابة ملف
- `read_file(filename)` - قراءة ملف
- `delete_file(filename)` - حذف ملف
- `list_files(directory)` - عرض الملفات
- `create_directory(path)` - إنشاء مجلد

### عمليات الكود:
- `run_ring_code(code)` - تشغيل كود Ring
- `analyze_code(code)` - تحليل الكود
- `format_code(code)` - تنسيق الكود

### إدارة المشاريع:
- `create_project(name, type)` - إنشاء مشروع
- `analyze_project(path)` - تحليل المشروع

### عمليات Git:
- `git_init(path)` - تهيئة مستودع
- `git_status(path)` - حالة المستودع
- `git_add(path, files)` - إضافة ملفات
- `git_commit(path, message)` - حفظ التغييرات

### أوامر النظام:
- `execute_command(command)` - تنفيذ أمر
- `search_in_files(pattern, directory)` - البحث في الملفات

## 💬 أمثلة على الاستخدام

### كتابة ملف جديد:
```
المستخدم: "اكتب ملف جديد باسم calculator.ring يحتوي على دالة جمع"
الوكيل: سيقوم بإنشاء الملف مع الكود المطلوب
```

### تشغيل الكود:
```
المستخدم: "شغل هذا الكود: see 'Hello World!' + nl"
الوكيل: سيقوم بتشغيل الكود وإظهار النتيجة
```

### تحليل الكود:
```
المستخدم: "حلل هذا الكود واعطني تقريراً عن الأخطاء"
الوكيل: سيقوم بتحليل الكود وتقديم تقرير مفصل
```

### إنشاء مشروع:
```
المستخدم: "أنشئ مشروع جديد باسم MyWebApp"
الوكيل: سيقوم بإنشاء هيكل المشروع الكامل
```

## 🔍 استكشاف الأخطاء

### مشاكل شائعة:

#### 1. خطأ في تحميل المكتبات
```
الحل: تأكد من تثبيت مكتبة webview
ringpm install webview
```

#### 2. خطأ في الاتصال بـ API
```
الحل: تحقق من:
- صحة مفتاح API
- الاتصال بالإنترنت
- تفعيل المقدم في ملف التكوين
```

#### 3. خطأ في تشغيل الكود
```
الحل: تحقق من:
- صحة بناء الجملة في Ring
- وجود الملفات المطلوبة
- صلاحيات الكتابة في المجلد
```

## 📁 هيكل الملفات

```
├── main.ring                 # التطبيق الرئيسي
├── simple_test.ring         # اختبار بسيط
├── test_agent.ring          # اختبار شامل
├── src/                     # الكود المصدري
│   ├── smart_agent.ring     # الوكيل الذكي
│   ├── ai_client.ring       # عميل AI
│   ├── agent_tools.ring     # الأدوات
│   └── ...
├── config/                  # التكوين
│   ├── api_keys.json       # مفاتيح API
│   └── prompt_templates.json
└── assets/                 # الواجهة
```

## 🎯 الخطوات التالية

1. **اختبر النظام**: شغل `ring simple_test.ring`
2. **أضف مفتاح API**: عدل `config/api_keys.json`
3. **جرب الأوامر**: استخدم الأوامر المختلفة
4. **طور مشروعك**: ابدأ في إنشاء مشاريعك

## 📞 الدعم

- **الوثائق**: راجع ملفات المساعدة
- **الأمثلة**: انظر مجلد examples/
- **المجتمع**: انضم لمجتمع Ring

---

**نصيحة**: ابدأ بالاختبار البسيط ثم انتقل للميزات المتقدمة تدريجياً!
