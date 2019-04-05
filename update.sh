#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
NOW=$(($($GNU_DATE_BIN '+%s')*1000))

echo " - ";

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	echo " - Checking GitHub for newer 'checkin.sh' script...";

	$SCRIPT_DIR/upgrade.sh "checkin"
	$SCRIPT_DIR/upgrade.sh "setup"

else

	echo " - Blocking update process because this is a Git repository.";

fi

GUID=`cat "$PRIVATE_DIR/guid";`;
TOKEN=`cat "$PRIVATE_DIR/token";`;

if [ -f "$PRIVATE_DIR/hostname" ]; then 
	echo " - Sending 'ping' to RFCx API..."
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;
	curl -s -o /dev/null -X GET "$HOSTNAME/v1/guardians/$GUID/software/all?role=updater&version=0.4.0&battery=100&timestamp=$NOW" -H "Cache-Control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";	
fi

