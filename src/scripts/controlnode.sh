#! /bin/bash
#

#--------- Bash settings ------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#--------- Variables ----------------------------------------------------------

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/scripts/"
export PROVISIONING_SCRIPTS
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/${HOSTNAME}"
export PROVISIONING_FILES

#---------- Load utility functions --------------------------------------------

source ${PROVISIONING_SCRIPTS}/util.sh

#---------- Provision host ----------------------------------------------------

log "Starting server specific provisioning tasks on host ${HOSTNAME}"

log "Installing Ansible and dependencies"

dnf install --assumeyes \
  epel-release

dnf install --assumeyes \
  bash-completion \
  bats \
  bind-utils \
  mc \
  psmisc \
  python3-libselinux \
  python3-libsemanage \
  python3-netaddr \
  python3-pip \
  python3-PyMySQL \
  tree \
  vim-enhanced

sudo --login --non-interactive --user=vagrant -- \
  pip install ansible

log "Installing Ansible Galaxy roles and collections"
sudo --login --non-interactive --user=vagrant -- \
  ansible-galaxy install -r /vagrant/ansible/requirements.yml

sudo --login --non-interactive --user=vagrant -- \
  ansible-galaxy collection install -r /vagrant/ansible/requirements.yml

log "Kopiëren en beveiligen van de SSH private key voor target VMs"

# Create .ssh directory first
DEST_DIR="/home/vagrant/.ssh"
sudo --login --non-interactive --user=vagrant -- \
  mkdir -p "${DEST_DIR}"
sudo --login --non-interactive --user=vagrant -- \
  chmod 700 "${DEST_DIR}"

# Copy SSH keys for all target VMs
for host in application database build-monitor; do
  SRC_KEY="/vagrant/.vagrant/machines/${host}/virtualbox/private_key"
  DEST_KEY="${DEST_DIR}/${host}_private_key"

  if [[ -f "${SRC_KEY}" ]]; then
    sudo --login --non-interactive --user=vagrant -- \
      cp "${SRC_KEY}" "${DEST_KEY}"

    sudo --login --non-interactive --user=vagrant -- \
      chmod 600 "${DEST_KEY}"

    log "SSH key voor ${host} succesvol gekopieerd en beveiligd"
  else
    log "Warning: SSH key voor ${host} nog niet gevonden - zal beschikbaar zijn wanneer VM draait"
  fi
done