# ===================================================================
# اختبار عميل HTTP البسيط
# ===================================================================

load "src/http_client.ring"

see "=== اختبار عميل HTTP البسيط ===" + nl + nl

# إنشاء عميل HTTP
oClient = new HTTPClient()

see "1. اختبار طلب GET بسيط..." + nl
oResponse = oClient.getrequest("https://httpbin.org/get", [])

see "   النتيجة: " + oResponse[:success] + nl
see "   كود الحالة: " + oResponse[:status_code] + nl
see "   طول المحتوى: " + len(oResponse[:content]) + nl
see "   المحتوى: " + substr(oResponse[:content], 1, 100) + " ..." + nl
if oResponse[:error] != ""
    see "   الخطأ: " + oResponse[:error] + nl
ok
see nl

see "2. اختبار طلب POST تجريبي (Gemini API)..." + nl
cTestData = '{"message": "test", "data": "hello world"}'
oResponse = oClient.post("https://generativelanguage.googleapis.com/test", cTestData, [])

see "   النتيجة: " + oResponse[:success] + nl
see "   كود الحالة: " + oResponse[:status_code] + nl
see "   المحتوى: " + substr(oResponse[:content], 1, 100) + " ..." + nl
if oResponse[:error] != ""
    see "   الخطأ: " + oResponse[:error] + nl
ok
see nl

see "3. اختبار طلب POST عادي..." + nl
oResponse = oClient.post("https://httpbin.org/post", cTestData, [])

see "   النتيجة: " + oResponse[:success] + nl
see "   كود الحالة: " + oResponse[:status_code] + nl
see "   طول المحتوى: " + len(oResponse[:content]) + nl
see "   المحتوى: " + substr(oResponse[:content], 1, 100) + " ..." + nl
if oResponse[:error] != ""
    see "   الخطأ: " + oResponse[:error] + nl
ok
see nl

# تنظيف
oClient.cleanup()

see "=== انتهى الاختبار ===" + nl
