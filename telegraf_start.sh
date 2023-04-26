#!/bin/bash

# Get the working directory path
WORKING_DIRECTORY="$(pwd)"

# Print the working directory path
echo "The working directory is: $WORKING_DIRECTORY"

# Get the hostname
HOSTNAME=$(hostname)

# Define the filename
TEMPLATE_FILE="$WORKING_DIRECTORY/etc/telegraf/telegraf_template.conf"
CONF_FILE="$WORKING_DIRECTORY/etc/telegraf/telegraf.conf"

# Set the new hostname
NEW_HOSTNAME=$(hostname)

# Check if the template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Remove the output file if it already exists
if [ -f "$CONF_FILE" ]; then
    echo "Existing Config file found at $CONF_FILE and Deleted"
    rm "$CONF_FILE"
fi


# Copy the contents of the template file to the output file
sed "s/P_Hostname/$NEW_HOSTNAME/g" "$TEMPLATE_FILE" > "$CONF_FILE"

# Display a message indicating success
echo "Created $CONF_FILE from $TEMPLATE_FILE"


# Set the service name
SERVICE_NAME=telegraf

# Set the description of the service
SERVICE_DESCRIPTION="telegraf agent"

# Create the service file
sudo tee /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=$SERVICE_DESCRIPTION
After=network.target

[Service]
WorkingDirectory=$WORKING_DIRECTORY
ExecStart=$WORKING_DIRECTORY/usr/bin/telegraf -config $WORKING_DIRECTORY/etc/telegraf/telegraf.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd daemon
sudo systemctl daemon-reload

# Start the service and enable it to run at boot time
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME
