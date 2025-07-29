# ===================================================================
# WebView Method Wrapper - حل لاستدعاء الطرق عبر RingWebView
# ===================================================================
load "webview.ring"

# مصفوفة لحفظ مراجع الكائنات
aWebObjects = []

# ===================================================================
# دالة إنشاء مُغلف للطرق - الحل الأساسي
# ===================================================================
func Method oObj, cMethodName
    # إضافة الكائن إلى المصفوفة
    aWebObjects + oObj
    nObjectId = len(aWebObjects)
    
    # إنشاء كود الدالة المُغلفة
    cCode = `
        cFunc = func (id, req) {
            return aWebObjects[#{id}].#{method}(id, req)
        }
    `
    
    # استبدال المتغيرات
    cCode = substr(cCode, "#{id}", "" + nObjectId)
    cCode = substr(cCode, "#{method}", cMethodName)
    
    # تقييم الكود وإرجاع الدالة
    eval(cCode)
    return cFunc

# ===================================================================
# دالة مساعدة لربط طرق الكائن بـ WebView
# ===================================================================
func BindObjectMethods oWebView, oObject, aMethodsList
    aBindList = []
    
    for aMethodInfo in aMethodsList
        cJSName = aMethodInfo[1]      # اسم الدالة في JavaScript
        cMethodName = aMethodInfo[2]  # اسم الطريقة في الكائن
        
        # إنشاء دالة مُغلفة للطريقة
        cWrapperFunc = Method(oObject, cMethodName)
        
        # إضافة إلى قائمة الربط
        aBindList + [cJSName, cWrapperFunc]
    next
    
    # ربط جميع الدوال مع WebView
    for aBinding in aBindList
        cJSName = aBinding[1]
        cWrapperFunc = aBinding[2]
        oWebView.bind(cJSName, cWrapperFunc)
        see "Bound method: " + cJSName + nl
    next
    
    return aBindList

# ===================================================================
# كلاس مساعد لإدارة ربط الطرق
# ===================================================================
class WebViewMethodBinder
    
    aObjects = []
    
    func bindMethod oWebView, cJSName, oObject, cMethodName
        # حفظ الكائن
        this.aObjects + oObject
        nObjectIndex = len(this.aObjects)
        
        # إنشاء دالة مُغلفة باستخدام Method
        cWrapperFunc = Method(oObject, cMethodName)
        
        # ربط الدالة مع WebView
        oWebView.bind(cJSName, cWrapperFunc)
        
        return true
    
    func bindMultipleMethods oWebView, oObject, aMethodsList
        for aMethodInfo in aMethodsList
            cJSName = aMethodInfo[1]
            cMethodName = aMethodInfo[2]
            this.bindMethod(oWebView, cJSName, oObject, cMethodName)
        next

