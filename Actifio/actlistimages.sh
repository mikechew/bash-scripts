#!/bin/bash
#
## File: actlistimages.sh
## Lists the hosts on an Actifio appliance from Linux or MacOS commmand line
## Author: Michael Chew ( michael.chew@actifio.com )
##
## Version 1.0 Initial Release ( tested on Actifio 7.x )
#
## Import the parameters required for the script:  $cli_User  $cli_User_pte_key
## Import the run_if_alive() function
#
[ ! -f ./actparms.conf ] && { echo "Usage: Missing config file ./actparms.conf "; exit 1; }
. ./actparms.conf

# -s option is only supported in MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
readonly TMPFILE="/tmp/$(basename -s .sh "$0")-"$$".txt"
else
readonly TMPFILE="/tmp/$(basename "$0" .sh)-"$$".txt"	
fi

# Clean up temporary file on normal exit or interrupt:
trap 'rm $TMPFILE >/dev/null 2>&1; exit 0' 0 1 2 3 15

# The script expects at least three parameters (IP address of the Sky appliance)
readonly numparms=4

[ $# -ne $numparms ] && { echo "Usage: $0 srcHost AppName jobType sky-ip (10.61.5.187) "; echo "Example: $0 centosa demo snapshot|dedup 10.61.5.187 " ; echo "Purpose: $0 lists snapshot|dedup images associated to a source & application on an Actifio appliance " ; exit 1; }
act_ip=$4

cat > $TMPFILE <<EOT
src_host=$1
app_name=$2
job_type=$3
printf '=%.0s' {1..80}
printf "\n"
hostID=\`udsinfo lshost -filtervalue hostname=\$src_host -delim , -nohdr | cut -d',' -f1\`
udsinfo lsbackup -nohdr -delim , -filtervalue  hostname=\$src_host\&jobclass=\$job_type | while IFS="," read -ra image; do printf "Consistency Dt: %-10s %-10s    : ImageID: %-15s  : AppName: %-15s \n" \${image[17]} \${image[18]} \${image[21]} \${image[22]} ; done
exit
EOT

#
## Executes the list of Actifio CLI commands in the $TMPFILE file
#
if [ -x "$(command -v nc)" ]; then
run_act_cli_if_alive_using_nc
else
run_act_cli_if_alive_using_telnet
fi
