#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$APP_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
LOGS_DIR="$APP_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;
UTILS_DIR="$APP_DIR/utils"; if [ ! -d $UTILS_DIR ]; then mkdir -p $UTILS_DIR; fi;
PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

echo " - "
echo " - Setup: Started"
echo " - "

# Initialize Guardian credentials (if necessary)
$APP_DIR/utils/setup/create_credentials.sh

# Register with RFCx API (if necessary)
$APP_DIR/utils/setup/api_register.sh



if [ -d "$APP_DIR/.git" ]; then 

	echo " - "
	echo " - Blocking update process because this is a Git repository.";

else

	# Download 'upgrade' script
	if [ ! -f "$APP_DIR/utils/upgrade.sh" ]; then
		DOWNLOAD=$(wget -q -O "$APP_DIR/utils/upgrade.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/utils/upgrade.sh");
		chmod a+x "$APP_DIR/utils/upgrade.sh";
	fi

	echo " - "
	echo " - Running Update script"
	$APP_DIR/utils/upgrade.sh "update" && $APP_DIR/update.sh

	echo " - "
	echo " - Creating database files, if they don't already exist..."
	$APP_DIR/utils/database_init.sh "checkins-queued"
	$APP_DIR/utils/database_init.sh "checkins-sent"
	$APP_DIR/utils/database_init.sh "checkins-complete"

	# set cron jobs
	if [ -f "$APP_DIR/utils/crontab.sh" ]; then
		$APP_DIR/utils/crontab.sh "update" 20
		$APP_DIR/utils/crontab.sh "triggerd" 1 "checkin_from_queue" 60 "SCW1840_%Y%Y%m%d_%H%M%S"
		$APP_DIR/utils/crontab.sh "triggerd" 1 "queue_from_inotify" 60 "/var/www/sites/Sand_Heads/" "wav"
	fi

fi


echo " - "
echo " - Setup: Complete"
echo " - "
