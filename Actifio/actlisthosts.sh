#!/bin/bash
#
## File: actlisthost.sh
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

# The script expects at least one parameter (IP address of the Sky appliance)
readonly numparms=1

[ $# -ne $numparms ] && { echo "Usage: $0 sky-ip (10.61.5.187) "; echo "Purpose: $0 lists all the hosts and applications on the Actifio appliance"; exit 1; }
act_ip=$1

cat > $TMPFILE <<EOT
printf '=%.0s' {1..60}
printf "\n"
reportconnectors -nc | while IFS="," read -r -a ahost ; do 
ahost=\`echo \${ahost[1]} | sed "s/\"//g"\`
host_id=\`udsinfo lshost -nohdr -delim ^ -filtervalue hostname=\$ahost | cut -d ^ -f1\`
printf "Hostname: %-34s : HostID: %-8s\n" \$ahost \$host_id
done
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