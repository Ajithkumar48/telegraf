# telegraf

Shell script to  start and stop telegraf as service in Linux

Prerequsites: Download telegraf linux binary x46 for installation and place the .sh files in root directory
    
    > /home/user/telegraf/etc/..
    > /home/user/telegraf/usr/..
    > /home/user/telegraf/var/..
    > telegraf_start.sh
    > telegraf_stop.sh

Place the template.conf file in /etc/telegraf/..

run below command:

Start CMD

    > chmod +x ./telegraf_start.sh
    > sudo ./telegraf_start.sh

Stop CMD

    > chmod +x ./telegraf_stop.sh
    > sudo ./telegraf_stop.sh

This script creates a new configuration file for Telegraf and sets the hostname to the hostname of the machine running the script. It then sets up a new systemd service for Telegraf using the new configuration file.

Here's a breakdown of the script:

    Get the working directory path.
    Print the working directory path.
    Get the hostname of the machine running the script.
    Define the filenames for the template file and output file.
    Set the new hostname to the hostname of the machine running the script.
    Check if the template file exists. If not, exit with an error.
    Check if the output file already exists. If so, delete it.
    Copy the contents of the template file to the output file, replacing the P_Hostname placeholder with the new hostname.
    Display a message indicating success.
    Set the service name and description.
    Create the service file.
    Reload the systemd daemon.
    Start the service and enable it to run at boot time.
