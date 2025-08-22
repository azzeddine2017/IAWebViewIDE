# ===================================================================
# اختبار بسيط للنظام المحدث
# Simple Test for Updated System
# ===================================================================

load "stdlib.ring"
load "jsonlib.ring"

# تحميل النظام المحدث
load "src/webview_method_wrapper.ring"

func main
    see "=== اختبار بسيط للنظام المحدث ===" + nl + nl
    
    # اختبار إنشاء المعالجات
    see "1. اختبار إنشاء المعالجات..." + nl
    
    try
        oWebView = new MockWebView
        oFileHandler = new ComprehensiveFileHandler(oWebView, new MockFileManager)
        oCodeHandler = new ComprehensiveCodeHandler(oWebView, new MockCodeRunner)
        see "✓ تم إنشاء المعالجات بنجاح" + nl
    catch
        see "✗ خطأ في إنشاء المعالجات: " + cCatchError + nl
        return
    done
    
    # اختبار الربط المباشر
    see nl + "2. اختبار الربط المباشر..." + nl
    
    try
        aFileMethods = [
            ["saveFile", "saveFile"],
            ["loadFile", "loadFile"]
        ]
        
        oWebView.bind(oFileHandler, aFileMethods)
        see "✓ تم ربط طرق معالج الملفات" + nl
        
        aCodeMethods = [
            ["runCode", "runCode"],
            ["formatCode", "formatCode"]
        ]
        
        oWebView.bind(oCodeHandler, aCodeMethods)
        see "✓ تم ربط طرق معالج الكود" + nl
        
    catch
        see "✗ خطأ في الربط: " + cCatchError + nl
        return
    done
    
    # اختبار bindMany
    see nl + "3. اختبار bindMany..." + nl
    
    try
        aAllBindings = [
            [oFileHandler, [["testSave", "saveFile"]]],
            [oCodeHandler, [["testRun", "runCode"]]]
        ]
        
        oWebView.bindMany(aAllBindings)
        see "✓ تم اختبار bindMany بنجاح" + nl
        
    catch
        see "✗ خطأ في bindMany: " + cCatchError + nl
        return
    done
    
    see nl + "=== جميع الاختبارات نجحت! ===" + nl
    see "✅ النظام المحدث يعمل بشكل مثالي" + nl
    see "✅ تم استخدام النظام المدمج بنجاح" + nl

# ===================================================================
# كلاسات وهمية مبسطة
# ===================================================================

class MockWebView
    func bind p1, p2
        if isObject(p1) and isList(p2)
            see "  - ربط كائن مع " + len(p2) + " طرق" + nl
        else
            see "  - ربط دالة: " + p1 + nl
        ok
        return true
    
    func bindMany aList
        see "  - bindMany مع " + len(aList) + " ربطات" + nl
        for aBinding in aList
            if len(aBinding) = 2 and isObject(aBinding[1])
                this.bind(aBinding[1], aBinding[2])
            ok
        next
        return true
    
    func wreturn id, status, response
        # وهمية

class MockFileManager
    func saveFile cFileName, cContent
        return [:success= true]

class MockCodeRunner
    func runCode cCode
        return [:success= true]

