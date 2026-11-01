#!/bin/bash

# Jamf Script Parameters:
# Parameter 4: Halcyon install token

LOG_FILE="/var/log/halcyon_install_token.log"
TOKEN="$4"

DEST_DIR="/Library/Application Support/Halcyon/HalcyonAR"
DEST_FILE="$DEST_DIR/token.toml"
TMP_FILE="${DEST_FILE}.tmp"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

fail() {
    log "ERROR: $1"
    exit 1
}

# Must run as root
if [[ "$EUID" -ne 0 ]]; then
    fail "Script must run as root."
fi

# Trim leading/trailing whitespace from token
TOKEN="$(echo "$TOKEN" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [[ -z "$TOKEN" ]]; then
    fail "No token provided. Set the Halcyon install token as Jamf Parameter 4."
fi

log "Creating Halcyon token directory."

mkdir -p "$DEST_DIR" || fail "Failed to create $DEST_DIR"

chown root:wheel "$DEST_DIR" || fail "Failed to set ownership on $DEST_DIR"
chmod 755 "$DEST_DIR" || fail "Failed to set permissions on $DEST_DIR"

log "Writing Halcyon token file."

umask 077

# Write privately to a temporary file, then replace the destination so a
# policy interruption cannot leave a partially written token file in place.
cat > "$TMP_FILE" <<EOF
install_token = "$TOKEN"
EOF

if [[ ! -s "$TMP_FILE" ]]; then
    fail "Temporary token file was not created correctly."
fi

mv "$TMP_FILE" "$DEST_FILE" || fail "Failed to move token file into place."

chown root:wheel "$DEST_FILE" || fail "Failed to set ownership on $DEST_FILE"
chmod 600 "$DEST_FILE" || fail "Failed to set permissions on $DEST_FILE"

log "Halcyon token file created successfully at $DEST_FILE"

exit 0