#!/usr/bin/env bash
# ------------------------------------------------------------------
# 
# Title:        pve-post-install.sh
# Description:  This script configures post installation options for Proxmox VE 7.x
# Author:       mckinie
# License:      MIT
# License URL:  https://github.com/mckinie/Proxmox/raw/main/LICENSE
#
# ------------------------------------------------------------------

# Variables
CYAN=$(echo "\033[1;36m")
NC=$(echo "\033[m")
LINE="-"
LOG_FILE="pve-post-install.log"

set -euo pipefail
shopt -s inherit_errexit nullglob

# Utility Functions
log() {
    local msg="$1"
    echo -ne " ${LINE} ${CYAN}${msg}${NC}" | tee -a $LOG_FILE
}

# Disable the "pve-enterprise" repository since we don't have a subscrption
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
log "Disabled 'pve-enterprise' repository\n"

# Enable the "pve-no-subscription" repository
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
log "Enabled 'pve-no-subscription' repository\n"

# Disable Subscription Warning in Proxmox
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
log "Disabled subscription nag message\n"

# Update Proxmox VE 7 
log "Updating Proxmox VE7 (may take some time)"
apt-get update &>/dev/null
apt-get -y dist-upgrade &>/dev/null
log "Update Complete\n"

# Reboot
log "Completed post install configuration, rebooting!"
reboot