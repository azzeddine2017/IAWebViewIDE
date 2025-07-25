# ===================================================================
# AI Assistant Class - Handles intelligent chat responses
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"

class AIAssistant
    
    # Private properties
    aChatHistory = []
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        see "AIAssistant initialized." + nl
    
    # ===================================================================
    # Chat with AI
    # ===================================================================
    func chatWithAI(id, req, oWebView)
        try
            aParams = json2list(req)
            cMessage = aParams[1]
            cCurrentCode = aParams[2]
            
            # Process the AI chat request
            cResponse = processAIChat(cMessage, cCurrentCode)
            
            # Add to chat history
            aChatHistory + [cMessage, cResponse]
            
            cJsonResponse = list2json([cResponse])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonResponse)
            see "AI chat processed: " + cMessage + nl
            
        catch
            see "Error in AI chat: " + cCatchError + nl
            cErrorMsg = "عذراً، حدث خطأ في معالجة طلبك. يرجى المحاولة مرة أخرى."
            cJsonError = list2json([cErrorMsg])
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonError)
        done
    
    # ===================================================================
    # Process AI Chat
    # ===================================================================
    func processAIChat(cMessage, cCurrentCode)
        cResponse = ""
        cLowerMessage = lower(cMessage)
        
        # Analyze the message and provide appropriate response
        if substr(cLowerMessage, "مساعدة") or substr(cLowerMessage, "help")
            cResponse = getHelpResponse()
            
        elseif substr(cLowerMessage, "خطأ") or substr(cLowerMessage, "error")
            cResponse = getErrorHelpResponse(cCurrentCode)
            
        elseif substr(cLowerMessage, "كيف") or substr(cLowerMessage, "how")
            cResponse = getHowToResponse(cMessage)
            
        elseif substr(cLowerMessage, "مثال") or substr(cLowerMessage, "example")
            cResponse = getExampleResponse(cMessage)
            
        elseif substr(cLowerMessage, "تحسين") or substr(cLowerMessage, "optimize")
            cResponse = getOptimizationResponse(cCurrentCode)
            
        elseif substr(cLowerMessage, "شرح") or substr(cLowerMessage, "explain")
            cResponse = getExplanationResponse(cCurrentCode)
            
        else
            cResponse = getGeneralResponse(cMessage, cCurrentCode)
        ok
        
        return cResponse
    
    # ===================================================================
    # Help Response
    # ===================================================================
    func getHelpResponse()
        return "مرحباً! أنا مساعدك الذكي للبرمجة بلغة Ring. يمكنني مساعدتك في:" + nl +
               "• شرح أكواد Ring" + nl +
               "• إصلاح الأخطاء" + nl +
               "• تقديم أمثلة برمجية" + nl +
               "• تحسين الكود" + nl +
               "• الإجابة على أسئلة البرمجة" + nl +
               "• اقتراح حلول برمجية" + nl + nl +
               "اكتب سؤالك أو اطلب مساعدة محددة!"
    
    # ===================================================================
    # Error Help Response
    # ===================================================================
    func getErrorHelpResponse(cCode)
        cResponse = "دعني أساعدك في إصلاح الأخطاء:" + nl + nl
        
        if len(cCode) > 0
            # Basic error checking
            if not substr(cCode, "func main")
                cResponse += "• تأكد من وجود دالة main() في برنامجك" + nl
            ok
            
            nOpenBraces = substr_count(cCode, "{")
            nCloseBraces = substr_count(cCode, "}")
            if nOpenBraces != nCloseBraces
                cResponse += "• تحقق من توازن الأقواس المجعدة { }" + nl
            ok
            
            if not substr(cCode, "load") and not substr(cCode, "import")
                cResponse += "• قد تحتاج لتحميل مكتبات باستخدام load" + nl
            ok
        else
            cResponse += "لا يوجد كود للفحص. اكتب الكود أولاً ثم اطلب المساعدة."
        ok
        
        return cResponse
    
    # ===================================================================
    # How To Response
    # ===================================================================
    func getHowToResponse(cMessage)
        cResponse = "إليك بعض الأمثلة الشائعة في Ring:" + nl + nl
        
        if substr(cMessage, "متغير") or substr(cMessage, "variable")
            cResponse += "إنشاء المتغيرات:" + nl +
                        "cName = \"أحمد\"  # نص" + nl +
                        "nAge = 25        # رقم" + nl +
                        "bActive = true   # منطقي" + nl +
                        "aList = [1,2,3]  # قائمة" + nl
                        
        elseif substr(cMessage, "دالة") or substr(cMessage, "function")
            cResponse += "إنشاء الدوال:" + nl +
                        "func myFunction(param1, param2)" + nl +
                        "    # كود الدالة" + nl +
                        "    return result" + nl
                        
        elseif substr(cMessage, "حلقة") or substr(cMessage, "loop")
            cResponse += "حلقات التكرار:" + nl +
                        "for i = 1 to 10" + nl +
                        "    see i + nl" + nl +
                        "next" + nl + nl +
                        "while condition" + nl +
                        "    # كود" + nl +
                        "end"
        else
            cResponse += "حدد ما تريد تعلمه: متغيرات، دوال، حلقات، شروط، كلاسات..."
        ok
        
        return cResponse
    
    # ===================================================================
    # Example Response
    # ===================================================================
    func getExampleResponse(cMessage)
        return "مثال برمجي بسيط:" + nl + nl +
               "# برنامج حساب المتوسط" + nl +
               "func main()" + nl +
               "    aNumbers = [10, 20, 30, 40, 50]" + nl +
               "    nSum = 0" + nl +
               "    " + nl +
               "    for nNum in aNumbers" + nl +
               "        nSum += nNum" + nl +
               "    next" + nl +
               "    " + nl +
               "    nAverage = nSum / len(aNumbers)" + nl +
               "    see \"المتوسط: \" + nAverage + nl" + nl + nl +
               "هل تريد مثالاً على موضوع محدد؟"
    
    # ===================================================================
    # Optimization Response
    # ===================================================================
    func getOptimizationResponse(cCode)
        cResponse = "اقتراحات لتحسين الكود:" + nl + nl
        
        if len(cCode) > 0
            # Check for optimization opportunities
            if substr(cCode, "for") and substr(cCode, "see")
                cResponse += "• استخدم list2str() بدلاً من حلقة for للطباعة" + nl
            ok
            
            if substr_count(cCode, "if") > 3
                cResponse += "• فكر في استخدام switch بدلاً من if متعددة" + nl
            ok
            
            cResponse += "• استخدم أسماء متغيرات وصفية" + nl +
                        "• قسم الكود إلى دوال صغيرة" + nl +
                        "• أضف تعليقات توضيحية" + nl
        else
            cResponse = "اكتب الكود أولاً لأتمكن من اقتراح تحسينات."
        ok
        
        return cResponse
    
    # ===================================================================
    # Explanation Response
    # ===================================================================
    func getExplanationResponse(cCode)
        if len(cCode) = 0
            return "اكتب الكود أولاً لأتمكن من شرحه لك."
        ok
        
        cResponse = "شرح الكود:" + nl + nl
        aLines = str2list(cCode)
        
        for i = 1 to len(aLines)
            cLine = trim(aLines[i])
            if len(cLine) > 0 and not substr(cLine, "#")
                cResponse += "السطر " + i + ": "
                
                if substr(cLine, "func ")
                    cResponse += "تعريف دالة جديدة"
                elseif substr(cLine, "for ")
                    cResponse += "بداية حلقة تكرار"
                elseif substr(cLine, "if ")
                    cResponse += "شرط منطقي"
                elseif substr(cLine, "see ")
                    cResponse += "طباعة نص أو متغير"
                elseif substr(cLine, "=")
                    cResponse += "إسناد قيمة لمتغير"
                else
                    cResponse += "تنفيذ عملية"
                ok
                
                cResponse += nl
            ok
        next
        
        return cResponse
    
    # ===================================================================
    # General Response
    # ===================================================================
    func getGeneralResponse(cMessage, cCurrentCode)
        return "شكراً لسؤالك! أحاول فهم طلبك..." + nl + nl +
               "يمكنني مساعدتك في:" + nl +
               "• كتابة كود Ring" + nl +
               "• شرح المفاهيم البرمجية" + nl +
               "• إصلاح الأخطاء" + nl +
               "• تحسين الأداء" + nl + nl +
               "اطرح سؤالاً أكثر تحديداً لأتمكن من مساعدتك بشكل أفضل."
    
    # ===================================================================
    # Utility function to count substring occurrences
    # ===================================================================
    func substr_count(cString, cSubString)
        nCount = 0
        nPos = 1
        while true
            nPos = substr(cString, cSubString, nPos)
            if nPos = 0
                exit
            ok
            nCount++
            nPos++
        end
        return nCount
