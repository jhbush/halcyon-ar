#!/bin/zsh --no-rcs

###############################################################################
#
# Script Name: Create Halcyon LaunchAgent
#
# Description:
# Creates and loads a LaunchAgent that automatically opens the
# Halcyon AR application at user login.
#
# The LaunchAgent is installed to:
# /Library/LaunchAgents/ai.halcyon.agent.UserAgent.plist
#
# The LaunchAgent uses:
# /usr/bin/open -ga "/Applications/Halcyon AR.app"
#
# This script:
#   - Verifies Halcyon AR.app is installed
#   - Creates or updates the LaunchAgent
#   - Removes any previously loaded version
#   - Sets appropriate ownership and permissions
#   - Loads the LaunchAgent for the currently logged-in user
#
# Requirements:
#   - macOS
#   - Halcyon AR.app installed in /Applications
#   - Must be run as root (Jamf Pro policy)
#
# Notes:
#   - The application will launch at user login
#   - This LaunchAgent does not relaunch the application if the
#     user manually quits or force quits it
#   - Safe to run multiple times
#
# Version: 1.0
# Last Updated: 2026-06-16
#
###############################################################################

APP_PATH="/Applications/Halcyon AR.app"
LABEL="ai.halcyon.agent.UserAgent"
PLIST_PATH="/Library/LaunchAgents/${LABEL}.plist"

CURRENT_USER="$(stat -f "%Su" /dev/console)"
USER_UID="$(id -u "$CURRENT_USER" 2>/dev/null)"

if [[ "$CURRENT_USER" == "root" || -z "$USER_UID" ]]; then
	echo "ERROR: No logged-in user detected."
	exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
	echo "ERROR: $APP_PATH not found."
	exit 1
fi

# Remove any existing loaded version of the LaunchAgent before
# creating and loading the updated version.
launchctl bootout "gui/$USER_UID/$LABEL" 2>/dev/null
launchctl bootout "gui/$USER_UID" "$PLIST_PATH" 2>/dev/null

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$LABEL</string>

	<key>ProgramArguments</key>
	<array>
		<string>/usr/bin/open</string>
		<string>-ga</string>
		<string>$APP_PATH</string>
	</array>

	<key>RunAtLoad</key>
	<true/>

	<key>LimitLoadToSessionType</key>
	<string>Aqua</string>
</dict>
</plist>
EOF

chown root:wheel "$PLIST_PATH"
chmod 644 "$PLIST_PATH"

plutil -lint "$PLIST_PATH" || exit 1

launchctl bootstrap "gui/$USER_UID" "$PLIST_PATH" 2>/dev/null

if [[ $? -ne 0 ]]; then
	echo "ERROR: Failed to bootstrap LaunchAgent."
	exit 1
fi

launchctl enable "gui/$USER_UID/$LABEL" 2>/dev/null

echo "LaunchAgent created and loaded successfully."
echo "User: $CURRENT_USER"
echo "App: $APP_PATH"
echo "Plist: $PLIST_PATH"

exit 0