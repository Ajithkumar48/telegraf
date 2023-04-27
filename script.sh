#!/bin/bash

WORKSPACE=$1
SERVER=$2
SSH_USER=$3

# Set the Source directory with WORKSPACE
SOURCE_DIR="${WORKSPACE}/telegraf/"
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
  ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo chmod -R 777 ${DEST_DIR} && cd ${DEST_DIR} && ./telegraf_start.sh" > /dev/null
fi

echo ""
echo "[Status]" && ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo systemctl status telegraf | grep -E 'Active:|Loaded:|Main PID:|CGroup:'"
echo ""
