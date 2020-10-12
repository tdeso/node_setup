#!/bin/bash
# Bash script to update an Avalanche node that runs as a service named avalanche

function getCurrentDir() {
    local current_dir="${BASH_SOURCE%/*}"
    if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
    echo "${current_dir}"
}

function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    source "${current_dir}/nodeLibrary.sh"
    source "${current_dir}/setupLibrary.sh"
}

current_dir=$(getCurrentDir)

includeDependencies

function node_version () {
  bac -f info.getNodeVersion | grep version | awk 'NR==1 {print $2}' | sed 's/avalanche//' | tr -d '\/"'
}

function monitorStatus () {
  systemctl -a list-units | grep -F 'monitor' | awk 'NR ==1 {print $4}' | tr -d \"
}

function updateAvalanche() {
  sudo apt-get -y update
  cd "${GOPATH}"/src/github.com/ava-labs/avalanchego
  git pull
  ./scripts/build.sh
  if [[ "${MONITOR_STATUS}" == "running" ]]; then    
  sudo systemctl restart monitor    
  fi
  sudo systemctl restart avalanche 
  NODE_VERSION2=$(eval node_version)
  NODE_STATUS=$(eval node_status)
  cleanup
}

function updateSuccesstext() {
  echo "${bold}##### AVALANCHE NODE SUCCESSFULLY UPDATED TO "${NODE_VERSION2}" #####${normal}"    
}

function updateFailedtext() {
  echo "${bold}##### AVALANCHE NODE UPDATE FAILED #####${normal}"    
}

function main () {
    echo '      _____               .__                       .__		      '
    echo '     /  _  \___  _______  |  | _____    ____   ____ |  |__   ____   '
    echo '    /  /_\  \  \/ /\__  \ |  | \__  \  /    \_/ ___\|  |  \_/ __ \  '
    echo '   /    |    \   /  / __ \|  |__/ __ \|   |  \  \___|   Y  \  ___/  '
    echo '   \____|__  /\_/  (____  /____(____  /___|  /\___  >___|  /\___  > '
    echo '           \/           \/          \/     \/     \/     \/     \/  '
    echo 'Updating Avalanche Node...'
    updateAvalanche

    if [[ "${NODE_STATUS}" == "active" && "${NODE_VERSION1}" != "${NODE_VERSION2}" ]]; then
        updateSuccesstext
    elif [[ "${NODE_STATUS}" == "active" && "${NODE_VERSION1}" == "${NODE_VERSION2}" ]]; then
        updateFailedtext
    elif [[ "${NODE_STATUS}" == "failed" ]]; then
        launchedFailedtext
    fi
    monitortext
}

disableSudoPassword $USER
NODE_VERSION1=$(eval node_version)
MONITOR_STATUS=$(eval monitorStatus)
main
