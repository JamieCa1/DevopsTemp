#! /bin/bash
#

set -o errexit
set -o nounset
set -o pipefail

readonly PROVISIONING_SCRIPTS="/vagrant/scripts/"
source ${PROVISIONING_SCRIPTS}/util.sh

log "Starten SportStore server provisioning"

log "Instaleren python3 voor Ansible"
sudo apt-get update
sudo apt-get install -y python3

log "Server ready voor Ansible provisioning"
