# Debug Tools Test
load "src/agent_tools.ring"

func main()
    see "=== Debug Tools Test ===" + nl
    
    oTools = new AgentTools()
    
    see "Number of tools: " + len(oTools.aAvailableTools) + nl
    
    # Print first few tools directly
    for i = 1 to 3
        if i <= len(oTools.aAvailableTools)
            oTool = oTools.aAvailableTools[i]
            see "Tool " + i + ":" + nl
            see "  Name: '" + oTool.name + "'" + nl
            see "  Description: '" + oTool.description + "'" + nl
            see "  Category: '" + oTool.category + "'" + nl
            see nl
        ok
    next
    
    see "=== Tools List Output ===" + nl
    cList = oTools.getToolsList()
    see cList + nl
