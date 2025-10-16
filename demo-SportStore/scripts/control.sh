#! /bin/bash
#

set -o errexit
set -o nounset
set -o pipefail

readonly PROVISIONING_SCRIPTS="/vagrant/scripts/"
source ${PROVISIONING_SCRIPTS}/util.sh

log "Starten van de control node provisioning"

log "Instaleren Python and pip"
sudo dnf install -y python3 python3-pip

log "Instaleren Ansible"
sudo pip3 install ansible

log "Adding /usr/local/bin to PATH"
echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /etc/profile.d/ansible.sh
export PATH=$PATH:/usr/local/bin

log "Kopiëren en beveiligen van de SSH private key voor SportStore"
SRC_KEY="/vagrant/.vagrant/machines/sportstore/virtualbox/private_key"
DEST_DIR="/home/vagrant/.ssh"
DEST_KEY="${DEST_DIR}/sportstore_private_key"

mkdir -p "${DEST_DIR}"
chmod 700 "${DEST_DIR}"

cp "${SRC_KEY}" "${DEST_KEY}"

chmod 600 "${DEST_KEY}"
chown -R vagrant:vagrant "${DEST_DIR}"

log "Installeren Ansible collections"
cd /vagrant/ansible
ansible-galaxy collection install -r requirements.yml

log "Control node ready"
