#!/bin/bash

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

# Loop through each row in the CSV file
while IFS=',' read -r SERVER SSH_USER SSH_PASS SSH_PORT; do

  # Set the destination directory with SSH_USER
  DEST_DIR="/home/${SSH_USER}/telegraf"

  echo ""
  echo "------------------------------------------------------------------------"
  echo "[STARTED] telegraf.service initiated on server: ${SERVER}"
  echo "------------------------------------------------------------------------"
  echo ""

  # Checking status of telegraf.service on current server
  if sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo systemctl is-active telegraf>/dev/null 2>&1"; then
    echo "The telegraf service is already running on ${SERVER}, skipping this server..."
  else
    echo "Copying files to ${SERVER}..."
    echo ""
    sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "mkdir -p ${DEST_DIR}" > /dev/null
    scp -o StrictHostKeyChecking=no -P 22 -r "${SOURCE_DIR}"* "${SSH_USER}@${SERVER}:${DEST_DIR}"
    sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo chmod -R 777 ${DEST_DIR} && cd ${DEST_DIR} && sudo ./telegraf_start.sh" > /dev/null
  fi

  echo ""
  echo "[Status]" && sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no -p 22 "${SSH_USER}@${SERVER}" "sudo systemctl status telegraf | grep -E 'Active:|Loaded:|Main PID:|CGroup:'"
  echo ""

done < "${SEARCH_DIR}/servers.csv"

# Pause the script to allow the user to read the output
read -rp "Press any key to continue..."