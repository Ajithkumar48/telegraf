#!/bin/bash

# Locate Source Directory Having "Telegraf" in Folder Name
SEARCH_DIR=$(dirname "${BASH_SOURCE[0]}")
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

# Destination Directory
DEST_DIR="/home/${SSH_USER}/telegraf"

# Loop through each row in the CSV file
while IFS=',' read -r SERVER SSH_USER SSH_PASS SSH_PORT; do

  # Set the default port to 22 if no input was provided
  if [ -z "${SSH_PORT}" ]; then
    SSH_PORT=22
  fi

  echo ""
  echo "------------------------------------------------------------------------"
  echo "[STARTED] telegraf.service initiated on server: ${SERVER}"
  echo "------------------------------------------------------------------------"
  echo ""

  # Checking status of telegraf.service on current server
  if plink -batch -ssh -P "${SSH_PORT}" -l "${SSH_USER}" -pw "${SSH_PASS}" "${SERVER}" "sudo systemctl is-active telegraf" | grep -q "active"; then
    echo "The telegraf service is already running on ${SERVER}, skipping this server..."
  else
    echo "Copying files to ${SERVER}..."
    echo ""
    plink -batch -ssh -P "${SSH_PORT}" -l "${SSH_USER}" -pw "${SSH_PASS}" "${SERVER}" "mkdir -p ${DEST_DIR}" > /dev/null
    pscp -C -r -P "${SSH_PORT}" -pw "${SSH_PASS}" "${SOURCE_DIR}"* "${SSH_USER}"@"${SERVER}":"${DEST_DIR}"
    plink -batch -ssh -P "${SSH_PORT}" -l "${SSH_USER}" -pw "${SSH_PASS}" "${SERVER}" "sudo chmod -R 777 ${DEST_DIR} && cd ${DEST_DIR} && sudo ./telegraf_start.sh" > /dev/null
  fi

  echo ""
  echo "[Status]" && plink -batch -ssh -P "${SSH_PORT}" -l "${SSH_USER}" -pw "${SSH_PASS}" "${SERVER}" "sudo systemctl status telegraf | grep -E 'Active:|Loaded:|Main PID:|CGroup:'"
  echo ""

done < "${SEARCH_DIR}/servers.csv"

# Pause the script to allow the user to read the output
read -rp "Press any key to continue..."
