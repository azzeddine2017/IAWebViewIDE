# Simple Test
see "Testing basic functionality..." + nl

load "src/agent_tools.ring"
see "✓ AgentTools loaded" + nl

oTools = new AgentTools()
see "✓ AgentTools created" + nl

# Test write file
oResult = oTools.executeTool("write_file", ["test_hello.ring", "see " + char(34) + "Hello World!" + char(34) + " + nl"])
if oResult["success"]
    see "✓ File created successfully" + nl
else
    see "✗ File creation failed: " + oResult["error"] + nl
ok

see "Test completed." + nl
