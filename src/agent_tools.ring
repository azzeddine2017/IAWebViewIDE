# ===================================================================
# Agent Tools - Advanced Tools for AI Agent
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"

class AgentTools
    
    # Tool registry
    aAvailableTools = []
    
    # Working directory
    cWorkingDirectory = ""
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        cWorkingDirectory = CurrentDir()
        registerTools()
        see "AgentTools initialized with " + len(aAvailableTools) + " tools." + nl
    
    # ===================================================================
    # Register Available Tools
    # ===================================================================
    func registerTools()
        # File operations
        aAvailableTools + createTool("write_file", "Write content to a file", 
            ["filename", "content"], "file_operation")
        aAvailableTools + createTool("read_file", "Read content from a file", 
            ["filename"], "file_operation")
        aAvailableTools + createTool("delete_file", "Delete a file", 
            ["filename"], "file_operation")
        aAvailableTools + createTool("list_files", "List files in directory", 
            ["directory"], "file_operation")
        aAvailableTools + createTool("create_directory", "Create a new directory", 
            ["directory_name"], "file_operation")
        
        # Code operations
        aAvailableTools + createTool("run_ring_code", "Execute Ring code", 
            ["code"], "code_execution")
        aAvailableTools + createTool("analyze_code", "Analyze Ring code for errors and improvements", 
            ["code"], "code_analysis")
        aAvailableTools + createTool("format_code", "Format Ring code with proper indentation", 
            ["code"], "code_formatting")
        
        # Project operations
        aAvailableTools + createTool("create_project", "Create a new Ring project structure", 
            ["project_name", "project_type"], "project_management")
        aAvailableTools + createTool("analyze_project", "Analyze project structure and dependencies", 
            ["project_path"], "project_analysis")
        
        # Git operations
        aAvailableTools + createTool("git_init", "Initialize Git repository", 
            [], "git_operation")
        aAvailableTools + createTool("git_status", "Get Git repository status", 
            [], "git_operation")
        aAvailableTools + createTool("git_add", "Add files to Git staging", 
            ["files"], "git_operation")
        aAvailableTools + createTool("git_commit", "Commit changes to Git", 
            ["message"], "git_operation")
        
        # System operations
        aAvailableTools + createTool("execute_command", "Execute system command", 
            ["command"], "system_operation")
        aAvailableTools + createTool("search_in_files", "Search for text in files", 
            ["search_term", "directory"], "search_operation")
    
    # ===================================================================
    # Create Tool Definition
    # ===================================================================
    func createTool(cName, cDescription, aParameters, cCategory)
        oTool = new stdclass
        oTool.name = cName
        oTool.description = cDescription
        oTool.parameters = aParameters
        oTool.category = cCategory
        return oTool
    
    # ===================================================================
    # Execute Tool
    # ===================================================================
    func executeTool(cToolName, aParameters)
        try
            switch cToolName
                # File operations
                on "write_file"
                    return writeFile(aParameters[1], aParameters[2])
                on "read_file"
                    return readFile(aParameters[1])
                on "delete_file"
                    return deleteFile(aParameters[1])
                on "list_files"
                    return listFiles(aParameters[1])
                on "create_directory"
                    return createDirectory(aParameters[1])
                
                # Code operations
                on "run_ring_code"
                    return runRingCode(aParameters[1])
                on "analyze_code"
                    return analyzeCode(aParameters[1])
                on "format_code"
                    return formatCode(aParameters[1])
                
                # Project operations
                on "create_project"
                    return createProject(aParameters[1], aParameters[2])
                on "analyze_project"
                    return analyzeProject(aParameters[1])
                
                # Git operations
                on "git_init"
                    return gitInit()
                on "git_status"
                    return gitStatus()
                on "git_add"
                    return gitAdd(aParameters[1])
                on "git_commit"
                    return gitCommit(aParameters[1])
                
                # System operations
                on "execute_command"
                    return executeCommand(aParameters[1])
                on "search_in_files"
                    return searchInFiles(aParameters[1], aParameters[2])
                
                other
                    return createErrorResult("Unknown tool: " + cToolName)
            off
            
        catch
            return createErrorResult("Tool execution failed: " + cCatchError)
        done
    
    # ===================================================================
    # File Operations
    # ===================================================================
    func writeFile(cFileName, cContent)
        try
            write(cFileName, cContent)
            return createSuccessResult("File written successfully: " + cFileName)
        catch
            return createErrorResult("Failed to write file: " + cCatchError)
        done
    
    func readFile(cFileName)
        try
            if fexists(cFileName)
                cContent = read(cFileName)
                return createSuccessResult("File content:\n" + cContent)
            else
                return createErrorResult("File not found: " + cFileName)
            ok
        catch
            return createErrorResult("Failed to read file: " + cCatchError)
        done
    
    func deleteFile(cFileName)
        try
            if fexists(cFileName)
                remove(cFileName)
                return createSuccessResult("File deleted successfully: " + cFileName)
            else
                return createErrorResult("File not found: " + cFileName)
            ok
        catch
            return createErrorResult("Failed to delete file: " + cCatchError)
        done
    
    func listFiles(cDirectory)
        try
            if cDirectory = ""
                cDirectory = "."
            ok
            
            cCommand = ""
            if iswindows()
                cCommand = "dir " + cDirectory + " /b"
            else
                cCommand = "ls " + cDirectory
            ok
            
            cResult = system(cCommand)
            return createSuccessResult("Files in " + cDirectory + ":\n" + cResult)
            
        catch
            return createErrorResult("Failed to list files: " + cCatchError)
        done
    
    func createDirectory(cDirName)
        try
            if not fexists(cDirName)
                system("mkdir " + cDirName)
                return createSuccessResult("Directory created: " + cDirName)
            else
                return createErrorResult("Directory already exists: " + cDirName)
            ok
        catch
            return createErrorResult("Failed to create directory: " + cCatchError)
        done
    
    # ===================================================================
    # Code Operations
    # ===================================================================
    func runRingCode(cCode)
        try
            # Save code to temporary file
            cTempFile = "temp_code_" + clock() + ".ring"
            write(cTempFile, cCode)
            
            # Execute the code
            cCommand = "ring " + cTempFile
            cResult = system(cCommand)
            
            # Clean up
            if fexists(cTempFile)
                remove(cTempFile)
            ok
            
            return createSuccessResult("Code execution result:\n" + cResult)
            
        catch
            return createErrorResult("Code execution failed: " + cCatchError)
        done
    
    func analyzeCode(cCode)
        try
            cAnalysis = "Code Analysis Report:\n\n"
            
            # Basic analysis
            aLines = str2list(cCode)
            nLines = len(aLines)
            cAnalysis += "Lines of code: " + nLines + nl
            
            # Count functions and classes
            nFunctions = 0
            nClasses = 0
            for cLine in aLines
                cTrimmedLine = trim(cLine)
                if substr(cTrimmedLine, "func ")
                    nFunctions++
                ok
                if substr(cTrimmedLine, "class ")
                    nClasses++
                ok
            next
            
            cAnalysis += "Functions: " + nFunctions + nl
            cAnalysis += "Classes: " + nClasses + nl + nl
            
            # Check for common issues
            cAnalysis += "Potential Issues:\n"
            nIssues = 0
            
            # Check for unbalanced braces
            nOpenBraces = 0
            nCloseBraces = 0
            for cLine in aLines
                nOpenBraces += substr_count(cLine, "{")
                nCloseBraces += substr_count(cLine, "}")
            next
            
            if nOpenBraces != nCloseBraces
                cAnalysis += "- Unbalanced braces detected\n"
                nIssues++
            ok
            
            # Check for missing main function
            bHasMain = false
            for cLine in aLines
                if substr(trim(cLine), "func main")
                    bHasMain = true
                    exit
                ok
            next
            
            if not bHasMain and nLines > 5
                cAnalysis += "- No main() function found\n"
                nIssues++
            ok
            
            if nIssues = 0
                cAnalysis += "- No obvious issues detected\n"
            ok
            
            return createSuccessResult(cAnalysis)
            
        catch
            return createErrorResult("Code analysis failed: " + cCatchError)
        done
    
    func formatCode(cCode)
        try
            # Basic Ring code formatting
            aLines = str2list(cCode)
            aFormattedLines = []
            nIndentLevel = 0
            
            for cLine in aLines
                cTrimmedLine = trim(cLine)
                
                # Handle closing keywords
                if substr(cTrimmedLine, "}") or 
                   substr(cTrimmedLine, "next") or 
                   substr(cTrimmedLine, "ok") or
                   substr(cTrimmedLine, "done")
                    nIndentLevel--
                    if nIndentLevel < 0
                        nIndentLevel = 0
                    ok
                ok
                
                # Add indentation
                cIndent = copy("    ", nIndentLevel)
                if len(cTrimmedLine) > 0
                    aFormattedLines + cIndent + cTrimmedLine
                else
                    aFormattedLines + ""
                ok
                
                # Handle opening keywords
                if substr(cTrimmedLine, "{") or 
                   substr(cTrimmedLine, "for ") or 
                   substr(cTrimmedLine, "while ") or
                   substr(cTrimmedLine, "if ") or
                   substr(cTrimmedLine, "func ") or
                   substr(cTrimmedLine, "class ") or
                   substr(cTrimmedLine, "try")
                    nIndentLevel++
                ok
            next
            
            cFormattedCode = list2str(aFormattedLines)
            return createSuccessResult("Formatted code:\n" + cFormattedCode)
            
        catch
            return createErrorResult("Code formatting failed: " + cCatchError)
        done
    
    # ===================================================================
    # Utility Functions
    # ===================================================================
    func createSuccessResult(cMessage)
        return [
            "success" = true,
            "message" = cMessage,
            "error" = ""
        ]
    
    func createErrorResult(cError)
        return [
            "success" = false,
            "message" = "",
            "error" = cError
        ]
    
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

    # ===================================================================
    # Project Operations
    # ===================================================================
    func createProject(cProjectName, cProjectType)
        try
            if fexists(cProjectName)
                return createErrorResult("Project directory already exists: " + cProjectName)
            ok

            # Create project directory
            system("mkdir " + cProjectName)

            # Create basic project structure
            system("mkdir " + cProjectName + "/src")
            system("mkdir " + cProjectName + "/docs")
            system("mkdir " + cProjectName + "/tests")

            # Create main.ring file
            cMainContent = "# " + cProjectName + " - Ring Project" + nl +
                          "# Created: " + date() + " " + time() + nl + nl +
                          "load \"stdlib.ring\"" + nl + nl +
                          "func main()" + nl +
                          '    see \"Welcome to ' + cProjectName + '!\" + nl' + nl +
                          "ok" + nl

            write(cProjectName + "/main.ring", cMainContent)

            # Create README.md
            cReadmeContent = "# " + cProjectName + nl + nl +
                           "Ring programming project created on " + date() + nl + nl +
                           "## Structure" + nl +
                           "- `src/` - Source code files" + nl +
                           "- `docs/` - Documentation" + nl +
                           "- `tests/` - Test files" + nl +
                           "- `main.ring` - Main application file" + nl

            write(cProjectName + "/README.md", cReadmeContent)

            return createSuccessResult("Project created successfully: " + cProjectName)

        catch
            return createErrorResult("Failed to create project: " + cCatchError)
        done

    func analyzeProject(cProjectPath)
        try
            if not fexists(cProjectPath)
                return createErrorResult("Project path not found: " + cProjectPath)
            ok

            cAnalysis = "Project Analysis: " + cProjectPath + nl + nl

            # Count files by type
            nRingFiles = 0
            nTotalFiles = 0

            # Analyze main directory
            cCommand = ""
            if iswindows()
                cCommand = "dir " + cProjectPath + " /s /b"
            else
                cCommand = "find " + cProjectPath + " -type f"
            ok

            cFileList = system(cCommand)
            aFiles = str2list(cFileList)

            for cFile in aFiles
                cFile = trim(cFile)
                if len(cFile) > 0
                    nTotalFiles++
                    if substr(cFile, ".ring")
                        nRingFiles++
                    ok
                ok
            next

            cAnalysis += "Total files: " + nTotalFiles + nl
            cAnalysis += "Ring files: " + nRingFiles + nl + nl

            # Check for standard project structure
            cAnalysis += "Project Structure:" + nl
            if fexists(cProjectPath + "/main.ring")
                cAnalysis += "✓ main.ring found" + nl
            else
                cAnalysis += "✗ main.ring missing" + nl
            ok

            if fexists(cProjectPath + "/src")
                cAnalysis += "✓ src/ directory found" + nl
            else
                cAnalysis += "✗ src/ directory missing" + nl
            ok

            if fexists(cProjectPath + "/README.md")
                cAnalysis += "✓ README.md found" + nl
            else
                cAnalysis += "✗ README.md missing" + nl
            ok

            return createSuccessResult(cAnalysis)

        catch
            return createErrorResult("Project analysis failed: " + cCatchError)
        done

    # ===================================================================
    # Git Operations
    # ===================================================================
    func gitInit()
        try
            cResult = system("git init")
            return createSuccessResult("Git repository initialized:\n" + cResult)
        catch
            return createErrorResult("Git init failed: " + cCatchError)
        done

    func gitStatus()
        try
            cResult = system("git status")
            return createSuccessResult("Git status:\n" + cResult)
        catch
            return createErrorResult("Git status failed: " + cCatchError)
        done

    func gitAdd(cFiles)
        try
            cCommand = "git add " + cFiles
            cResult = system(cCommand)
            return createSuccessResult("Files added to Git:\n" + cResult)
        catch
            return createErrorResult("Git add failed: " + cCatchError)
        done

    func gitCommit(cMessage)
        try
            cCommand = 'git commit -m "' + cMessage + '"'
            cResult = system(cCommand)
            return createSuccessResult("Git commit completed:\n" + cResult)
        catch
            return createErrorResult("Git commit failed: " + cCatchError)
        done

    # ===================================================================
    # System Operations
    # ===================================================================
    func executeCommand(cCommand)
        try
            cResult = system(cCommand)
            return createSuccessResult("Command executed:\n" + cResult)
        catch
            return createErrorResult("Command execution failed: " + cCatchError)
        done

    func searchInFiles(cSearchTerm, cDirectory)
        try
            if cDirectory = ""
                cDirectory = "."
            ok

            cCommand = ""
            if iswindows()
                cCommand = 'findstr /s /i "' + cSearchTerm + '" ' + cDirectory + '\*.*'
            else
                cCommand = 'grep -r "' + cSearchTerm + '" ' + cDirectory
            ok

            cResult = system(cCommand)

            if len(cResult) > 0
                return createSuccessResult("Search results for '" + cSearchTerm + "':\n" + cResult)
            else
                return createSuccessResult("No matches found for '" + cSearchTerm + "'")
            ok

        catch
            return createErrorResult("Search failed: " + cCatchError)
        done

    # ===================================================================
    # Get Available Tools List
    # ===================================================================
    func getToolsList()
        cToolsList = "Available Tools:" + nl + nl

        cCurrentCategory = ""
        for oTool in aAvailableTools
            if oTool.category != cCurrentCategory
                cCurrentCategory = oTool.category
                cToolsList += "=== " + cCurrentCategory + " ===" + nl
            ok

            cToolsList += "• " + oTool.name + ": " + oTool.description + nl
        next

        return cToolsList

    # ===================================================================
    # Validate Tool Parameters
    # ===================================================================
    func validateToolParameters(cToolName, aParameters)
        # Find tool definition
        oTool = null
        for oToolDef in aAvailableTools
            if oToolDef["name"] = cToolName
                oTool = oToolDef
                exit
            ok
        next

        if oTool = null
            return [false, "Tool not found: " + cToolName]
        ok

        # Check parameter count
        aRequiredParams = oTool["parameters"]
        if len(aParameters) != len(aRequiredParams)
            return [false, "Expected " + len(aRequiredParams) + " parameters, got " + len(aParameters)]
        ok

        return [true, "Parameters valid"]
