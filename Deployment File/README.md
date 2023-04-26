# telegraf

Here are the pointers for the given batch file:

    The script locates the source directory having "Telegraf" in folder name.
    It uses a for loop to loop through each row in the servers.csv file.
    It sets the variables SERVER, SSH_USER, SSH_PASS, and SSH_PORT from each row of the CSV file.
    If no input was provided for the SSH_PORT, it sets the default port to 22.
    It uses plink and pscp commands to copy the contents of the source directory to the destination directory on each server and execute the telegraf_start.sh  script.
    It uses the sudo command to give permission to the destination directory and execute the telegraf_start.sh script.
    It prints the status of the telegraf service using the systemctl command.
    The script pauses at the end to allow the user to read the output.

Additionally, the script changes the color of the terminal and suppresses the output of the plink command.
