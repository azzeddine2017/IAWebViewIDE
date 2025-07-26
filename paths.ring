# ===================================================================
# Project Paths Configuration
# ===================================================================

# Get current directory with forward slashes
cCurrentDir = substr(currentdir(), "\", "/")

# Define paths
cSrcPath = cCurrentDir + "/src"
cAssetsPath = cCurrentDir + "/assets"
cFilesPath = cCurrentDir + "/files"
cTempPath = cCurrentDir + "/temp"

# Create required directories if they don't exist
if not direxists(cFilesPath)
    system("mkdir " + cFilesPath)
ok

if not direxists(cTempPath)
    system("mkdir " + cTempPath)
ok
