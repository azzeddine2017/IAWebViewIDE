# ===================================================================
# File Manager Class - Handles all file operations
# ===================================================================

load "jsonlib.ring"
load "stdlib.ring"

class FileManager
    
    # Private properties
    aOpenFiles = []
    cFilesDirectory = "files"
    
    # ===================================================================
    # Constructor
    # ===================================================================
    func init()
        # Create files directory if it doesn't exist
        if not fexists(cFilesDirectory)
            system("mkdir " + cFilesDirectory)
        ok
        see "FileManager initialized." + nl
    
    # ===================================================================
    # Save File
    # ===================================================================
    func saveFile(id, req, oWebView)
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cContent = aParams[2]
            
            # Save file
            cFilePath = cFilesDirectory + "/" + cFileName
            write(cFilePath, cContent)
            
            # Add to open files list if not already there
            if find(aOpenFiles, cFileName) = 0
                aOpenFiles + cFileName
            ok
            
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
            see "File saved: " + cFileName + nl
            
        catch
            see "Error saving file: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
        done
    
    # ===================================================================
    # Load File
    # ===================================================================
    func loadFile(id, req, oWebView)
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cFilePath = cFilesDirectory + "/" + cFileName
            
            if fexists(cFilePath)
                cContent = read(cFilePath)
                cJsonContent = list2json([cContent])
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonContent)
                see "File loaded: " + cFileName + nl
            else
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, "null")
                see "File not found: " + cFileName + nl
            ok
            
        catch
            see "Error loading file: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "null")
        done
    
    # ===================================================================
    # Create New File
    # ===================================================================
    func createNewFile(id, req, oWebView)
       // try
       see "Creating new file..." + nl
       ? req
            aParams = json2list(req)
            cFileName = aParams[1]
            ? type(cFileName) ? list2code(cFileName)
            cFilePath = cFilesDirectory + "/" + cFileName
            
            # Create empty file if it doesn't exist
            if not fexists(cFilePath)
                cTemplate = getFileTemplate(cFileName)
                write(cFilePath, cTemplate)
                aOpenFiles + cFileName
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
                see "New file created: " + cFileName + nl
            else
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
                see "File already exists: " + cFileName + nl
            ok
            
       /* catch
            see "Error creating file: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
        done*/
    
    # ===================================================================
    # Delete File
    # ===================================================================
    func deleteFile(id, req, oWebView)
        try
            aParams = json2list(req)
            cFileName = aParams[1]
            cFilePath = cFilesDirectory + "/" + cFileName
            
            if fexists(cFilePath)
                remove(cFilePath)
                # Remove from open files list
                nIndex = find(aOpenFiles, cFileName)
                if nIndex > 0
                    del(aOpenFiles, nIndex)
                ok
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, "true")
                see "File deleted: " + cFileName + nl
            else
                oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
            ok
            
        catch
            see "Error deleting file: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "false")
        done
    
    # ===================================================================
    # Get File List
    # ===================================================================
    func getFileList(id, req, oWebView)
        try
            aFiles = []
            
            if fexists(cFilesDirectory)
                # Get list of files in the files directory
                cCommand = ""
                if iswindows()
                    cCommand = "dir " + cFilesDirectory + " /b"
                else
                    cCommand = "ls " + cFilesDirectory
                ok
                
                cResult = system(cCommand)
                aLines = str2list(cResult)
                
                for cLine in aLines
                    cLine = trim(cLine)
                    if len(cLine) > 0 and not substr(cLine, ".")
                        aFiles + cLine
                    ok
                next
            ok
            
            cJsonFiles = list2json(aFiles)
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, cJsonFiles)
            
        catch
            see "Error getting file list: " + cCatchError + nl
            oWebView.wreturn(id, WEBVIEW_ERROR_OK, "[]")
        done
    
    # ===================================================================
    # Get File Template
    # ===================================================================
    func getFileTemplate(cFileName)
        cTemplate = "# " + cFileName + nl + 
                   "# Created: " + date() + " " + time() + nl + nl
        
        # Add specific template based on file extension
        if substr(cFileName, ".ring")
            cTemplate += "load \"stdlib.ring\"" + nl + nl +
                        "func main()" + nl +
                        '    see \"Hello from ' + cFileName + '!\" + nl' + nl +
                        nl
        ok
        
        return cTemplate
