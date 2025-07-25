# ===================================================================
# Context Engine - Advanced Context Management System
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"

class ContextEngine
    
    # Context storage
    aConversationHistory = []
    aProjectContext = []
    aCodeContext = []
    aFileContext = []
    
    # Configuration
    nMaxHistoryLength = 50
    nMaxContextTokens = 8000
    
    # Prompt templates
    cSystemPromptTemplate = ""
    cCodeAnalysisTemplate = ""
    cFileOperationTemplate = ""
    cProjectManagementTemplate = ""
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        loadPromptTemplates()
        see "ContextEngine initialized." + nl
    
    # ===================================================================
    # Load Prompt Templates
    # ===================================================================
    func loadPromptTemplates()
        try
            # Load system prompt template
            if fexists("prompts/system_prompt.txt")
                cSystemPromptTemplate = read("prompts/system_prompt.txt")
            else
                cSystemPromptTemplate = getDefaultSystemPrompt()
                createPromptFiles()
            ok
            
            # Load other templates
            if fexists("prompts/code_analysis.txt")
                cCodeAnalysisTemplate = read("prompts/code_analysis.txt")
            else
                cCodeAnalysisTemplate = getDefaultCodeAnalysisPrompt()
            ok
            
            if fexists("prompts/file_operation.txt")
                cFileOperationTemplate = read("prompts/file_operation.txt")
            else
                cFileOperationTemplate = getDefaultFileOperationPrompt()
            ok
            
            if fexists("prompts/project_management.txt")
                cProjectManagementTemplate = read("prompts/project_management.txt")
            else
                cProjectManagementTemplate = getDefaultProjectManagementPrompt()
            ok
            
        catch
            see "Warning: Could not load prompt templates: " + cCatchError + nl
            setDefaultTemplates()
        done
    
    # ===================================================================
    # Create Prompt Files
    # ===================================================================
    func createPromptFiles()
        try
            if not fexists("prompts")
                system("mkdir prompts")
            ok
            
            write("prompts/system_prompt.txt", getDefaultSystemPrompt())
            write("prompts/code_analysis.txt", getDefaultCodeAnalysisPrompt())
            write("prompts/file_operation.txt", getDefaultFileOperationPrompt())
            write("prompts/project_management.txt", getDefaultProjectManagementPrompt())
            
            see "Created default prompt templates in prompts/ directory" + nl
            
        catch
            see "Error creating prompt files: " + cCatchError + nl
        done
    
    # ===================================================================
    # Add Message to Conversation History
    # ===================================================================
    func addToHistory(cRole, cMessage, cType)
        oHistoryItem = [
            "role" = cRole,
            "content" = cMessage,
            "type" = cType,
            "timestamp" = date() + " " + time()
        ]
        
        aConversationHistory + oHistoryItem
        
        # Trim history if too long
        if len(aConversationHistory) > nMaxHistoryLength
            del(aConversationHistory, 1)
        ok
    
    # ===================================================================
    # Add Project Context
    # ===================================================================
    func addProjectContext(cProjectName, cDescription, aFiles)
        oProjectContext = [
            "name" = cProjectName,
            "description" = cDescription,
            "files" = aFiles,
            "timestamp" = date() + " " + time()
        ]
        
        aProjectContext = [oProjectContext]  # Keep only current project
    
    # ===================================================================
    # Add Code Context
    # ===================================================================
    func addCodeContext(cFileName, cCode, cLanguage)
        oCodeContext = [
            "filename" = cFileName,
            "code" = cCode,
            "language" = cLanguage,
            "timestamp" = date() + " " + time()
        ]
        
        # Add to code context array
        aCodeContext + oCodeContext
        
        # Keep only recent code contexts (max 10)
        if len(aCodeContext) > 10
            del(aCodeContext, 1)
        ok
    
    # ===================================================================
    # Add File Context
    # ===================================================================
    func addFileContext(cOperation, cFileName, cResult)
        oFileContext = [
            "operation" = cOperation,
            "filename" = cFileName,
            "result" = cResult,
            "timestamp" = date() + " " + time()
        ]
        
        aFileContext + oFileContext
        
        # Keep only recent file operations (max 20)
        if len(aFileContext) > 20
            del(aFileContext, 1)
        ok
    
    # ===================================================================
    # Build Context for AI Request
    # ===================================================================
    func buildContext(cRequestType, cCurrentCode)
        aContext = []
        
        # Add relevant conversation history
        nHistoryCount = 0
        for i = len(aConversationHistory) to 1 step -1
            if nHistoryCount < 10  # Last 10 messages
                oItem = aConversationHistory[i]
                aContext + [
                    "role" = oItem["role"],
                    "content" = oItem["content"]
                ]
                nHistoryCount++
            ok
        next
        
        # Add project context if available
        if len(aProjectContext) > 0
            oProject = aProjectContext[1]
            cProjectInfo = "Current Project: " + oProject["name"] + nl +
                          "Description: " + oProject["description"] + nl +
                          "Files: " + list2str(oProject["files"])
            
            aContext + [
                "role" = "system",
                "content" = cProjectInfo
            ]
        ok
        
        # Add current code context
        if cCurrentCode != ""
            aContext + [
                "role" = "system", 
                "content" = "Current Code:\n" + cCurrentCode
            ]
        ok
        
        # Add recent file operations for file-related requests
        if cRequestType = "file_operation" and len(aFileContext) > 0
            cFileOps = "Recent File Operations:\n"
            for i = len(aFileContext) to max(1, len(aFileContext)-5) step -1
                oFileOp = aFileContext[i]
                cFileOps += oFileOp["operation"] + ": " + oFileOp["filename"] + 
                           " -> " + oFileOp["result"] + nl
            next
            
            aContext + [
                "role" = "system",
                "content" = cFileOps
            ]
        ok
        
        return aContext
    
    # ===================================================================
    # Get System Prompt for Request Type
    # ===================================================================
    func getSystemPrompt(cRequestType)
        switch cRequestType
            on "code_analysis"
                return cCodeAnalysisTemplate
            on "file_operation"
                return cFileOperationTemplate
            on "project_management"
                return cProjectManagementTemplate
            other
                return cSystemPromptTemplate
        off
    
    # ===================================================================
    # Default Prompt Templates
    # ===================================================================
    func getDefaultSystemPrompt()
        return `أنت مساعد ذكي متخصص في البرمجة بلغة Ring. لديك القدرة على:

1. تحليل وشرح الكود
2. كتابة وتعديل الملفات
3. تشغيل وتصحيح البرامج
4. إدارة المشاريع البرمجية
5. تقديم اقتراحات وحلول برمجية

قواعد مهمة:
- اكتب الكود بوضوح ومع التعليقات
- اتبع أفضل الممارسات في البرمجة
- قدم شرحاً مفصلاً للحلول
- تأكد من صحة الكود قبل تقديمه
- استخدم اللغة العربية في الشرح والتعليقات

أدواتك المتاحة:
- كتابة وقراءة الملفات
- تشغيل كود Ring
- تحليل بنية المشاريع
- إدارة نظام Git
- البحث في الملفات والمجلدات`
    
    func getDefaultCodeAnalysisPrompt()
        return `أنت محلل كود متخصص في لغة Ring. مهمتك:

1. تحليل الكود المقدم بدقة
2. اكتشاف الأخطاء والمشاكل
3. اقتراح تحسينات وتطويرات
4. شرح منطق الكود ووظائفه
5. تقديم أمثلة وبدائل أفضل

ركز على:
- صحة الصيغة (Syntax)
- كفاءة الأداء
- قابلية القراءة
- أمان الكود
- اتباع معايير Ring`
    
    func getDefaultFileOperationPrompt()
        return `أنت مدير ملفات ذكي. يمكنك:

1. إنشاء وحذف الملفات والمجلدات
2. قراءة وكتابة محتوى الملفات
3. نسخ ونقل الملفات
4. البحث في الملفات
5. إدارة صلاحيات الملفات

احرص على:
- التأكد من صحة المسارات
- عمل نسخ احتياطية عند الحاجة
- التحقق من الصلاحيات
- تجنب الكتابة فوق ملفات مهمة
- تنظيم بنية المجلدات`
    
    func getDefaultProjectManagementPrompt()
        return `أنت مدير مشاريع برمجية ذكي. تساعد في:

1. تخطيط وتنظيم المشاريع
2. إدارة الملفات والمجلدات
3. تتبع التقدم والمهام
4. إدارة نظام Git
5. توثيق المشاريع

مبادئك:
- التنظيم والوضوح
- اتباع أفضل الممارسات
- التوثيق الشامل
- إدارة الإصدارات
- التعاون الفعال`
    
    # ===================================================================
    # Set Default Templates
    # ===================================================================
    func setDefaultTemplates()
        cSystemPromptTemplate = getDefaultSystemPrompt()
        cCodeAnalysisTemplate = getDefaultCodeAnalysisPrompt()
        cFileOperationTemplate = getDefaultFileOperationPrompt()
        cProjectManagementTemplate = getDefaultProjectManagementPrompt()
    
    # ===================================================================
    # Clear Context
    # ===================================================================
    func clearHistory()
        aConversationHistory = []
        see "Conversation history cleared." + nl
    
    func clearProjectContext()
        aProjectContext = []
        see "Project context cleared." + nl
    
    func clearCodeContext()
        aCodeContext = []
        see "Code context cleared." + nl
    
    func clearFileContext()
        aFileContext = []
        see "File context cleared." + nl