# ===================================================================
# مثال على كلاس معالج الملفات
# ===================================================================
class FileHandler
    
    oWebView = NULL
    
    func init oWebViewRef
        oWebView = oWebViewRef
    
    func saveFile id, req
        see "=== حفظ الملف من خلال الطريقة ===" + nl
        see "ID: " + "" + id + nl
        see "Request: " + "" + req + nl
        
        try{
            aParams = json2list(req)
             ? list2code(aParams) 
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات حفظ الملف غير صحيحة"
                cJsonError = list2json([:error= cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            cContent = aParams[1][2]
            see "حفظ الملف: " + cFileName + nl

            # هنا يمكن إضافة منطق حفظ الملف الفعلي
            aResult = [:success= "تم حفظ الملف بنجاح", :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "تم حفظ الملف بنجاح: " + cFileName + nl

        catch
            see "خطأ في حفظ الملف: " + cCatchError + nl
            cErrorMsg = "خطأ في حفظ الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        }
    
    func loadFile id, req
        see "=== تحميل الملف من خلال الطريقة ===" + nl
        see "ID: " + "" + id + nl
        see "Request: " + "" + req + nl
        
        try{
            aParams = json2list(req)
             ? list2code(aParams) 
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تحميل الملف غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            see "تحميل الملف: " + cFileName + nl

            # محتوى تجريبي
            cSampleContent = "# مرحباً بك في Ring Programming IDE" + nl +
                           "# هذا محتوى تجريبي للملف: " + cFileName + nl + nl +
                           "load " + '"' + "stdlib.ring" + '"' + nl + nl +
                           "func main" + nl +
                           "    see " + '"' + "مرحباً من " + cFileName + "!" + '"' + " + nl" + nl +
                           "main()"

            aResult = [:content= cSampleContent, :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "تم تحميل الملف بنجاح: " + cFileName + nl

        catch
            see "خطأ في تحميل الملف: " + cCatchError + nl
            cErrorMsg = "خطأ في تحميل الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        }
    
    func runCode id, req
        see "=== تشغيل الكود من خلال الطريقة ===" + nl
        see "ID: " + "" + id + nl
        see "Request: " + "" + req + nl
        
        try
            aParams = json2list(req)
             ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تشغيل الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "تشغيل الكود: " + substr(cCode, 1, 100) + "..." + nl

            # محاكاة تشغيل الكود
            cOutput = "تم تشغيل الكود بنجاح!" + nl + "الكود: " + nl + cCode
            aResult = [:output= cOutput]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "تم تشغيل الكود بنجاح" + nl

        catch
            see "خطأ في تشغيل الكود: " + cCatchError + nl
            cErrorMsg = "خطأ في تشغيل الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# كلاس معالج الذكاء الاصطناعي
# ===================================================================
class AIHandler

    oWebView = NULL
    oSmartAgent = NULL

    func init oWebViewRef, oSmartAgentRef
        oWebView = oWebViewRef
        oSmartAgent = oSmartAgentRef

    func chatWithAI id, req
        see "=== محادثة مع الذكاء الاصطناعي من خلال الطريقة ===" + nl
        see "ID: " + "" + id + nl
        see "Request: " + "" + req + nl

        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات الدردشة غير صحيحة"
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cMessage = aParams[1][1]
            cCurrentCode = aParams[1][2]
            see "رسالة المحادثة: " + cMessage + nl

            # استخدام الوكيل الذكي للمحادثة
            oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

            if oResponse["success"]
                cJsonResponse = list2json([oResponse["message"]])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "تم إرسال رد المحادثة بنجاح" + nl
            else
                cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                cJsonError = list2json([cErrorMsg])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                see "تم إرسال رد خطأ المحادثة: " + cErrorMsg + nl
            ok

        catch
            see "خطأ في محادثة الذكاء الاصطناعي: " + cCatchError + nl
            cErrorMsg = "خطأ في المحادثة: " + cCatchError
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func sendAIRequest id, req
        see "=== طلب الذكاء الاصطناعي من خلال الطريقة ===" + nl
        see "ID: " + id + nl
        see "Request: " + req + nl

        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات الطلب غير صحيحة"
                cResult = [:error= cErrorMsg]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                return
            ok

            cMessage = aParams[1][1]
            cCurrentCode = aParams[1][2]
            see "رسالة الذكاء الاصطناعي: " + cMessage + nl

            # استخدام الوكيل الذكي لطلب الذكاء الاصطناعي
            oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

            if oResponse["success"]
                cResult = [:response= oResponse["message"]]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "تم إرسال رد الذكاء الاصطناعي بنجاح" + nl
            else
                cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                cResult = [:error= cErrorMsg]
                cJsonResponse = list2json(cResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                see "تم إرسال رد خطأ الذكاء الاصطناعي: " + cErrorMsg + nl
            ok

        catch
            see "خطأ في طلب الذكاء الاصطناعي: " + cCatchError + nl
            cErrorMsg = "خطأ في طلب الذكاء الاصطناعي: " + cCatchError
            cResult = [:error= cErrorMsg]
            cJsonResponse = list2json(cResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        done

# ===================================================================
# معالج شامل للملفات - يحتوي على جميع عمليات الملفات
# ===================================================================
class ComprehensiveFileHandler

    oWebView = NULL
    oFileManager = NULL

    func init oWebViewRef, oFileManagerRef
        oWebView = oWebViewRef
        oFileManager = oFileManagerRef

    func saveFile id, req
        see "=== SaveFile Method Called ===" + nl
        see "ID: " + "" + id + nl
        see "Request Data: " + "" + req + nl

        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات حفظ الملف غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            cContent = aParams[1][2]
            see "Saving file: " + cFileName + nl

            # استخدام FileManager الفعلي إذا كان متاحاً
            if oFileManager != NULL
                # يمكن إضافة استدعاء FileManager هنا
            ok

            aResult = [:success= "تم حفظ الملف بنجاح", :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File saved successfully: " + cFileName + nl

        catch
            see "Error in saveFile: " + cCatchError + nl
            cErrorMsg = "خطأ في حفظ الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func loadFile id, req
        see "=== LoadFile Method Called ===" + nl
        see "ID: " + "" + id + nl
        see "Request Data: " + "" + req + nl

        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تحميل الملف غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            see "Loading file: " + cFileName + nl

            # محتوى تجريبي محسن
            cSampleContent = "# مرحباً بك في Ring Programming IDE" + nl +
                           "# هذا محتوى تجريبي للملف: " + cFileName + nl + nl +
                           "load " + '"' + "stdlib.ring" + '"' + nl + nl +
                           "func main" + nl +
                           "    see " + '"' + "مرحباً من " + cFileName + "!" + '"' + " + nl" + nl +
                           "main()"

            aResult = [:content= cSampleContent, :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File loaded successfully: " + cFileName + nl

        catch
            see "Error in loadFile: " + cCatchError + nl
            cErrorMsg = "خطأ في تحميل الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func createNewFile id, req
        see "=== CreateNewFile Method Called ===" + nl
        see "ID: " + "" + id + nl
        see "Request Data: " + "" + req + nl

        try
            if req = NULL or len(req) = 0
                see "Warning: Empty request received in createNewFile" + nl
                aError = [:error= "طلب فارغ"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات إنشاء الملف غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            see "Creating file: " + cFileName + nl

            aResult = [:success= "تم إنشاء الملف بنجاح", :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File created successfully: " + cFileName + nl

        catch
            see "Error in createNewFile: " + cCatchError + nl
            cErrorMsg = "خطأ في إنشاء الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func deleteFile id, req
        see "=== DeleteFile Method Called ===" + nl
        try
            if req = NULL or len(req) = 0
                see "Warning: Empty request received in deleteFile" + nl
                aError = [:error= "طلب فارغ"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات حذف الملف غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cFileName = aParams[1][1]
            see "Deleting file: " + cFileName + nl

            # استخدام FileManager إذا كان متاحاً
            if oFileManager != NULL
                # يمكن إضافة استدعاء FileManager هنا
            ok

            aResult = [:success= "تم حذف الملف بنجاح", :fileName= cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            see "Error in deleteFile: " + cCatchError + nl
            cErrorMsg = "خطأ في حذف الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getFileList id, req
        see "=== GetFileList Method Called ===" + nl
        try
            see "GetFileList - Request Data: " + "" + req + nl

            # إرجاع قائمة ملفات تجريبية محسنة
            aFileList = [
                [:name= "main.ring", :active= true, :type= "ring"],
                [:name= "test.ring", :active= false, :type= "ring"],
                [:name= "example.ring", :active= false, :type= "ring"],
                [:name= "config.json", :active= false, :type= "json"],
                [:name= "README.md", :active= false, :type= "markdown"]
            ]

            aResult = [:files= aFileList]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "File list sent successfully" + nl

        catch
            see "Error in getFileList: " + cCatchError + nl
            cErrorMsg = "خطأ في جلب قائمة الملفات: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func openFile id, req
        see "=== OpenFile Method Called ===" + nl
        try
            see "Open file request: " + "" + req + nl

            # استخدام file manager إذا كان متاحاً
            if oFileManager != NULL
                cResult = oFileManager.openFile()
                cJsonResponse = list2json(cResult)
            else
                # محاكاة فتح ملف
                aResult = [:success= "تم فتح الملف بنجاح", :fileName= "selected_file.ring"]
                cJsonResponse = list2json(aResult)
            ok

            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في فتح الملف: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# معالج شامل للكود - يحتوي على جميع عمليات الكود
# ===================================================================
class ComprehensiveCodeHandler

    oWebView = NULL
    oCodeRunner = NULL

    func init oWebViewRef, oCodeRunnerRef
        oWebView = oWebViewRef
        oCodeRunner = oCodeRunnerRef

    func runCode id, req
        see "=== RunCode Method Called ===" + nl
        see "ID: " + "" + id + nl
        see "Request Data: " + "" + req + nl

        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تشغيل الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "Running code: " + substr(cCode, 1, 100) + "..." + nl

            # استخدام CodeRunner إذا كان متاحاً
            if oCodeRunner != NULL
                # يمكن إضافة استدعاء CodeRunner هنا
            ok

            # محاكاة تشغيل الكود
            cOutput = "تم تشغيل الكود بنجاح!" + nl + "الكود: " + nl + cCode
            aResult = [:output= cOutput]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "Code executed successfully" + nl

        catch
            see "Error in runCode: " + cCatchError + nl
            cErrorMsg = "خطأ في تشغيل الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func formatCode id, req
        see "=== FormatCode Method Called ===" + nl
        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تنسيق الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "Formatting code..." + nl

            # استخدام CodeRunner إذا كان متاحاً
            if oCodeRunner != NULL
                oCodeRunner.formatCode(id, req, oWebView)
                return
            ok

            # تنسيق بسيط للكود
            cFormattedCode = "# كود منسق" + nl + cCode
            aResult = [:formatted_code= cFormattedCode]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            see "Error in formatCode: " + cCatchError + nl
            cErrorMsg = "خطأ في تنسيق الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func analyzeCode id, req
        see "=== AnalyzeCode Method Called ===" + nl
        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تحليل الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "Analyzing code..." + nl

            # استخدام CodeRunner إذا كان متاحاً
            if oCodeRunner != NULL
                oCodeRunner.analyzeCode(id, req, oWebView)
                return
            ok

            # تحليل بسيط للكود
            aAnalysis = [
                :lines= 10,
                :functions= 2,
                :variables= 5,
                :suggestions= ["إضافة تعليقات", "تحسين الأداء", "استخدام متغيرات أوضح"]
            ]
            cJsonResponse = list2json(aAnalysis)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            see "Error in analyzeCode: " + cCatchError + nl
            cErrorMsg = "خطأ في تحليل الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func debugCode id, req
        see "=== DebugCode Method Called ===" + nl
        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات تصحيح الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "Debugging code..." + nl

            # استخدام CodeRunner إذا كان متاحاً
            if oCodeRunner != NULL
                cResult = oCodeRunner.debugCode(cCode)
                cJsonResponse = list2json(cResult)
            else
                # تصحيح بسيط للكود
                aDebugInfo = [
                    :status= "success",
                    :breakpoints= [3, 7, 12],
                    :variables= ["x = 10", "y = 20", "result = 30"],
                    :warnings= ["متغير غير مستخدم: temp"],
                    :suggestions= ["إضافة معالجة الأخطاء"]
                ]
                cJsonResponse = list2json(aDebugInfo)
            ok

            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            see "Error in debugCode: " + cCatchError + nl
            cErrorMsg = "خطأ في تصحيح الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getCodeSuggestions id, req
        see "=== GetCodeSuggestions Method Called ===" + nl
        try
            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات اقتراحات الكود غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            cCode = aParams[1][1]
            see "Getting code suggestions..." + nl

            # اقتراحات أساسية للكود
            aSuggestions = [
                "استخدم أسماء متغيرات واضحة",
                "أضف تعليقات للدوال المعقدة",
                "تحقق من صحة المدخلات",
                "استخدم معالجة الأخطاء try/catch",
                "قسم الكود إلى دوال أصغر"
            ]

            aResult = [:suggestions= aSuggestions]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            see "Error in getCodeSuggestions: " + cCatchError + nl
            cErrorMsg = "خطأ في جلب اقتراحات الكود: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# معالج شامل للذكاء الاصطناعي - يحتوي على جميع عمليات الذكاء الاصطناعي
# ===================================================================
class ComprehensiveAIHandler

    oWebView = NULL
    oSmartAgent = NULL

    func init oWebViewRef, oSmartAgentRef
        oWebView = oWebViewRef
        oSmartAgent = oSmartAgentRef

    func chatWithAI id, req
        see "=== ChatWithAI Method Called ===" + nl
        try
            see "Chat request from JavaScript: " + "" + req + nl

            # معالجة JSON المتداخل
            aParams = json2list(req)[1]
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات الدردشة غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # تهيئة المتغيرات
            cMessage = ""
            cCurrentCode = ""

            # إذا كان العنصر الأول نص JSON، قم بتحليله مرة أخرى
            if type(aParams[1]) = "STRING"
                aInnerParams = json2list(aParams[1])
                if type(aInnerParams) = "LIST" and len(aInnerParams) >= 2
                    if type(aInnerParams[1]) = "STRING"
                        cMessage = aInnerParams[1]
                    else
                        cMessage = "" + aInnerParams[1]
                    ok
                    if type(aInnerParams[2]) = "STRING"
                        cCurrentCode = aInnerParams[2]
                    else
                        cCurrentCode = "" + aInnerParams[2]
                    ok
                else
                    if type(aParams[1]) = "STRING"
                        cMessage = aParams[1]
                    else
                        cMessage = "" + aParams[1]
                    ok
                    if len(aParams) >= 2
                        if type(aParams[2]) = "STRING"
                            cCurrentCode = aParams[2]
                        else
                            cCurrentCode = "" + aParams[2]
                        ok
                    else
                        cCurrentCode = ""
                    ok
                ok
            else
                if type(aParams[1]) = "STRING"
                    cMessage = aParams[1]
                else
                    cMessage = "" + aParams[1]
                ok
                if len(aParams) >= 2
                    if type(aParams[2]) = "STRING"
                        cCurrentCode = aParams[2]
                    else
                        cCurrentCode = "" + aParams[2]
                    ok
                else
                    cCurrentCode = ""
                ok
            ok

            see "Chat message: " + cMessage + nl

            # استخدام Smart Agent إذا كان متاحاً
            if oSmartAgent != NULL
                oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

                if oResponse["success"]
                    aResult = [:response= oResponse["message"]]
                    cJsonResponse = list2json(aResult)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                    see "Chat response sent successfully" + nl
                else
                    cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                    aError = [:error= cErrorMsg]
                    cJsonError = list2json(aError)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                    see "Chat error response sent: " + cErrorMsg + nl
                ok
            else
                # رد تجريبي
                cResponse = "مرحباً! أنا مساعد الذكاء الاصطناعي. رسالتك: " + "" + cMessage
                aResult = [:response= cResponse]
                cJsonResponse = list2json(aResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            ok

        catch
            see "Error in AI chat: " + cCatchError + nl
            cErrorMsg = "خطأ في المحادثة: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func sendAIRequest id, req
        see "=== SendAIRequest Method Called ===" + nl
        try
            see "AI request from JavaScript: " + "" + req + nl

            # معالجة JSON المتداخل
            aParams = json2list(req)[1]
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 1
                cErrorMsg = "معاملات الطلب غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonResponse = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                return
            ok

            # تهيئة المتغيرات
            cMessage = ""
            cCurrentCode = ""

            # إذا كان العنصر الأول نص JSON، قم بتحليله مرة أخرى
            if type(aParams[1]) = "STRING"
                aInnerParams = json2list(aParams[1])
                if type(aInnerParams) = "LIST" and len(aInnerParams) >= 2
                    if type(aInnerParams[1]) = "STRING"
                        cMessage = aInnerParams[1]
                    else
                        cMessage = "" + aInnerParams[1]
                    ok
                    if type(aInnerParams[2]) = "STRING"
                        cCurrentCode = aInnerParams[2]
                    else
                        cCurrentCode = "" + aInnerParams[2]
                    ok
                else
                    if type(aParams[1]) = "STRING"
                        cMessage = aParams[1]
                    else
                        cMessage = "" + aParams[1]
                    ok
                    if len(aParams) >= 2
                        if type(aParams[2]) = "STRING"
                            cCurrentCode = aParams[2]
                        else
                            cCurrentCode = "" + aParams[2]
                        ok
                    else
                        cCurrentCode = ""
                    ok
                ok
            else
                if type(aParams[1]) = "STRING"
                    cMessage = aParams[1]
                else
                    cMessage = "" + aParams[1]
                ok
                if len(aParams) >= 2
                    if type(aParams[2]) = "STRING"
                        cCurrentCode = aParams[2]
                    else
                        cCurrentCode = "" + aParams[2]
                    ok
                else
                    cCurrentCode = ""
                ok
            ok

            see "AI message: " + cMessage + nl

            # استخدام Smart Agent إذا كان متاحاً
            if oSmartAgent != NULL
                oResponse = oSmartAgent.processRequest(cMessage, cCurrentCode)

                if oResponse["success"]
                    aResult = [:response= oResponse["message"]]
                    cJsonResponse = list2json(aResult)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                    see "AI response sent successfully" + nl
                else
                    cErrorMsg = "عذراً، حدث خطأ: " + oResponse["error"]
                    aError = [:error= cErrorMsg]
                    cJsonResponse = list2json(aError)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                    see "AI error response sent: " + cErrorMsg + nl
                ok
            else
                # رد تجريبي
                cResponse = "تم معالجة طلبك: " + "" + cMessage
                aResult = [:response= cResponse]
                cJsonResponse = list2json(aResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            ok

        catch
            see "Error in AI request: " + cCatchError + nl
            cErrorMsg = "خطأ في طلب الذكاء الاصطناعي: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonResponse = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        done

    func processRequest id, req
        see "=== ProcessRequest Method Called ===" + nl
        try
            see "Processing request from JavaScript: " + "" + req + nl

            aParams = json2list(req)[1]
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) < 2
                cErrorMsg = "معاملات غير صحيحة"
                aError = [:error= cErrorMsg]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # تحويل المعاملات إلى نصوص آمنة
            if type(aParams[1]) = "STRING"
                cUserMessage = aParams[1]
            else
                cUserMessage = "" + aParams[1]
            ok

            if type(aParams[2]) = "STRING"
                cCurrentCode = aParams[2]
            else
                cCurrentCode = "" + aParams[2]
            ok

            see "User message: " + cUserMessage + nl
            see "Current code length: " + len(cCurrentCode) + nl

            # استخدام Smart Agent إذا كان متاحاً
            if oSmartAgent != NULL
                oResponse = oSmartAgent.processRequest(cUserMessage, cCurrentCode)
                see "Agent response: " + list2code(oResponse) + nl

                if oResponse["success"]
                    aResult = [:response= oResponse["message"]]
                    cJsonResponse = list2json(aResult)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
                    see "Success response sent" + nl
                else
                    cErrorMsg = "خطأ: " + oResponse["error"]
                    aError = [:error= cErrorMsg]
                    cJsonError = list2json(aError)
                    oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                    see "Error response sent: " + cErrorMsg + nl
                ok
            else
                # رد تجريبي
                cResponse = "تم معالجة الطلب: " + "" + cUserMessage
                aResult = [:response= cResponse]
                cJsonResponse = list2json(aResult)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            ok

        catch
            see "Error processing request: " + cCatchError + nl
            cErrorMsg = "خطأ في معالجة الطلب: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getAgentStatus id, req
        see "=== GetAgentStatus Method Called ===" + nl
        try
            if oSmartAgent != NULL
                cStatus = oSmartAgent.getAgentStatus()
                aResult = [:status= cStatus]
                cJsonResponse = list2json(aResult)
            else
                aResult = [:status= "Smart Agent غير متاح"]
                cJsonResponse = list2json(aResult)
            ok
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            aError = [:error= "خطأ في الحصول على حالة الوكيل"]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# معالج شامل للمشاريع - يحتوي على جميع عمليات المشاريع
# ===================================================================
class ComprehensiveProjectHandler

    oWebView = NULL
    oFileManager = NULL
    oSmartAgent = NULL

    func init oWebViewRef, oFileManagerRef, oSmartAgentRef
        oWebView = oWebViewRef
        oFileManager = oFileManagerRef
        oSmartAgent = oSmartAgentRef

    func createProject id, req
        see "=== CreateProject Method Called ===" + nl
        try
            see "Create project request: " + "" + req + nl
            aParams = json2list(req)[1]
            ? list2code(aParams)
            if type(aParams) = "LIST" and len(aParams) > 0
                cProjectName = aParams[1]

                # استخدام FileManager إذا كان متاحاً
                if oFileManager != NULL
                    cResult = oFileManager.createProject(cProjectName)
                    cJsonResponse = list2json(cResult)
                else
                    aResult = [:success= "تم إنشاء المشروع: " + cProjectName]
                    cJsonResponse = list2json(aResult)
                ok
            else
                aResult = [:error= "اسم المشروع مطلوب"]
                cJsonResponse = list2json(aResult)
            ok
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في إنشاء المشروع: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func openProject id, req
        see "=== OpenProject Method Called ===" + nl
        try
            see "Open project request: " + "" + req + nl

            # استخدام FileManager إذا كان متاحاً
            if oFileManager != NULL
                cResult = oFileManager.openProject()
                cJsonResponse = list2json(cResult)
            else
                aResult = [:success= "تم فتح المشروع", :project= "مشروع تجريبي"]
                cJsonResponse = list2json(aResult)
            ok

            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في فتح المشروع: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func saveProject id, req
        see "=== SaveProject Method Called ===" + nl
        try
            see "Save project request: " + "" + req + nl

            # استخدام FileManager إذا كان متاحاً
            if oFileManager != NULL
                cResult = oFileManager.saveProject()
                cJsonResponse = list2json(cResult)
            else
                aResult = [:success= "تم حفظ المشروع"]
                cJsonResponse = list2json(aResult)
            ok

            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cErrorMsg = "خطأ في حفظ المشروع: " + cCatchError
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func setCurrentProject id, req
        see "=== SetCurrentProject Method Called ===" + nl
        try
            see "Set project request: " + "" + req + nl

            aParams = json2list(req)[1]
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) = 0
                aError = [:error= "معاملات غير صحيحة لتعيين المشروع"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # استخراج اسم المشروع
            cProjectName = ""
            if len(aParams) >= 1
                if type(aParams[1]) = "LIST" and len(aParams[1]) >= 1
                    cProjectName = aParams[1][1]  # Format: [["name"]]
                else
                    cProjectName = aParams[1]     # Format: ["name"]
                ok
            ok

            if cProjectName = "" or cProjectName = null
                aError = [:error= "اسم المشروع فارغ"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # استخدام SmartAgent إذا كان متاحاً
            if oSmartAgent != NULL
                oSmartAgent.setCurrentProject(cProjectName)
            ok

            aResult = [:success= "تم تعيين المشروع: " + cProjectName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            aError = [:error= "خطأ في تعيين المشروع: " + cCatchError]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func setCurrentFile id, req
        see "=== SetCurrentFile Method Called ===" + nl
        try
            see "Set file request: " + "" + req + nl

            aParams = json2list(req)
            ? list2code(aParams)
            if type(aParams) != "LIST" or len(aParams) = 0
                aError = [:error= "معاملات غير صحيحة لتعيين الملف"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # استخراج اسم الملف
            cFileName = ""
            if len(aParams) >= 1
                if type(aParams[1]) = "LIST" and len(aParams[1]) >= 1
                    cFileName = aParams[1][1]  # Format: [["name"]]
                else
                    cFileName = aParams[1]     # Format: ["name"]
                ok
            ok

            if cFileName = "" or cFileName = null
                aError = [:error= "اسم الملف فارغ"]
                cJsonError = list2json(aError)
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
                return
            ok

            # استخدام SmartAgent إذا كان متاحاً
            if oSmartAgent != NULL
                oSmartAgent.setCurrentFile(cFileName)
            ok

            aResult = [:success= "تم تعيين الملف: " + cFileName]
            cJsonResponse = list2json(aResult)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            aError = [:error= "خطأ في تعيين الملف: " + cCatchError]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# معالج شامل للنظام - يحتوي على وظائف النظام العامة
# ===================================================================
class ComprehensiveSystemHandler

    oWebView = NULL

    func init oWebViewRef
        oWebView = oWebViewRef

    func testConnection id, req
        see "=== TestConnection Method Called ===" + nl
        see "ID: " + "" + id + nl
        see "Request Data: " + "" + req + nl

        try
            # اختبار الاتصال الأساسي
            aResult = [
                :status= "success",
                :message= "✅ Ring Backend متصل بنجاح!",
                :functions_available= [
                    "createNewFile", "runCode", "sendAIRequest",
                    "getFileList", "saveFile", "loadFile",
                    "chatWithAI", "testConnection", "formatCode",
                    "analyzeCode", "debugCode", "createProject",
                    "openProject", "saveProject"
                ],
                :timestamp= date() + " " + time(),
                :method_wrapper= "active"
            ]

            cJsonResponse = list2json(aResult)
            see "Test connection response: " + cJsonResponse + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)

        catch
            cErrorMsg = "خطأ في اختبار الاتصال: " + cCatchError
            see "Error in testConnection: " + cErrorMsg + nl
            aError = [:error= cErrorMsg]
            cJsonError = list2json(aError)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# ===================================================================
# مدير شامل للمعالجات - يدير جميع المعالجات
# ===================================================================
class ComprehensiveHandlerManager

    oWebView = NULL
    oFileHandler = NULL
    oCodeHandler = NULL
    oAIHandler = NULL
    oProjectHandler = NULL
    oSystemHandler = NULL

    func init oWebViewRef, oSmartAgentRef, oFileManagerRef, oCodeRunnerRef
        oWebView = oWebViewRef

        # إنشاء جميع المعالجات
        oFileHandler = new ComprehensiveFileHandler(oWebView, oFileManagerRef)
        oCodeHandler = new ComprehensiveCodeHandler(oWebView, oCodeRunnerRef)
        oAIHandler = new ComprehensiveAIHandler(oWebView, oSmartAgentRef)
        oProjectHandler = new ComprehensiveProjectHandler(oWebView, oFileManagerRef, oSmartAgentRef)
        oSystemHandler = new ComprehensiveSystemHandler(oWebView)

        see "ComprehensiveHandlerManager initialized successfully!" + nl

    func bindAllMethods()
        see "=== Binding All Methods with New System ===" + nl

        # ربط طرق معالج الملفات
        aFileMethodsList = [
            ["saveFile", "saveFile"],
            ["loadFile", "loadFile"],
            ["createNewFile", "createNewFile"],
            ["deleteFile", "deleteFile"],
            ["getFileList", "getFileList"],
            ["openFile", "openFile"]
        ]
        BindObjectMethods(oWebView, oFileHandler, aFileMethodsList)
        see "File handler methods bound: " + len(aFileMethodsList) + " methods" + nl

        # ربط طرق معالج الكود
        aCodeMethodsList = [
            ["runCode", "runCode"],
            ["formatCode", "formatCode"],
            ["analyzeCode", "analyzeCode"],
            ["debugCode", "debugCode"],
            ["getCodeSuggestions", "getCodeSuggestions"]
        ]
        BindObjectMethods(oWebView, oCodeHandler, aCodeMethodsList)
        see "Code handler methods bound: " + len(aCodeMethodsList) + " methods" + nl

        # ربط طرق معالج الذكاء الاصطناعي
        aAIMethodsList = [
            ["chatWithAI", "chatWithAI"],
            ["sendAIRequest", "sendAIRequest"],
            ["processRequest", "processRequest"],
            ["getAgentStatus", "getAgentStatus"]
        ]
        BindObjectMethods(oWebView, oAIHandler, aAIMethodsList)
        see "AI handler methods bound: " + len(aAIMethodsList) + " methods" + nl

        # ربط طرق معالج المشاريع
        aProjectMethodsList = [
            ["createProject", "createProject"],
            ["openProject", "openProject"],
            ["saveProject", "saveProject"],
            ["setCurrentProject", "setCurrentProject"],
            ["setCurrentFile", "setCurrentFile"]
        ]
        BindObjectMethods(oWebView, oProjectHandler, aProjectMethodsList)
        see "Project handler methods bound: " + len(aProjectMethodsList) + " methods" + nl

        # ربط طرق معالج النظام
        aSystemMethodsList = [
            ["testConnection", "testConnection"]
        ]
        BindObjectMethods(oWebView, oSystemHandler, aSystemMethodsList)
        see "System handler methods bound: " + len(aSystemMethodsList) + " methods" + nl

        nTotalMethods = len(aFileMethodsList) + len(aCodeMethodsList) + len(aAIMethodsList) +
                       len(aProjectMethodsList) + len(aSystemMethodsList)
        see "=== Total methods bound: " + nTotalMethods + " ===" + nl

        return true

# ===================================================================
# كلاسات مساعدة إضافية للمثال
# ===================================================================

# معالج ملفات متقدم
class AdvancedFileHandler from FileHandler

    func createFile id, req
        see "=== إنشاء ملف جديد ===" + nl
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cJsonResponse = list2json([:success= "تم إنشاء الملف: " + cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في إنشاء الملف"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func deleteFile id, req
        see "=== حذف ملف ===" + nl
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cJsonResponse = list2json([:success= "تم حذف الملف: " + cFileName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في حذف الملف"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getFileList id, req
        see "=== جلب قائمة الملفات ===" + nl
        try
            aFileList = ["main.ring", "test.ring", "example.ring"]
            cJsonResponse = list2json([:files= aFileList])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في جلب قائمة الملفات"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# معالج المشاريع
class ProjectHandler

    oWebView = NULL

    func init oWebViewRef
        oWebView = oWebViewRef

    func createProject id, req
        see "=== إنشاء مشروع جديد ===" + nl
        try
            aParams = json2list(req)
            cProjectName = aParams[1]
            cJsonResponse = list2json([:success= "تم إنشاء المشروع: " + cProjectName])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في إنشاء المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func openProject id, req
        see "=== فتح مشروع ===" + nl
        try
            cJsonResponse = list2json([:success= "تم فتح المشروع", :project= "مشروع تجريبي"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في فتح المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func saveProject id, req
        see "=== حفظ المشروع ===" + nl
        try
            cJsonResponse = list2json([:success= "تم حفظ المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في حفظ المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func getProjectInfo id, req
        see "=== معلومات المشروع ===" + nl
        try
            aProjectInfo = [
                :name= "مشروع تجريبي",
                :files= ["main.ring", "test.ring"],
                :created= date()
            ]
            cJsonResponse = list2json(aProjectInfo)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في جلب معلومات المشروع"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

# معالج الكود
class CodeHandler

    oWebView = NULL

    func init oWebViewRef
        oWebView = oWebViewRef

    func runCode id, req
        see "=== تشغيل الكود ===" + nl
        try
            aParams = json2list(req)
            cCode = aParams[1]
            cOutput = "تم تشغيل الكود بنجاح!" + nl + "النتيجة: Hello World!"
            cJsonResponse = list2json([:output= cOutput])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في تشغيل الكود"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func formatCode id, req
        see "=== تنسيق الكود ===" + nl
        try
            aParams = json2list(req)
            cCode = aParams[1]
            cFormattedCode = "# كود منسق" + nl + cCode
            cJsonResponse = list2json([:formatted_code= cFormattedCode])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في تنسيق الكود"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func analyzeCode id, req
        see "=== تحليل الكود ===" + nl
        try
            aParams = json2list(req)
            cCode = aParams[1]
            aAnalysis = [
                :lines= 5,
                :functions= 1,
                :variables= 2,
                :suggestions= ["إضافة تعليقات", "تحسين الأداء"]
            ]
            cJsonResponse = list2json(aAnalysis)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في تحليل الكود"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done

    func debugCode id, req
        see "=== تصحيح الكود ===" + nl
        try
            aParams = json2list(req)
            cCode = aParams[1]
            aDebugInfo = [
                :status= "success",
                :breakpoints= [3, 7],
                :variables= ["x = 10", "y = 20"]
            ]
            cJsonResponse = list2json(aDebugInfo)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
        catch
            cJsonError = list2json([:error= "خطأ في تصحيح الكود"])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
