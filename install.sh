#!/bin/bash
# Bash script to install an Avalanche node as a systemd service and automate its updates if desired
#git clone https://github.com/tdeso/avalanche_setup.git 
#cd avalanche_setup

#rm -rf install.sh
#rm -rf setup.sh
#rm -rf setupLibrary.sh
#rm -rf README.md
#rm -rf LICENSE

function getCurrentDir() {
    local current_dir="${BASH_SOURCE%/*}"
    if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
    echo "${current_dir}"
}

function includeDependencies() {
    # shellcheck source=./nodeLibrary.sh
    source "${current_dir}/setupLibrary.sh"
    source "${current_dir}/nodeLibrary.sh"
}

current_dir=$(getCurrentDir)
includeDependencies

echo '      _____               .__                       .__		  '
echo '     /  _  \___  _______  |  | _____    ____   ____ |  |__   ____   '
echo '    /  /_\  \  \/ /\__  \ |  | \__  \  /    \_/ ___\|  |  \_/ __ \  '
echo '   /    |    \   /  / __ \|  |__/ __ \|   |  \  \___|   Y  \  ___/  '
echo '   \____|__  /\_/  (____  /____(____  /___|  /\___  >___|  /\___  > '
echo '           \/           \/          \/     \/     \/     \/     \/  '

function main () {
    echo 'Updating packages...'
    sudo apt-get update -y
    sudo apt-get install -y jq perl
    sudo apt-get -y install gcc g++ make

    importScripts
    goInstall
    textVariables
    installAvalanche
    writemonitor

    if ask "Do you wish to enable automatic updates? " Y; then
        launchMonitor
        AUTO_UPDATE=yes
    fi

    launchAvalanche
    cleanup

    if [[ "${NODE_STATUS}" == "active" ]]; then
        launchedtext
        if [[ "${AUTO_UPDATE}" == "yes" ]]; then
            autoUpdatetext
        else
            updatetext
        fi
    elif [[ "${NODE_STATUS}" == "failed" ]]; then
        launchedFailedtext
    fi
    monitortext
}

disableSudoPassword $USER
main
