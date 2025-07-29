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


# Method Binding System with RingWebView

## The Problem

RingWebView is designed to call functions, not methods. The parameters (id, req) are passed through the stack, not through the evaluation of the Ring code.

## The Solution

An intelligent system was developed using reflection and meta-programming to create wrapper functions that create the object and then call the method.

## Files

- `src/webview_method_wrapper.ring` - Method binding platform
- `test_method_wrapper.ring` - System tests
- `example_method_usage.ring` - Comprehensive usage example

## How to Use

### 1. Basic Solution

```ring
# Load the system
load "src/webview_method_wrapper.ring"

# Create an object
oMyObject = new MyClass()

# Create a wrapper function for the method
cWrapperFunc = Method(oMyObject, "myMethod")

# Use the wrapper function
call cWrapperFunc(id, req)
```

### 2. Multi-Method Binding

```ring
# Create a WebView
oWebView = new WebView()

# Create a Handler object
oHandler = new MyHandler(oWebView)

# Define a list of methods
aMethodsList = [
["saveFile", "saveFile"],
["loadFile", "loadFile"],
["runCode", "runCode"]
]

# Bind all methods
BindObjectMethods(oWebView, oHandler, aMethodsList)
```

### 3. Using the Binder class

```ring
# Create a method binder
oMethodBinder = new WebViewMethodBinder()

# Bind a single method
oMethodBinder.bindMethod(oWebView, "saveFile", oFileHandler, "saveFile")

# Bind multiple methods
oMethodBinder.bindMultipleMethods(oWebView, oFileHandler, aMethodsList)
```

## Full Example

```ring
# Load Required Libraries
load "src/webview_method_wrapper.ring"
load "webview.ring"

# Create a Handler Class
class FileHandler
oWebView = NULL

func init oWebViewRef
oWebView = oWebViewRef

func saveFile id, req
see "Save File..." + nl
aParams = json2list(req)
cFileName = aParams[1]
cContent = aParams[2]

# Logic for saving the file here...

cResponse = list2json(["success": "File saved"])
oWebView.wreturn(id, WEBVIEW_ERROR_OK, cResponse)

func loadFile id, req
see "Uploading the file..." + nl
# File upload logic here...

# Main application
class MyApp
func start()
oWebView = new WebView()
oFileHandler = new FileHandler(oWebView)

oWebView {
setTitle("My Ring App")
setSize(800, 600, WEBVIEW_HINT_NONE)

# Binding methods
aMethodsList = [
["saveFile", "saveFile"],
["loadFile", "loadFile"]
]
BindObjectMethods(this, oFileHandler, aMethodsList)

# Load HTML
setHtml("<html>...</html>")

# Start the application
run()
}

# Run the application
oApp = new MyApp()
oApp.start()
```

## Advantages

1. **Separation of Concerns**: Each handler is in a separate class.
2. **Reusability**: The same handler can be used in different applications.
3. **Ease of Maintenance**: The code is organized and logically divided.
4. **Flexibility**: New methods can be easily added.
5. **Security**: Each object is securely stored in an array.

## Testing

To run tests:

```bash
ring test_method_wrapper.ring
```

To run the full example:

```bash
ring example_method_usage.ring
```

## Available Functions

### Basic Functions

- `Method(oObj, cMethodName)` - Create a wrapper function for a method
- `BindObjectMethods(oWebView, oObject, aMethodsList)` - Bind multiple methods

### Helper Classes

- `WebViewMethodBinder` - A class to manage method bindings
- FileHandler - File Process Handler
- AIHandler - Artificial Intelligence Handler
- ProjectHandler - Project Handler
- CodeHandler - Code Handler

## Important Notes

1. Ensure that the WebView reference is passed to the handlers.
2. Use json2list() and list2json() to process data.
3. Use wreturn() to return results to JavaScript.
4. Handle errors using try/catch.

## Future Development

- Add support for optional parameters.
- Improve error handling.
- Add advanced logging.
- Support for transaction validation.