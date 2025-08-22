# ===================================================================
# AI Client - Advanced API Integration System
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"
load "http_client.ring"

class AIClient
    
    # Configuration
    cGeminiAPIKey = ""
    cOpenAIAPIKey = ""
    cClaudeAPIKey = ""
    cCurrentProvider = "gemini"  # Default provider
    
    # API Endpoints
    cGeminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    cOpenAIEndpoint = "https://api.openai.com/v1/chat/completions"
    cClaudeEndpoint = "https://api.anthropic.com/v1/messages"
    
    # Request settings
    nTimeout = 30
    nMaxTokens = 4096
    nTemperature = 0.7
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        loadAPIKeys()
        see "AIClient initialized with provider: " + cCurrentProvider + nl
    
    # ===================================================================
    # Load API Keys from Configuration
    # ===================================================================
    func loadAPIKeys()
        try
            if fexists("config/api_keys.json")
                cConfigContent = read("config/api_keys.json")
                oConfig = json2list(cConfigContent)
                if type(oConfig) = "LIST" and len(oConfig) > 0
                    oKeys = oConfig[1]
                    if type(oKeys) = "LIST"
                        # Load API keys with correct field names
                        oGemini = getValue(oKeys, "gemini", [])
                        if type(oGemini) = "LIST"
                            cGeminiAPIKey = oGemini["api_key"]
                        ok

                        oOpenAI = getValue(oKeys, "openai", [])
                        if type(oOpenAI) = "LIST"
                            cOpenAIAPIKey = oOpenAI["api_key"]
                        ok

                        oClaude = getValue(oKeys, "claude", [])
                        if type(oClaude) = "LIST"
                            cClaudeAPIKey = oClaude["api_key"]
                        ok

                        cCurrentProvider = oKeys[1]["default_provider"]
                        nMaxTokens = oKeys[1]["max_tokens"]
                        nTemperature = oKeys[1]["temperature"]
                        nTimeout = oKeys[1]["timeout"]
                    ok
                ok
            else
                createDefaultConfig()
            ok
        catch
            see "Warning: Could not load API keys: " + cCatchError + nl
            createDefaultConfig()
        done
    
    # ===================================================================
    # Create Default Configuration File
    # ===================================================================
    func createDefaultConfig()
        try
            if not fexists("config")
                system("mkdir config")
            ok
            
            oDefaultConfig = [
                "gemini_api_key" = "",
                "openai_api_key" = "",
                "claude_api_key" = "",
                "default_provider" = "gemini"
            ]
            
            cConfigJSON = list2json(oDefaultConfig)
            write("config/api_keys.json", cConfigJSON)
            
            see "Created default configuration file: config/api_keys.json" + nl
            see "Please add your API keys to the configuration file." + nl
            
        catch
            see "Error creating default config: " + cCatchError + nl
        done
    
    # ===================================================================
    # Set API Provider
    # ===================================================================
    func setProvider(cProvider)
        if cProvider = "gemini" or cProvider = "openai" or cProvider = "claude"
            cCurrentProvider = cProvider
            see "AI Provider set to: " + cProvider + nl
            return true
        else
            see "Invalid provider: " + cProvider + nl
            return false
        ok
    
    # ===================================================================
    # Send Request (Main Entry Point)
    # ===================================================================
    func sendRequest(cMessage)
        return sendChatRequest(cMessage, "", [])

    # ===================================================================
    # Send Chat Request
    # ===================================================================
    func sendChatRequest(cMessage, cSystemPrompt, aContext)
        try
            switch cCurrentProvider
                on "gemini"
                    return sendGeminiRequest(cMessage, cSystemPrompt, aContext)
                on "openai"
                    return sendOpenAIRequest(cMessage, cSystemPrompt, aContext)
                on "claude"
                    return sendClaudeRequest(cMessage, cSystemPrompt, aContext)
                other
                    return createErrorResponse("Invalid AI provider: " + cCurrentProvider)
            off

        catch
            return createErrorResponse("Error in AI request: " + cCatchError)
        done
    
    # ===================================================================
    # Send Gemini Request
    # ===================================================================
    func sendGeminiRequest(cMessage, cSystemPrompt, aContext)
        if cGeminiAPIKey = "" or cGeminiAPIKey = "YOUR_GEMINI_API_KEY_HERE"
            see "No valid Gemini API key, using demo response" + nl
            return createSuccessResponse("🤖 مرحباً! أنا في الوضع التجريبي. رسالتك: " + cMessage + nl +
                                       "للحصول على ردود حقيقية، يرجى إضافة مفتاح API صحيح في config/api_keys.json")
        ok

        try
            see "Sending request to Gemini API..." + nl

            # Build request payload
            cFullPrompt = buildContextualPrompt(cMessage, cSystemPrompt, aContext)

            oRequestData = [
                :contents = [
                    [
                        :parts = [
                            [
                                :text = cFullPrompt
                            ]
                        ]
                    ]
                ],
                :generationConfig = [
                    :temperature = nTemperature,
                    :maxOutputTokens = nMaxTokens
                ]
            ]

            cRequestJSON = list2json(oRequestData)
            cURL = cGeminiEndpoint + "?key=" + cGeminiAPIKey

            see "Request URL: " + substr(cURL, 1, 80) + "..." + nl
            see "Request data length: " + len(cRequestJSON) + nl

            # Send HTTP request
            cResponse = sendHTTPRequest(cURL, cRequestJSON, "POST", [
                "Content-Type: application/json"
            ])

            return parseGeminiResponse(cResponse)

        catch
            see "Gemini request failed: " + cCatchError + nl
            return createErrorResponse("Gemini request failed: " + cCatchError)
        done
    
    # ===================================================================
    # Send OpenAI Request
    # ===================================================================
    func sendOpenAIRequest(cMessage, cSystemPrompt, aContext)
        if cOpenAIAPIKey = ""
            return createErrorResponse("OpenAI API key not configured")
        ok
        
        try
            # Build messages array
            aMessages = []
            
            if cSystemPrompt != ""
                aMessages + ["role" = "system", "content" = cSystemPrompt]
            ok
            
            # Add context messages
            if type(aContext) = "LIST" and len(aContext) > 0
                for oContextItem in aContext
                    aMessages + oContextItem
                next
            ok
            
            # Add user message
            aMessages + ["role" = "user", "content" = cMessage]
            
            oRequestData = [
                "model" = "gpt-4",
                "messages" = aMessages,
                "temperature" = nTemperature,
                "max_tokens" = nMaxTokens
            ]
            
            cRequestJSON = list2json(oRequestData)
            
            # Send HTTP request
            cResponse = sendHTTPRequest(cOpenAIEndpoint, cRequestJSON, "POST", [
                "Content-Type: application/json",
                "Authorization: Bearer " + cOpenAIAPIKey
            ])
            
            return parseOpenAIResponse(cResponse)
            
        catch
            return createErrorResponse("OpenAI request failed: " + cCatchError)
        done
    
    # ===================================================================
    # Send Claude Request
    # ===================================================================
    func sendClaudeRequest(cMessage, cSystemPrompt, aContext)
        if cClaudeAPIKey = ""
            return createErrorResponse("Claude API key not configured")
        ok
        
        try
            # Build messages array
            aMessages = []
            
            # Add context messages
            if type(aContext) = "LIST" and len(aContext) > 0
                for oContextItem in aContext
                    aMessages + oContextItem
                next
            ok
            
            # Add user message
            aMessages + ["role" = "user", "content" = cMessage]
            
            oRequestData = [
                "model" = "claude-3-sonnet-20240229",
                "max_tokens" = nMaxTokens,
                "temperature" = nTemperature,
                "messages" = aMessages
            ]
            
            if cSystemPrompt != ""
                oRequestData["system"] = cSystemPrompt
            ok
            
            cRequestJSON = list2json(oRequestData)
            
            # Send HTTP request
            cResponse = sendHTTPRequest(cClaudeEndpoint, cRequestJSON, "POST", [
                "Content-Type: application/json",
                "x-api-key: " + cClaudeAPIKey,
                "anthropic-version: 2023-06-01"
            ])
            
            return parseClaudeResponse(cResponse)
            
        catch
            return createErrorResponse("Claude request failed: " + cCatchError)
        done
    
    # ===================================================================
    # Build Contextual Prompt
    # ===================================================================
    func buildContextualPrompt(cMessage, cSystemPrompt, aContext)
        cPrompt = ""

        # Add system prompt
        if cSystemPrompt != "" and cSystemPrompt != null
            cPrompt += "System: " + cSystemPrompt + nl + nl
        ok

        # Add context
        if type(aContext) = "LIST" and len(aContext) > 0
            cPrompt += "Context:" + nl
            for oContextItem in aContext
                if type(oContextItem) = "LIST"
                    cRole = getValue(oContextItem, "role", "user")
                    cContent = getValue(oContextItem, "content", "")
                    if cRole != "" and cContent != "" and cRole != null and cContent != null
                        cPrompt += cRole + ": " + cContent + nl
                    ok
                elseif type(oContextItem) = "STRING" and oContextItem != ""
                    cPrompt += oContextItem + nl
                ok
            next
            cPrompt += nl
        ok

        # Add user message
        if cMessage != "" and cMessage != null
            cPrompt += "User: " + cMessage
        ok

        return cPrompt
    
    # ===================================================================
    # Utility Functions
    # ===================================================================
    func getValue(aList, cKey, cDefault)
        if type(aList) = "LIST"
            for i = 1 to len(aList) step 2
                if i < len(aList) and aList[i] = cKey
                    return aList[i+1]
                ok
            next
        ok
        return cDefault
    
    func createErrorResponse(cError)
        return [
            :success = false,
            :error = cError,
            :message = "عذراً، حدث خطأ في الاتصال بخدمة الذكاء الاصطناعي: " + cError
        ]

    func createSuccessResponse(cContent)
        return [
            :success = true,
            :error = "",
            :message = cContent
        ]

    # ===================================================================
    # HTTP Request Function - Using SimpleHTTPClient
    # ===================================================================
    func sendHTTPRequest(cURL, cData, cMethod, aHeaders)
        try
            see "Sending HTTP request to: " + cURL + nl
            see "Method: " + cMethod + nl
            see "Data length: " + len(cData) + " characters" + nl

            # إنشاء عميل HTTP بسيط
            oClient = new HTTPClient()
            oClient.setTimeout(nTimeout)
            oClient.setVerifySSL(false)

            # إرسال الطلب حسب النوع
            oResponse = NULL
            switch upper(cMethod)
                on "GET"
                    oResponse = oClient.getrequest(cURL, aHeaders)
                on "POST"
                    oResponse = oClient.post(cURL, cData, aHeaders)
                other
                    oResponse = oClient.request(cMethod, cURL, aHeaders, cData)
            off

            # تنظيف الموارد
            oClient.cleanup()

            # التحقق من نجاح الطلب
            if oResponse != NULL and oResponse[:success]
                see "HTTP request successful - Status: " + oResponse[:status_code] + nl
                return oResponse[:content]
            elseif oResponse != NULL and oResponse[:error] != NULL and oResponse[:error] != ""
                see "HTTP request failed: " + oResponse[:error] + nl
                return '{"error": "HTTP request failed: ' + oResponse[:error] + '"}'
            else
                see "HTTP request failed with status: " + oResponse[:status_code] + nl
                return '{"error": "HTTP request failed with status code: ' + oResponse[:status_code] + '"}'
            ok

        catch
            see "HTTP request error: " + cCatchError + nl
            return '{"error": "HTTP request failed: ' + cCatchError + '"}'
        done



    # ===================================================================
    # Parse Gemini Response
    # ===================================================================
    func parseGeminiResponse(cResponse)
        try
            # Check if response is empty or contains error
            if cResponse = "" or cResponse = null
                return createErrorResponse("Empty response from Gemini API")
            ok

            # Check for curl errors
            if substr(cResponse, "curl:")
                return createErrorResponse("Network error: " + cResponse)
            ok

            oResponse = json2list(cResponse)

            if type(oResponse) = "LIST" and len(oResponse) > 0
                oData = oResponse[1]

                # Check for API error
                if find(oData, "error")
                    oError = getValue(oData, "error", [])
                    if type(oError) = "LIST"
                        cErrorMsg = getValue(oError, "message", "Unknown error")
                        cErrorCode = getValue(oError, "code", "")
                        return createErrorResponse("Gemini API error [" + cErrorCode + "]: " + cErrorMsg)
                    else
                        return createErrorResponse("Gemini API error: " + oError)
                    ok
                ok

                # Extract content
                aCandidates = getValue(oData, "candidates", [])
                if type(aCandidates) = "LIST" and len(aCandidates) > 0
                    oCandidate = aCandidates[1]
                    if type(oCandidate) = "LIST"
                        oContent = getValue(oCandidate, "content", [])
                        if type(oContent) = "LIST"
                            aParts = getValue(oContent, "parts", [])
                            if type(aParts) = "LIST" and len(aParts) > 0
                                oPart = aParts[1]
                                if type(oPart) = "LIST"
                                    cText = getValue(oPart, "text", "")
                                    if cText != ""
                                        return createSuccessResponse(cText)
                                    ok
                                ok
                            ok
                        ok
                    ok
                ok
            ok

            return createErrorResponse("Invalid Gemini response format: " + left(cResponse, 100))

        catch
            return createErrorResponse("Failed to parse Gemini response: " + cCatchError + " | Response: " + left(cResponse, 100))
        done

    # ===================================================================
    # Parse OpenAI Response
    # ===================================================================
    func parseOpenAIResponse(cResponse)
        try
            oResponse = json2list(cResponse)

            if type(oResponse) = "LIST" and len(oResponse) > 0
                oData = oResponse[1]

                # Check for error
                if find(oData, "error")
                    oError = getValue(oData, "error", [])
                    cErrorMsg = getValue(oError, "message", "Unknown error")
                    return createErrorResponse("OpenAI API error: " + cErrorMsg)
                ok

                # Extract content
                aChoices = getValue(oData, "choices", [])
                if type(aChoices) = "LIST" and len(aChoices) > 0
                    oChoice = aChoices[1]
                    oMessage = getValue(oChoice, "message", [])
                    cContent = getValue(oMessage, "content", "")
                    return createSuccessResponse(cContent)
                ok
            ok

            return createErrorResponse("Invalid OpenAI response format")

        catch
            return createErrorResponse("Failed to parse OpenAI response: " + cCatchError)
        done

    # ===================================================================
    # Parse Claude Response
    # ===================================================================
    func parseClaudeResponse(cResponse)
        try
            oResponse = json2list(cResponse)

            if type(oResponse) = "LIST" and len(oResponse) > 0
                oData = oResponse[1]

                # Check for error
                if find(oData, "error")
                    oError = getValue(oData, "error", [])
                    cErrorMsg = getValue(oError, "message", "Unknown error")
                    return createErrorResponse("Claude API error: " + cErrorMsg)
                ok

                # Extract content
                aContent = getValue(oData, "content", [])
                if type(aContent) = "LIST" and len(aContent) > 0
                    oContentItem = aContent[1]
                    cText = getValue(oContentItem, "text", "")
                    return createSuccessResponse(cText)
                ok
            ok

            return createErrorResponse("Invalid Claude response format")

        catch
            return createErrorResponse("Failed to parse Claude response: " + cCatchError)
        done
