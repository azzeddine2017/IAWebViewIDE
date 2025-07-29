# نظام ربط الطرق مع RingWebView

## المشكلة

RingWebView مصمم لاستدعاء الدوال (Functions) وليس الطرق (Methods)، حيث يتم تمرير المعاملات `(id, req)` عبر المكدس وليس من خلال تقييم كود Ring.

## الحل

تم تطوير نظام ذكي باستخدام التفكير الانعكاسي (Reflection) والبرمجة الوصفية (Meta-programming) لإنشاء دوال مُغلفة تقوم بإنشاء الكائن ثم استدعاء الطريقة.

## الملفات

- `src/webview_method_wrapper.ring` - النظام الأساسي لربط الطرق
- `test_method_wrapper.ring` - اختبارات النظام
- `example_method_usage.ring` - مثال شامل على الاستخدام

## كيفية الاستخدام

### 1. الحل الأساسي

```ring
# تحميل النظام
load "src/webview_method_wrapper.ring"

# إنشاء كائن
oMyObject = new MyClass()

# إنشاء دالة مُغلفة للطريقة
cWrapperFunc = Method(oMyObject, "myMethod")

# استخدام الدالة المُغلفة
call cWrapperFunc(id, req)
```

### 2. ربط متعدد الطرق

```ring
# إنشاء WebView
oWebView = new WebView()

# إنشاء كائن معالج
oHandler = new MyHandler(oWebView)

# تعريف قائمة الطرق
aMethodsList = [
    ["saveFile", "saveFile"],
    ["loadFile", "loadFile"],
    ["runCode", "runCode"]
]

# ربط جميع الطرق
BindObjectMethods(oWebView, oHandler, aMethodsList)
```

### 3. استخدام كلاس المُربط

```ring
# إنشاء مُربط الطرق
oMethodBinder = new WebViewMethodBinder()

# ربط طريقة واحدة
oMethodBinder.bindMethod(oWebView, "saveFile", oFileHandler, "saveFile")

# ربط طرق متعددة
oMethodBinder.bindMultipleMethods(oWebView, oFileHandler, aMethodsList)
```

## مثال كامل

```ring
# تحميل المكتبات المطلوبة
load "src/webview_method_wrapper.ring"
load "webview.ring"

# إنشاء كلاس معالج
class FileHandler
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
    
    func saveFile id, req
        see "حفظ الملف..." + nl
        aParams = json2list(req)
        cFileName = aParams[1]
        cContent = aParams[2]
        
        # منطق حفظ الملف هنا...
        
        cResponse = list2json(["success": "تم حفظ الملف"])
        oWebView.wreturn(id, WEBVIEW_ERROR_OK, cResponse)
    
    func loadFile id, req
        see "تحميل الملف..." + nl
        # منطق تحميل الملف هنا...

# التطبيق الرئيسي
class MyApp
    func start()
        oWebView = new WebView()
        oFileHandler = new FileHandler(oWebView)
        
        oWebView {
            setTitle("My Ring App")
            setSize(800, 600, WEBVIEW_HINT_NONE)
            
            # ربط الطرق
            aMethodsList = [
                ["saveFile", "saveFile"],
                ["loadFile", "loadFile"]
            ]
            BindObjectMethods(this, oFileHandler, aMethodsList)
            
            # تحميل HTML
            setHtml("<html>...</html>")
            
            # بدء التطبيق
            run()
        }

# تشغيل التطبيق
oApp = new MyApp()
oApp.start()
```

## المزايا

1. **فصل الاهتمامات**: كل معالج في كلاس منفصل
2. **إعادة الاستخدام**: يمكن استخدام نفس المعالج في تطبيقات مختلفة
3. **سهولة الصيانة**: الكود منظم ومقسم بشكل منطقي
4. **المرونة**: يمكن إضافة طرق جديدة بسهولة
5. **الأمان**: كل كائن محفوظ بشكل آمن في المصفوفة

## الاختبار

لتشغيل الاختبارات:

```bash
ring test_method_wrapper.ring
```

لتشغيل المثال الشامل:

```bash
ring example_method_usage.ring
```

## الدوال المتاحة

### دوال أساسية

- `Method(oObj, cMethodName)` - إنشاء دالة مُغلفة لطريقة
- `BindObjectMethods(oWebView, oObject, aMethodsList)` - ربط طرق متعددة

### كلاسات مساعدة

- `WebViewMethodBinder` - كلاس لإدارة ربط الطرق
- `FileHandler` - معالج عمليات الملفات
- `AIHandler` - معالج الذكاء الاصطناعي
- `ProjectHandler` - معالج المشاريع
- `CodeHandler` - معالج الكود

## ملاحظات مهمة

1. تأكد من تمرير مرجع WebView للمعالجات
2. استخدم `json2list()` و `list2json()` لمعالجة البيانات
3. استخدم `wreturn()` لإرجاع النتائج إلى JavaScript
4. تعامل مع الأخطاء باستخدام `try/catch`

## التطوير المستقبلي

- إضافة دعم للمعاملات الاختيارية
- تحسين معالجة الأخطاء
- إضافة نظام تسجيل متقدم
- دعم التحقق من صحة المعاملات
