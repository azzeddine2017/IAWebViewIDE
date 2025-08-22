# ===================================================================
# اختبار عميل HTTP بسيط
# Simple HTTP Client Test
# ===================================================================

load "internetlib.ring"
load "jsonlib.ring"

func main
    see "=== اختبار عميل HTTP بسيط ===" + nl + nl
    
    # اختبار طلب GET بسيط
    see "1. اختبار طلب GET..." + nl
    testSimpleGet()
    
    see nl + "2. اختبار طلب POST..." + nl
    testSimplePost()
    
    see nl + "=== انتهى الاختبار ===" + nl

func testSimpleGet()
    try
        see "إرسال طلب GET إلى httpbin.org..." + nl
        cResponse = download("https://httpbin.org/get")
        
        if len(cResponse) > 0
            see "✓ تم استلام الرد: " + len(cResponse) + " حرف" + nl
            see "معاينة الرد: " + left(cResponse, 100) + "..." + nl
        else
            see "✗ لم يتم استلام رد" + nl
        ok
        
    catch
        see "✗ خطأ في طلب GET: " + cCatchError + nl
    done

func testSimplePost()
    try
        see "إرسال طلب POST إلى httpbin.org..." + nl
        
        # بيانات اختبار
        cTestData = '{"message": "Hello from Ring!", "test": true}'
        
        # محاولة استخدام download مع POST
        # ملاحظة: قد لا تعمل هذه الطريقة في جميع إصدارات Ring
        cResponse = download("https://httpbin.org/post", cTestData)
        
        if len(cResponse) > 0
            see "✓ تم استلام الرد: " + len(cResponse) + " حرف" + nl
            see "معاينة الرد: " + left(cResponse, 100) + "..." + nl
        else
            see "✗ لم يتم استلام رد" + nl
        ok
        
    catch
        see "✗ خطأ في طلب POST: " + cCatchError + nl
        see "ملاحظة: قد تحتاج لاستخدام مكتبة HTTP أخرى" + nl
    done
