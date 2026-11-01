#!/bin/sh

# Reports whether the Halcyon system extension identifier appears in the
# systemextensionsctl inventory.

result=false
APP_PATH="/Applications/Halcyon AR.app"
BUNDLE_ID="ai.halcyon.agent.halcyonard"

# Only report a match when the app is installed and macOS lists the identifier;
# Jamf consumes the result XML below.
if [ -d "$APP_PATH" ]; then
    if systemextensionsctl list 2>/dev/null | grep -q "$BUNDLE_ID"; then
        result=true
    fi
fi

echo "<result>$result</result>"