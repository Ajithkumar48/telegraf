# telegraf

Shell script to  start and stop telegraf as service in Linux

Prerequsites: Download telegraf linux binary x46 for installation and place the .sh files in root directory
    
    > /home/user/telegraf/etc/..
    > /home/user/telegraf/usr/..
    > /home/user/telegraf/var/..
    > telegraf_start.sh
    > telegraf_stop.sh
    > script.sh  #to be used for deployment alongside jenkins

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
    
    
# Jenkins Project + git to run script.sh [Simple Project]

    > git clone /home/vagrant/localrepo/telegraf.git
    > cd ${WORKSPACE}/telegraf/
    > chmod +x ./script.sh
    > sudo ./script.sh ${WORKSPACE} ${SERVER} ${SSH_USER}
    
    
# Pipeline (Jenkins)

The Jenkins file is a pipeline that deploys the telegraf service to a list of servers specified in the `server_details` parameter. 

The pipeline consists of three stages:

1. Init Stage: This stage cleans the workspace by deleting the existing files and directories, clones the telegraf repository, checks if the `script.sh` file exists in the `telegraf` directory, and makes it executable using the `chmod` command.

2. Deploy Stage: This stage deploys the telegraf service to the list of servers specified in the `server_details` parameter using the `./script.sh` command with the parameters `${WORKSPACE}`, `${server}` and `${user}`. It also checks if the service is running on each server using the `systemctl status telegraf` command and throws an error if it is not running. 

This stage uses the `parallel` directive to run the deployment process concurrently for all servers. It also has a try-catch block to catch any exceptions that occur during deployment and prints an error message with the stage number.

3. CleanUp Stage: This stage deletes the `telegraf` directory and any other files/directories created during the pipeline execution.

Here are some examples of file paths used in the pipeline:

- `/home/vagrant/localrepo/telegraf.git`: This is the path to the telegraf repository that is cloned in the `Init Stage`.
- `${WORKSPACE}/telegraf`: This is the path to the `telegraf` directory inside the workspace.
- `./script.sh`: This is the path to the `script.sh` file inside the `telegraf` directory.
