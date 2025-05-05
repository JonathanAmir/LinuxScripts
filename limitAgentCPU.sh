#!/bin/bash

##This script sets a limit to the AteraAgent.service CPU usage
## This script was tested on Ubuntu 24.04 and Debian 12.
## While it should work on other distros, please test beforehand

## This script is provided 'as-is' without any warranty or liability. Use at your own risk
## This script must be run with root permissions


# Define variables
LOG_FILE="/var/log/setAteraCPU.log"
SERVICE_FILE="/etc/systemd/system/AteraAgent.service"

# Create the log file if it doesn’t exist
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Starting Atera Agent CPU limit update..."

# Check if the service file exists
if [ ! -f "$SERVICE_FILE" ]; then
    log "Error: AteraAgent.service not found!"
    exit 1
fi

log "AteraAgent.service found. Proceeding with update."

# Backup the original file
cp "$SERVICE_FILE" "$SERVICE_FILE.bak"
log "Backup created: $SERVICE_FILE.bak"

# Check if CPUQuota is already set
if grep -q "CPUQuota=" "$SERVICE_FILE"; then
    log "CPUQuota is already set. Updating existing value..."
    sed -i 's/^CPUQuota=.*/CPUQuota=50%/' "$SERVICE_FILE"
else
    log "Adding CPUQuota=50% under [Service] section..."
    sed -i '/^\[Service\]/a CPUQuota=50%' "$SERVICE_FILE"
fi

# Reload systemd daemon
log "Reloading systemd daemon..."
systemctl daemon-reload && log "Systemd daemon reloaded successfully." || log "Error reloading systemd daemon."

# Restart Atera Agent service
log "Restarting AteraAgent service..."
systemctl restart AteraAgent && log "AteraAgent restarted successfully." || log "Error restarting AteraAgent."

log "Update completed successfully!"
exit 0
