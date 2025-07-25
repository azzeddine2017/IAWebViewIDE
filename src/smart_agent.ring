# ===================================================================
# Smart Agent - Advanced AI Programming Assistant
# ===================================================================

load "ai_client.ring"
load "context_engine.ring"
load "agent_tools.ring"
load "jsonlib.ring"
load "stdlib.ring"

class SmartAgent
    
    # Core components
    oAIClient = null
    oContextEngine = null
    oAgentTools = null
    
    # Agent configuration
    cAgentName = "Ring Programming Assistant"
    cAgentVersion = "1.0"
    bDebugMode = false
    
    # Current session
    cCurrentProject = ""
    cCurrentFile = ""
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        # Initialize components
        oAIClient = new AIClient()
        oContextEngine = new ContextEngine()
        oAgentTools = new AgentTools()
        
        see "SmartAgent initialized successfully!" + nl
        see "Agent: " + cAgentName + " v" + cAgentVersion + nl
    
    # ===================================================================
    # Process User Request
    # ===================================================================
    func processRequest(cUserMessage, cCurrentCode)
        try
            # Add user message to context
            oContextEngine.addToHistory("user", cUserMessage, "chat")
            
            # Determine request type
            cRequestType = analyzeRequestType(cUserMessage)
            
            # Check if this is a tool request
            oToolRequest = parseToolRequest(cUserMessage)
            
            if oToolRequest["is_tool_request"]
                # Execute tool directly
                return executeToolRequest(oToolRequest, cCurrentCode)
            else
                # Send to AI for processing
                return sendToAI(cUserMessage, cRequestType, cCurrentCode)
            ok
            
        catch
            return createErrorResponse("Request processing failed: " + cCatchError)
        done
    
    # ===================================================================
    # Analyze Request Type
    # ===================================================================
    func analyzeRequestType(cMessage)
        cLowerMessage = lower(cMessage)
        
        # File operations
        if substr(cLowerMessage, "اكتب ملف") or substr(cLowerMessage, "احفظ") or 
           substr(cLowerMessage, "write file") or substr(cLowerMessage, "save")
            return "file_operation"
        ok
        
        # Code analysis
        if substr(cLowerMessage, "حلل") or substr(cLowerMessage, "تحليل") or
           substr(cLowerMessage, "analyze") or substr(cLowerMessage, "check")
            return "code_analysis"
        ok
        
        # Project management
        if substr(cLowerMessage, "مشروع") or substr(cLowerMessage, "project") or
           substr(cLowerMessage, "إنشاء") or substr(cLowerMessage, "create")
            return "project_management"
        ok
        
        # Default to general chat
        return "general_chat"
    
    # ===================================================================
    # Parse Tool Request
    # ===================================================================
    func parseToolRequest(cMessage)
        oResult = [
            "is_tool_request" = false,
            "tool_name" = "",
            "parameters" = []
        ]
        
        cLowerMessage = lower(cMessage)
        
        # Check for specific tool patterns
        if substr(cLowerMessage, "اكتب ملف") or substr(cLowerMessage, "write file")
            oResult["is_tool_request"] = true
            oResult["tool_name"] = "write_file"
            # Extract filename and content from message
            # This is a simplified parser - in production, use more sophisticated NLP
        ok
        
        if substr(cLowerMessage, "شغل الكود") or substr(cLowerMessage, "run code")
            oResult["is_tool_request"] = true
            oResult["tool_name"] = "run_ring_code"
        ok
        
        if substr(cLowerMessage, "اعرض الملفات") or substr(cLowerMessage, "list files")
            oResult["is_tool_request"] = true
            oResult["tool_name"] = "list_files"
            oResult["parameters"] = ["."]
        ok
        
        return oResult
    
    # ===================================================================
    # Execute Tool Request
    # ===================================================================
    func executeToolRequest(oToolRequest, cCurrentCode)
        try
            cToolName = oToolRequest["tool_name"]
            aParameters = oToolRequest["parameters"]
            
            # Add current code as parameter if needed
            if cToolName = "run_ring_code" and len(aParameters) = 0
                aParameters = [cCurrentCode]
            ok
            
            # Validate parameters
            aValidation = oAgentTools.validateToolParameters(cToolName, aParameters)
            if not aValidation[1]
                return createErrorResponse("Tool validation failed: " + aValidation[2])
            ok
            
            # Execute tool
            oResult = oAgentTools.executeTool(cToolName, aParameters)
            
            # Add result to context
            cResultMessage = ""
            if oResult["success"]
                cResultMessage = "Tool executed successfully: " + oResult["message"]
                oContextEngine.addFileContext(cToolName, "direct_execution", "success")
            else
                cResultMessage = "Tool execution failed: " + oResult["error"]
                oContextEngine.addFileContext(cToolName, "direct_execution", "error")
            ok
            
            oContextEngine.addToHistory("assistant", cResultMessage, "tool_result")
            
            return createSuccessResponse(cResultMessage)
            
        catch
            return createErrorResponse("Tool execution error: " + cCatchError)
        done
    
    # ===================================================================
    # Send to AI
    # ===================================================================
    func sendToAI(cMessage, cRequestType, cCurrentCode)
        try
            # Build context for AI
            aContext = oContextEngine.buildContext(cRequestType, cCurrentCode)
            cSystemPrompt = oContextEngine.getSystemPrompt(cRequestType)
            
            # Add current code to context if available
            if cCurrentCode != ""
                oContextEngine.addCodeContext(cCurrentFile, cCurrentCode, "ring")
            ok
            
            # Enhance message with tool information
            cEnhancedMessage = enhanceMessageWithTools(cMessage, cRequestType)
            
            # Send request to AI
            oAIResponse = oAIClient.sendChatRequest(cEnhancedMessage, cSystemPrompt, aContext)
            
            if oAIResponse["success"]
                cAIContent = oAIResponse["content"]
                
                # Check if AI wants to use tools
                oToolUsage = parseAIToolUsage(cAIContent)
                
                if oToolUsage["wants_to_use_tools"]
                    # Execute tools requested by AI
                    cToolResults = executeAIRequestedTools(oToolUsage["tools"])
                    cFinalResponse = cAIContent + nl + nl + "Tool Results:" + nl + cToolResults
                else
                    cFinalResponse = cAIContent
                ok
                
                # Add to conversation history
                oContextEngine.addToHistory("assistant", cFinalResponse, "ai_response")
                
                return createSuccessResponse(cFinalResponse)
            else
                return createErrorResponse(oAIResponse["error"])
            ok
            
        catch
            return createErrorResponse("AI processing failed: " + cCatchError)
        done
    
    # ===================================================================
    # Enhance Message with Tool Information
    # ===================================================================
    func enhanceMessageWithTools(cMessage, cRequestType)
        cEnhancedMessage = cMessage + nl + nl
        
        # Add available tools information
        cEnhancedMessage += "Available Tools:" + nl
        cEnhancedMessage += oAgentTools.getToolsList() + nl
        
        # Add instructions for tool usage
        cEnhancedMessage += nl + "Tool Usage Instructions:" + nl
        cEnhancedMessage += "To use a tool, include in your response:" + nl
        cEnhancedMessage += "TOOL_REQUEST: tool_name(parameter1, parameter2, ...)" + nl
        cEnhancedMessage += "You can request multiple tools in one response." + nl
        
        return cEnhancedMessage
    
    # ===================================================================
    # Parse AI Tool Usage
    # ===================================================================
    func parseAIToolUsage(cAIResponse)
        oResult = [
            "wants_to_use_tools" = false,
            "tools" = []
        ]
        
        # Look for TOOL_REQUEST patterns in AI response
        if substr(cAIResponse, "TOOL_REQUEST:")
            oResult["wants_to_use_tools"] = true
            
            # Extract tool requests (simplified parser)
            aLines = str2list(cAIResponse)
            for cLine in aLines
                if substr(cLine, "TOOL_REQUEST:")
                    cToolLine = substr(cLine, substr(cLine, "TOOL_REQUEST:") + 13)
                    cToolLine = trim(cToolLine)
                    
                    # Parse tool name and parameters
                    nParenPos = substr(cToolLine, "(")
                    if nParenPos > 0
                        cToolName = left(cToolLine, nParenPos - 1)
                        cParamsStr = substr(cToolLine, nParenPos + 1)
                        cParamsStr = left(cParamsStr, len(cParamsStr) - 1)  # Remove closing )
                        
                        # Split parameters (simplified)
                        aParams = str2list(cParamsStr)
                        
                        oResult["tools"] + [
                            "name" = trim(cToolName),
                            "parameters" = aParams
                        ]
                    ok
                ok
            next
        ok
        
        return oResult
    
    # ===================================================================
    # Execute AI Requested Tools
    # ===================================================================
    func executeAIRequestedTools(aTools)
        cResults = ""
        
        for oTool in aTools
            cToolName = oTool["name"]
            aParameters = oTool["parameters"]
            
            oResult = oAgentTools.executeTool(cToolName, aParameters)
            
            cResults += "Tool: " + cToolName + nl
            if oResult["success"]
                cResults += "Result: " + oResult["message"] + nl
            else
                cResults += "Error: " + oResult["error"] + nl
            ok
            cResults += nl
        next
        
        return cResults
    
    # ===================================================================
    # Utility Functions
    # ===================================================================
    func createSuccessResponse(cMessage)
        return [
            "success" = true,
            "message" = cMessage,
            "error" = ""
        ]
    
    func createErrorResponse(cError)
        return [
            "success" = false,
            "message" = "",
            "error" = cError
        ]
    
    # ===================================================================
    # Agent Management
    # ===================================================================
    func setCurrentProject(cProjectName)
        cCurrentProject = cProjectName
        oContextEngine.addProjectContext(cProjectName, "Current working project", [])
        see "Current project set to: " + cProjectName + nl
    
    func setCurrentFile(cFileName)
        cCurrentFile = cFileName
        see "Current file set to: " + cFileName + nl
    
    func setDebugMode(bEnabled)
        bDebugMode = bEnabled
        see "Debug mode: " + bEnabled + nl
    
    func getAgentStatus()
        cStatus = "Agent Status:" + nl
        cStatus += "Name: " + cAgentName + nl
        cStatus += "Version: " + cAgentVersion + nl
        cStatus += "Current Project: " + cCurrentProject + nl
        cStatus += "Current File: " + cCurrentFile + nl
        cStatus += "Debug Mode: " + bDebugMode + nl
        cStatus += "AI Provider: " + oAIClient.cCurrentProvider + nl
        
        return cStatus
