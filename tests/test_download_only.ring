# اختبار دالة Download() فقط
load "internetlib.ring"

see "=== اختبار دالة Download() ===" + nl

try
    see "1. اختبار Download() مع معامل واحد..." + nl
    cResult = Download("https://httpbin.org/get")
    see "النتيجة: " + type(cResult) + nl
    if type(cResult) = "STRING"
        see "طول النتيجة: " + len(cResult) + nl
        see "أول 100 حرف: " + substr(cResult, 1, 100) + nl
    ok
catch
    see "خطأ في Download() مع معامل واحد: " + cCatchError + nl
done

see nl

try
    see "2. اختبار Download() مع معاملين..." + nl
    cResult = Download("https://httpbin.org/get", "test_file.tmp")
    see "النتيجة: " + cResult + nl
    
    if fexists("test_file.tmp")
        cContent = read("test_file.tmp")
        see "تم إنشاء الملف، طول المحتوى: " + len(cContent) + nl
        remove("test_file.tmp")
    ok
catch
    see "خطأ في Download() مع معاملين: " + cCatchError + nl
done

see nl + "=== انتهى الاختبار ===" + nl
