#!/bin/bash
# ----------------------------------
# Define variables
# ----------------------------------
EDITOR=vim
RED='\033[0;41;30m'
STD='\033[0;0;39m'\
BASEDIR="${HOME}/deploy"
BACKUPDIR="${BASEDIR}/backup"
DEPLOYDIR="${BASEDIR}/to_deploy"
LIVEDIR="${BASEDIR}/live"
NUM_BACKUP="$(find ${BACKUPDIR} | wc -l)"
#WEBAPPS_PATH="/opt/deploy/tomcat/latest/webapps"
WEBAPPS_PATH="/home/marco/temp/mecshopping"
BACKEND_POOL="test1
test2"
BACKOFFICE_POOL="test3"
JOBS_POOL="test3"

# ----------------------------------
# User defined function
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

deploy_webapps(){
	WEBAPPS_N="(ls -1 ${DEPLOYDIR} | wc -l)"
	echo "There are ${WEBAPPS_N} ready to be deployed"
	ls -1 ${DEPLOYDIR}
	read -p "Would you like to proceed? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ ${REPLY} =~ ^[Yy]$ ]]
	then
		echo "Backing up currently live webapps"
		backup_webapps
		echo "A few checks before deploying"
		
		echo "Are you sure "
	else
		exit 0;
	fi

}

sync_webapps(){
	if [ ${1} == *backend* ]; then
		for server in "${BACKEND_POOL}";
		do
			rsync -avzx ${DEPLOYDIR}/${1} ${server}:${WEBAPPS_PATH}/site/ROOT.war
			while true;
			do
				clear
				echo "Deploying ${1} on ${server}, please wait."
				sleep 60
				echo "Deployed war and folder timestamp: "
				echo "ROOT.war"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/site/ROOT.war|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				echo "ROOT"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/site/ROOT|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				read -p "Has the webapp been deployed?? " -n 1 -r
				echo    # (optional) move to a new line
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo "${1} has been deployed on ${server}"
					break
				fi
			done
		done
	elif [ ${1} == *backoffice* ]; then
		for server in "${BACKOFFICE_POOL}";
		do
			rsync -avzx ${DEPLOYDIR}/${1} ${server}:${WEBAPPS_PATH}/backoffice/ROOT.war
			while true;
			do
				clear
				echo "Deploying ${1} on ${server}, please wait."
				sleep 60
				echo "Deployed war and folder timestamp: "
				echo "ROOT.war"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/backoffice/ROOT.war|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				echo "ROOT"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/backoffice/ROOT|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				read -p "Has the webapp been deployed?? " -n 1 -r
				echo    # (optional) move to a new line
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo "${1} has been deployed on ${server}"
					break
				fi
			done
		done
	elif [ ${1} == *jobs* ]; then
		for server in "${JOBS_POOL}";
		do
			rsync -avzx ${DEPLOYDIR}/${1} ${server}:${WEBAPPS_PATH}/jobs/ROOT.war
			while true;
			do
				clear
				echo "Deploying ${1} on ${server}, please wait."
				sleep 60
				echo "Deployed war and folder timestamp: "
				echo "ROOT.war"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/jobs/ROOT.war|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				echo "ROOT"
				"$(ssh ${server} 'stat ${WEBAPPS_PATH}/jobs/ROOT|awk -F\': \' \'/Modify: /{print $2}\'| cut -d. -f1\')"
				read -p "Has the webapp been deployed?? " -n 1 -r
				echo    # (optional) move to a new line
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo "${1} has been deployed on ${server}"
					break
				fi
			done
		done
}

backup_webapps(){
	echo "backup"
}

list_webapps(){
	echo "list appz"
}

list_backups(){
	echo "list backupz"
}

# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. List the currently deployed webapps"
	echo "2. Deploy new webapp(s)"
	echo "3. List the backed up webapps"
	echo "4. Backup currently live webapps"
	echo "5. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.read_options(){
	local choice
	read -p "Enter choice [ 1 - 5] " choice
	case $choice in
		1) list_webapps ;;
		2) deploy_webapps ;;
        3) list_backups ;;
        4) backup_webapps ;;
		5) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options
done