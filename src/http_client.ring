/*
==============================================================================
    وحدة عميل HTTP -  HTTP Client
    
    الوصف: عميل HTTP متقدم باستخدام libcurl.ring مع دعم الجلسات والكوكيز
    المؤلف:  Team
==============================================================================
*/

load "libcurl.ring"
# إنشاء مثيل عام من عميل HTTP
//oHTTPClient = new HTTPClient()

/*==============================================================================
    كلاس عميل HTTP
==============================================================================
*/

class HTTPClient

    # خصائص العميل
    curl = NULL
    bVerbose = false
    
    # إعدادات افتراضية
    cUserAgent = "-HTTPClient/1.0"
    nTimeout = 30
    bFollowRedirects = true
    bVerifySSL = false
    cCookieFile = "_cookies.txt"
    
    # رؤوس افتراضية
    aDefaultHeaders = [
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language: en-US,en;q=0.5",
        "Accept-Encoding: gzip, deflate",
        "Connection: keep-alive",
        "Upgrade-Insecure-Requests: 1"
    ]
    
    /*
    دالة البناء
    */
    func init
        initializeCurl()
        ?  "[ debug ] " + "تم تهيئة عميل HTTP"
    
    /*
    تهيئة libcurl
    */
    func initializeCurl
        curl = curl_easy_init()
        if curl = NULL
            ?  "[ error] " + "فشل في تهيئة libcurl"
            return
        ok
        
        # إعدادات أساسية
        curl_easy_setopt(curl, CURLOPT_USERAGENT, cUserAgent)
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, nTimeout)
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1)
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0)
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0)
        curl_easy_setopt(curl, CURLOPT_COOKIEJAR, cCookieFile)
        curl_easy_setopt(curl, CURLOPT_COOKIEFILE, cCookieFile)
    
    /*
    تنظيف الموارد
    */
    func cleanup
        if curl != NULL
            curl_easy_cleanup(curl)
            curl = NULL
        ok
    
    /*
    تعيين User Agent
    المدخلات: cAgent - نص User Agent
    */
    func setUserAgent cAgent
        cUserAgent = cAgent
        if curl != NULL
            curl_easy_setopt(curl, CURLOPT_USERAGENT, cUserAgent)
        ok
        ?  "[ debug ] " + "تم تعيين User Agent إلى: " + cUserAgent
    
    /*
    تعيين مهلة الاتصال
    المدخلات: nSeconds - المهلة بالثواني
    */
    func setTimeout nSeconds
        nTimeout = nSeconds
        if curl != NULL
            curl_easy_setopt(curl, CURLOPT_TIMEOUT, nTimeout)
        ok
        ?  "[ debug ] " + "تم تعيين مهلة الاتصال إلى " + nTimeout + " ثانية"
    
    /*
    تفعيل/إلغاء تتبع إعادة التوجيه
    المدخلات: bEnable - true للتفعيل، false للإلغاء
    */
    func setFollowRedirects bEnable
        bFollowRedirects = bEnable
        if curl != NULL
            nValue = iif(bEnable, 1, 0)
            curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, nValue)
        ok
        cStatus = iif(bEnable, "مفعل", "معطل")
        ?  "[ debug ] " + "تتبع إعادة التوجيه: " + cStatus
    
    /*
    تفعيل/إلغاء التحقق من شهادات SSL
    المدخلات: bEnable - true للتفعيل، false للإلغاء
    */
    func setVerifySSL bEnable
        bVerifySSL = bEnable
        if curl != NULL
            nPeerValue = iif(bEnable, 1, 0)
            nHostValue = iif(bEnable, 2, 0)
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, nPeerValue)
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, nHostValue)
        ok
        cStatus = iif(bEnable, "مفعل", "معطل")
        ?  "[ debug ] " + "التحقق من SSL: " + cStatus
    
    /*
    تعيين ملف الكوكيز
    المدخلات: cFile - مسار ملف الكوكيز
    */
    func setCookieFile cFile
        cCookieFile = cFile
        if curl != NULL
            curl_easy_setopt(curl, CURLOPT_COOKIEJAR, cCookieFile)
            curl_easy_setopt(curl, CURLOPT_COOKIEFILE, cCookieFile)
        ok
        ?  "[ debug ] " + "تم تعيين ملف الكوكيز إلى: " + cCookieFile
    
    /*
    تفعيل/إلغاء الوضع المفصل
    المدخلات: bEnable - true للتفعيل، false للإلغاء
    */
    func setVerbose bEnable
        bVerbose = bEnable
        if curl != NULL
            nValue = iif(bEnable, 1, 0)
            curl_easy_setopt(curl, CURLOPT_VERBOSE, nValue)
        ok
    
    /*
    إعداد الرؤوس المخصصة
    المدخلات: aHeaders - قائمة الرؤوس
    */
    func setHeaders aHeaders
        if curl = NULL
            return
        ok
        
        # إنشاء قائمة الرؤوس
        headerList = NULL
        for cHeader in aHeaders
            headerList = curl_slist_append(headerList, cHeader)
        next
        
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerList)
        
        if bVerbose
            ?  "[ debug ] " + "تم تعيين " + len(aHeaders) + " رأس مخصص"
        ok
    
    /*
    إرسال طلب HTTP
    المدخلات: cMethod - نوع الطلب، cURL - الرابط، aHeaders - الرؤوس، cData - البيانات
    المخرجات: كائن يحتوي على الاستجابة
    */
    func request cMethod, URL, aHeaders, cData
        if curl = NULL
            return createErrorResponse("عميل HTTP غير مهيأ")
        ok
        
        ?  "[ info ] " + "إرسال طلب " + cMethod + " إلى: " + URL
        
        # تعيين الرابط
        curl_easy_setopt(curl, CURLOPT_URL, URL)
        
        # تعيين نوع الطلب
        switch upper(cMethod)
            on "GET"
                curl_easy_setopt(curl, CURLOPT_HTTPGET, 1)
            on "POST"
                curl_easy_setopt(curl, CURLOPT_POST, 1)
                if cData != NULL and len(cData) > 0
                    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, cData)
                ok
            on "PUT"
                curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "PUT")
                if cData != NULL and len(cData) > 0
                    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, cData)
                ok
            on "DELETE"
                curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE")
            on "HEAD"
                curl_easy_setopt(curl, CURLOPT_NOBODY, 1)
            other
                curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, cMethod)
        off
        
        # تعيين الرؤوس
        if aHeaders != NULL and len(aHeaders) > 0
            setHeaders(aHeaders)
        else
            setHeaders(aDefaultHeaders)
        ok
        
        # إرسال الطلب والحصول على الاستجابة
        try
            cResponse = curl_easy_perform_silent(curl)
            //? cResponse
            # الحصول على معلومات الاستجابة
            nResponseCode = curl_getResponseCode(curl)
           // cContentType = curl_getContentType(curl)
            nContentLength = curl_getContentLength(curl)
           // cEffectiveURL = curl_getEffectiveUrl(curl)
            
            ?  "[ info ] " + "تم استلام الاستجابة - كود: " + nResponseCode + 
                        ", الحجم: " + (nContentLength) + " بايت"
            
            # إنشاء كائن الاستجابة
            return createResponse(nResponseCode, cResponse, nContentLength)
            
        catch
            ?  "[ error] " + "خطأ في إرسال الطلب: " + cCatchError
            return createErrorResponse("خطأ في إرسال الطلب: " + cCatchError)
        done
    
    /*
    إنشاء كائن استجابة
    */
    func createResponse nCode, cContent, nLength
        return [
            :status_code = nCode,
            :content = cContent,
           // :content_type = Type,
            :content_length = nLength,
           // :url = URL,
            :success = (nCode >= 200 and nCode < 300),
            :headers = parseResponseHeaders(cContent)
        ]
    
    /*
    إنشاء كائن استجابة خطأ
    */
    func createErrorResponse cError
        return [
            :status_code = 0,
            :content = "",
            :content_type = "",
            :content_length = 0,
            :url = "",
            :success = false,
            :error = cError,
            :headers = []
        ]
    
    /*
    تحليل رؤوس الاستجابة (مبسط)
    */
    func parseResponseHeaders cContent
        # هذه دالة مبسطة - في التطبيق الحقيقي ستحتاج لتحليل أكثر تعقيداً
        return []
    
    /*
    إرسال طلب GET
    المدخلات: cURL - الرابط، aHeaders - الرؤوس الاختيارية
    المخرجات: كائن الاستجابة
    */
    func getrequest cURL, aHeaders
        return request("GET", cURL, aHeaders, NULL)
    
    /*
    إرسال طلب POST
    المدخلات: cURL - الرابط، cData - البيانات، aHeaders - الرؤوس الاختيارية
    المخرجات: كائن الاستجابة
    */
    func post cURL, cData, aHeaders
        return request("POST", cURL, aHeaders, cData)
    
    /*
    إرسال طلب PUT
    المدخلات: cURL - الرابط، cData - البيانات، aHeaders - الرؤوس الاختيارية
    المخرجات: كائن الاستجابة
    */
    func putrequest cURL, cData, aHeaders
        return request("PUT", cURL, aHeaders, cData)
    
    /*
    إرسال طلب DELETE
    المدخلات: cURL - الرابط، aHeaders - الرؤوس الاختيارية
    المخرجات: كائن الاستجابة
    */
    func delete cURL, aHeaders
        return request("DELETE", cURL, aHeaders, NULL)
    
    /*
    إرسال طلب HEAD
    المدخلات: cURL - الرابط، aHeaders - الرؤوس الاختيارية
    المخرجات: كائن الاستجابة
    */
    func head cURL, aHeaders
        return request("HEAD", cURL, aHeaders, NULL)
    
    /*
    تحميل ملف من رابط
    المدخلات: cURL - الرابط، cFilePath - مسار الملف المحلي
    المخرجات: true إذا نجح التحميل، false إذا فشل
    */
    func downloadFile cURL, cFilePath
        ?  "[ info ] " + "تحميل ملف من: " + cURL + " إلى: " + cFilePath
        
        try
            # فتح الملف للكتابة
            fp = fopen(cFilePath, "wb")
            if fp = NULL
                ?  "[ error] " + "فشل في فتح الملف للكتابة: " + cFilePath
                return false
            ok
            
            # تعيين إعدادات التحميل
            curl_easy_setopt(curl, CURLOPT_URL, cURL)
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp)
            
            # تحميل الملف
            curl_easy_perform(curl)
            
            # إغلاق الملف
            fclose(fp)
            
            # التحقق من نجاح التحميل
            nResponseCode = curl_getResponseCode(curl)
            if nResponseCode = 200
                ?  "[ info ] " + "تم تحميل الملف بنجاح"
                return true
            else
                ?  "[ error] " + "فشل في تحميل الملف - كود الاستجابة: " + nResponseCode
                return false
            ok
            
        catch
            ?  "[ error] " + "خطأ في تحميل الملف: " + cCatchError
            return false
        done

    func iif bCondition, cTrue, cFalse
        if bCondition
            return cTrue
        else
            return cFalse
        ok

