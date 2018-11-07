#!/bin/bash

 ###############################################################
	#	Copyright (c) 2014, Meh.... TT
  # Other folk put their names here
	###############################################################
	#

# Version 3.1

unset IFS
SAVEDIFS=$IFS
IFS=$' '
if [ -z ${3} ]; then
exit
else
# ${3}:	The user's short name, When used with Casper AKA Jamf PRO

    # Populate an array with the users in the current admin group
    
    adminGroup=( `dscl -f "/var/db/dslocal/nodes/Default" localonly -read /Local/Target/Groups/admin GroupMembership | awk -F ": " '{print $NF}'` )
   ADUserFound="0"
    
    # Cycle through the users and check their UniqueID
   for i in ${adminGroup[@]}; do
        #echo ${i}
        if [ ${i} = ${3} ]; then 
            echo "User ${3} is already an admin..."
            ADUserFound="1"
        fi
   done
   # Below are a series of common names used as management accounts
   # feel free to adjust where necessary
    if [ ${ADUserFound} = "0" ]; then
        if [ ${3} == "root" ]; then exit; fi
        if [ ${3} == "_cadmin" ]; then exit; fi
        if [ ${3} == "_jadmin" ]; then exit; fi
        if [ ${3} == "adobeinstall" ]; then exit; fi
        if [ ${3} == "opt" ]; then exit; fi
    else
        echo "User ${3} is already an Admin."
        exit
    fi
    
 echo "User ${3} is not an admin proceeding..."

    for RecordName in "${adminGroup[@]}" ; do
        if [ ${ADUserFound} -eq "1" ]; then
            exit
        else
            IFS=": "
	       UniqueID=( `dscl -f "/var/db/dslocal/nodes/Default" localonly -read /Local/Target/Users/${RecordName} UniqueID | awk '{print $2}'` )
	   
# Simply exit the script if there is a UniqueID greater than 9999, this should be an AD user, hence a user has had admin rights granted
	       
	       if [[ ${UniqueID} -gt 9999 ]] ; then
	           ADUserFound="1"
	           echo "An AD User is already in the Admin Group!"
		      exit
	       fi
        fi
    done
    
    # If we get to this stage we can just simply add the user currently logging in to the admin group
   dscl -f "/var/db/dslocal/nodes/Default" localonly -append /Local/Target/Groups/admin GroupMembership ${3}
    echo "Just added the user ${3} to the Admin Group"
	# Following command can be used to touch a users home to allow a bash script to call the Outlook AppleScript
   # touch /Users/${3}/Documents/Microsoft\ User\ Data/.SetupMail
fi
exit 0
