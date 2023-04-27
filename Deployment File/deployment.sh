#!/bin/bash

#Standalone script to run the deployment from source machine [Linux] having SSH enabled

SERVER="127.0.0.1"
SSH_USER="jenkins"

# Locate Source Directory Having "Telegraf" in Folder Name
SEARCH_DIR="$(dirname "${BASH_SOURCE[0]}")/"
FOLDER_NAME="telegraf"

for dir in "${SEARCH_DIR}"*"${FOLDER_NAME}"*/; do
  if [ -d "${dir}" ]; then
    SOURCE_DIR="${dir}"
    break
  fi
done

if [ -z "${SOURCE_DIR}" ]; then
  echo "No folder found matching the folder pattern: ${SEARCH_DIR}*${FOLDER_NAME}*"
  exit 1
fi

echo "Source folder: ${SOURCE_DIR}"

# Set the destination directory with SSH_USER
DEST_DIR="/home/${SSH_USER}/telegraf"
echo "Destination folder: ${DEST_DIR}"

echo ""
echo "------------------------------------------------------------------------"
echo "[STARTED] telegraf.service initiated on server: ${SERVER}"
echo "------------------------------------------------------------------------"
echo ""

# Checking status of telegraf.service on current server
if ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo systemctl is-active telegraf>/dev/null 2>&1"; then
  echo "The telegraf service is already running on ${SERVER}, skipping this server..."
else
  echo "Copying files to ${SERVER}..."
  echo ""
  ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "mkdir -p ${DEST_DIR}" > /dev/null
  scp -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -P 22 -r "${SOURCE_DIR}"* "${SSH_USER}@${SERVER}:${DEST_DIR}"
  ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo chmod -R 777 ${DEST_DIR} && cd ${DEST_DIR} && sudo ./telegraf_start.sh" > /dev/null
fi

echo ""
echo "[Status]" && ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo systemctl status telegraf | grep -E 'Active:|Loaded:|Main PID:|CGroup:'"
echo ""