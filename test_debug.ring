# Test Debug File
see "Starting debug test..." + nl

try
    load "src/smart_agent.ring"
    see "✓ SmartAgent loaded successfully" + nl
    
    oAgent = new SmartAgent()
    see "✓ SmartAgent created successfully" + nl
    
    # Test simple request
    oResult = oAgent.processRequest("مرحبا", "")
    see "Result: " + list2code(oResult) + nl
    
catch
    see "✗ Error: " + cCatchError + nl
done

see "Debug test completed." + nl
