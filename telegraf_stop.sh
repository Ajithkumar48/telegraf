# Get the working directory path
WORKING_DIRECTORY="$(pwd)"

# Print the working directory path
echo "The working directory is: $WORKING_DIRECTORY"

# Set the service name
SERVICE_NAME=telegraf

sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME
sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload

sudo systemctl status $SERVICE_NAME -l
