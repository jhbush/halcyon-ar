#!/bin/sh

# Reports whether the Halcyon system extension is loaded

result=false
APP_PATH="/Applications/Halcyon AR.app"
BUNDLE_ID="ai.halcyon.agent.halcyonard"

if [ -d "$APP_PATH" ]; then
    if systemextensionsctl list 2>/dev/null | grep -q "$BUNDLE_ID"; then
        result=true
    fi
fi

echo "<result>$result</result>"