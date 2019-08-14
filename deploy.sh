aaaaaa#!/bin/bash

###
# Deploying script by MB - v 0.1
# TODO: make it modular.
###

# ----------------------------------
# Define variables
# ----------------------------------

EDITOR=vim
RED='\033[0;41;30m'
STD='\033[0;0;39m'
WORKDIR="${HOME}"
BACKUPDIR="${WORKDIR}/backup"
DEPLOYDIR="${WORKDIR}/to_deploy"
LIVEDIR="${WORKDIR}/deploy"
WEBAPPS_PATH="/opt/deploy/tomcat/latest/webapps"
BACKEND_POOL="c003669app00.neen.cloud c003669app01.neen.cloud"
BACKOFFICE_POOL="c003669bcf00.neen.cloud"
JOBS_POOL="c003669bcf00.neen.cloud"

 
# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP


clear
sleep 0.5

echo "======================================================="
echo "=============  Webapps Deploying Script ==============="
echo "======================================================="
echo
sleep 0.5
echo
WEBAPPS_N="$(ls -1 ${DEPLOYDIR} | wc -l)"
echo "There are ${WEBAPPS_N} webapps ready to be deployed"
echo
ls -1 ${DEPLOYDIR}
echo
read -p "Would you like to proceed? [Y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ ${REPLY} =~ ^[Yy]$ ]]
then
    echo "Proceeding..."
    echo
    sleep 2
else
	exit 2;
fi

sleep 2
echo
for servlet in $(ls -1 ${DEPLOYDIR})
do
    if [[ $(echo ${servlet} | cut -d- -f3) == $(cat ${HOME}/.env) ]]
    then
        echo "You are deploying" $(echo ${servlet} | cut -d- -f3)
        echo
    else
        echo "You are trying to deploy "$(echo ${servlet} | cut -d- -f3) "webapp onto a "$(cat ${HOME}/.env)" server"
        echo "Exiting..."
        echo
        sleep 2
        exit 3
    fi

    echo "Handling ${servlet}"
    echo
    if [[ ${servlet} =~ backend ]]
    then

        echo "Backing up currently live backend webapp"
        echo
        sleep 2
        mv ${LIVEDIR}/backend/* ${BACKUPDIR}/backend/.
        if [ "$(ls -1 ${BACKUPDIR}/backend/ | wc -l)" -gt 5 ];
        then
            rm -rf ${BACKUPDIR}/backend/$(ls -1rt ${BACKUPDIR}/backend | head -n1)
        fi
        echo "These are the available backups for the currently used backend webapp:"
        echo
        echo "== backend =="
        echo "list of backups"
        ls -1 ${BACKUPDIR}/backend/
        echo


		for server in ${BACKEND_POOL};
		do
            echo "Pushing ${servlet} on ${server}, please wait"
            echo
			rsync -avzx ${DEPLOYDIR}/${servlet} ${server}:${WEBAPPS_PATH}/site/ROOT.war
            if [ "$(ssh ${server} "if [ ${WEBAPPS_PATH}/site/ROOT -nt ${WEBAPPS_PATH}/site/ROOT.war ]; then echo ok; else echo no; fi ")" == ok ]
            then
				echo "${servlet} has been successfully deployed on ${server}"
                echo "Proceeding..."
                echo
            else
                echo "There has been a problem with the deployment of ${servlet} on ${server}"
                echo "Exiting..."
                sleep 2
                exit 3
			fi
		done
        mv ${DEPLOYDIR}/${servlet} ${LIVEDIR}/backend/.

    elif [[ ${servlet} =~ backoffice ]]
    then

        echo "Backing up currently live backoffice webapp"
        echo
        sleep 2
        mv ${LIVEDIR}/backoffice/* ${BACKUPDIR}/backoffice/.
        if [ "$(ls -1 ${BACKUPDIR}/backoffice/ | wc -l)" -gt 5 ];
        then
            rm -rf ${BACKUPDIR}/backoffice/$(ls -1rt ${BACKUPDIR}/backoffice | head -n1)
        fi
        echo "These are the available backups for the currently used backoffice webapp:"
        echo "== backoffice =="
        echo "list of backups"
        ls -1 ${BACKUPDIR}/backoffice/
        echo



		for server in ${BACKOFFICE_POOL};
		do
            echo "Pushing ${servlet} on ${server}, please wait"
			rsync -avzx ${DEPLOYDIR}/${servlet} ${server}:${WEBAPPS_PATH}/backoffice/ROOT.war
            if [ "$(ssh ${server} "if [ ${WEBAPPS_PATH}/backoffice/ROOT -nt ${WEBAPPS_PATH}/backoffice/ROOT.war ]; then echo ok; else echo no; fi ")" == ok ]
            then
				echo "${servlet} has been successfully deployed on ${server}"
                echo "Proceeding..."
                echo
            else
                echo "There has been a problem with the deployment of ${servlet} on ${server}"
                echo "Exiting..."
                sleep 2
                exit 3
			fi
		done
        mv ${DEPLOYDIR}/${servlet} ${LIVEDIR}/backoffice/.

    elif [[ ${servlet} =~ jobs ]]
    then

        echo "Backing up currently live jobs webapp"
        echo
        sleep 2
        mv ${LIVEDIR}/jobs/* ${BACKUPDIR}/jobs/.
        if [ "$(ls -1 ${BACKUPDIR}/jobs/ | wc -l)" -gt 5 ];
        then
            rm -rf ${BACKUPDIR}/jobs/$(ls -1rt ${BACKUPDIR}/jobs | head -n1)
        fi
        echo "These are the available backups for the currently used jobs webapp:"
        echo "== jobs =="
        echo "list of backups"
        ls -1 ${BACKUPDIR}/jobs/
        echo

		for server in ${JOBS_POOL};
		do
            echo "Pushing ${servlet} on ${server}, please wait"
			rsync -avzx ${DEPLOYDIR}/${servlet} ${server}:${WEBAPPS_PATH}/jobs/ROOT.war
            if [ "$(ssh ${server} "if [ ${WEBAPPS_PATH}/jobs/ROOT -nt ${WEBAPPS_PATH}/jobs/ROOT.war ]; then echo ok; else echo no; fi ")" == ok ]
            then
				echo "${servlet} has been successfully deployed on ${server}"
                echo "Proceeding..."
                echo
            else
                echo "There has been a problem with the deployment of ${servlet} on ${server}"
                echo "Exiting..."
                sleep 2
                exit 3
			fi
		done
        mv ${DEPLOYDIR}/${servlet} ${LIVEDIR}/jobs/.

    fi
done

echo "Deploy successful, this is the current situation"
echo
echo "== Backend Webapp ==" 
ls ${LIVEDIR}/backend/.
echo 

echo "== Backoffice Webapp ==" 
ls ${LIVEDIR}/backoffice/.
echo 

echo "== Jobs Webapp ==" 
ls ${LIVEDIR}/jobs/.
echo

sleep 5
exit 0
