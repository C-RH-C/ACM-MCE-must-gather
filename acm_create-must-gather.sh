#!/bin/bash

### Varialbles ###
Esc="$( printf '\033' )"
_norm_="${Esc}[0m" #returns to "normal"
_bold_="${Esc}[0;1m" #set bold
_yellow_="${Esc}[0;33m" #set yellow
_cyan_="${Esc}[0;36m" #set cyan
_red_="${Esc}[0;31m" #set red
_boldred_="${Esc}[0;1;31m" #set bold and red.

REL24=99
REL25=99
REL26=99
REL27=12
REL28=5
REL29=3
REL210=0

GENERATION=1712140662
RETIRED=7689599
VERSION="1.7.1"
SOURCE="https://github.com/C-RH-C/ACM-MCE-must-gather/blob/main/acm_create-must-gather.sh"

isretired() {
	AGE=`date +%s`
	AGE=$(($AGE - $GENERATION))
	if [ $AGE -gt $RETIRED ]; then
		echo "This script is older then 3 months, please check for latest version"
		echo "The latest version should be available here: $SOURCE"
	fi
}

help() {
	echo -e "Usage: $0 [OPTION]"
	echo -e "\n\tThis is helper script for collecting"
	echo -e "\tall must-gathers neccesary for support."
	echo -e "\tSource repository of this script: $SOURCE\n"
	echo -e "Options:"
	echo -e "\t${_bold_}-h${_norm_}\t\tShow this help"
	echo -e "\t${_bold_}-d <dest>${_norm_}\tSave all gatherred data to this directory."
	echo -e "\t\t\tDestination directory must be empty!"
	echo -e "\t${_bold_}-s${_norm_}\t\tGather data to diagnose Submariner add-on."
	echo -e "\t${_bold_}-r <registry>${_norm_}\tSpecify own registry in case of registry.redhat.io is not available."
	echo -e "\t\t\tUse format \"internal.repo.address:port\""
	echo -e "\t${_bold_}-l <timeout>${_norm_}\tIn case of gathering data took too long and must-gather timeout,"
	echo -e "\t\t\tfor requesting longer timeout: https://access.redhat.com/solutions/5227051"
	echo -e "\t${_bold_}-m <version>${_norm_}\tEnforce ACM version for gather data from managed cluster"
	echo -e "\t${_bold_}-t${_norm_}\t\tTest run - test all requirements and show executed commands,"
	echo -e "\t\t\tdo not collect any data"
	echo -e "\nPrerequisities:"
	echo -e "\t${_bold_}oc${_norm_}\t- download actual version from https://console.redhat.com/openshift/downloads."
	echo -e "\t${_bold_}jq${_norm_}\t- CLI JSON processor - part of common Linux distributions, for installation check your distro documentation"
	echo -e "\t${_bold_}subctl${_norm_}\t- OPTIONAL - Submariner CLI tool, required only when -s specified,\n\t\t  To download follow the documentation: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.7/html/add-ons/add-ons-overview#installing-subctl-command-utility"
	isretired
}

isupdate() {

	IFS='.'
	read -r -a ver <<< "$1"
 	AFFECTED_CVE_2023_29017=""
	UPDOC=""

	case ${ver[0]} in
		2)
			case ${ver[1]} in
				4)
					echo "THIS VERSION IS NO LONGER SUPPORTED, PLEASE UPGRADE TO 2.5"
					UPDOC="Upgrade to 2.5 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.5/html/install/index"
				;;
				5)
					echo "THIS VERSION IS NO LONGER SUPPORTED, PLEASE UPGRADE TO 2.6"
					UPDOC="Upgrade to 2.6 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.6/html/install/index"
				;;
				6)
					echo "THIS VERSION IS NO LONGER SUPPORTED, PLEASE UPGRADE TO 2.7"
					UPDOC="Upgrade to 2.7 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.7/html/install/index"
				;;
				7)
					if [ "${ver[2]}" -lt "$REL27" ]; then
						echo "Upgrade available to 2.7.$REL27"
						UPDOC=""
					else
						echo "Upgrade available to 2.8"	
					fi
					if [ "${ver[2]}" -lt "3" ]; then
						AFFECTED_CVE_2023_29017="yes"
					fi
					UPDOC="Upgrade to 2.8 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html/install/index"

				;;
				8)
					if [ "${ver[2]}" -lt "$REL28" ]; then
						echo "Upgrade available to 2.8.$REL28"
						UPDOC=""
					else
						echo "Upgrade available to 2.9"	
					fi
					UPDOC="Upgrade to 2.9 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.9/html/install/index"

				;;
				9)
					if [ "${ver[2]}" -lt "$REL29" ]; then
						echo "Upgrade available to 2.9.$REL29"
						UPDOC=""
					else
						echo "Upgrade available to 2.10"	
					fi
					UPDOC="Upgrade to 2.10 version: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.10/html/install/index"

				;;
				10)
					if [ "${ver[2]}" -lt "$REL210" ]; then
						echo "Upgrade available to 2.10.$REL210"
						UPDOC=""
					fi
				;;
				*)
					echo "UNKNOWN VERSION: $1"
				;;
			esac
			
		;;
		*)
			echo "UNKNOWN VERSION: $1"
		;;
	esac

	[ -n "$UPDOC" ] && echo "  * $UPDOC"

	if [ "xxx${AFFECTED_CVE_2023_29017}" == "xxxyes" ]; 
	then
		echo -e "  * Your ACM installation contains vulnerability https://access.redhat.com/security/cve/cve-2023-29017.
    To fix this issue, please follow instructions in https://access.redhat.com/solutions/7007647."
		echo -e "  * ${_bold_}DO NOT UPGRADE WITH HOTFIX INSTALLED${_norm_} - please, remove hotfix first\n"
	fi

}


mcemgimage() {

	IFS='.'
	read -r -a ver <<< "$1"

	ENFORCE="$2"

	case ${ver[0]} in
		2)
			VERSION='-'
			case ${ver[1]} in
				4) VERSION='-'
				;;
				5) VERSION="8:v2.0"
				;;
				6) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="8:v2.1"
				   fi
				;;
				7) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="8:v2.2"
				   fi
				;;
				8) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="8:v2.3"
				   fi
				;;
				9) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="8:v2.4"
				   fi
				;;
				10) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="9:v2.5"
				   fi
				;;
				10) if [ "x${ENFORCE}" == "xyes" ]; then
					VERSION="2.5"
				   fi
				;;
				*) VERSION='-'
				;;
			esac

			if [ "x${VERSION}" == "x-" ]; then
				echo '-'
			else
				echo "${REGISTRY}/multicluster-engine/must-gather-rhel${VERSION}"
			fi
	
		;;
		*)
			echo "-"
		;;
	esac
}

ACM_VERSION='-'
ACM_CHANNEL='-'
MANAGED='-'
REGISTRY='registry.redhat.io'
OWNREGISTRY='-'
SUBCTL='-'
LONGRUN=''
MCE_ENFORCE='-'

###
#
# Parameter -M not documented, enforce creating MCE m-g
#
###

while getopts tsMd:m:r:l:h flag
do
    case "${flag}" in
        t) DRY_RUN=yes;;
        d) DIR=${OPTARG};;
        h) HELP=yes;;
	m) ACM_VERSION=${OPTARG}
	   ACM_CHANNEL="release-${OPTARG::3}"
	   MANAGED='yes'
	;;
	r) REGISTRY=${OPTARG}
	   OWNREGISTRY='yes'
	   ;;
	s) SUBCTL=yes;;
	l) LONGRUN="--request-timeout=${OPTARG}";;
	M) MCE_ENFORCE='yes';;
    esac
done

if [ "xxx$HELP" == "xxxyes" -o "xxx$DIR" == "xxx" ]; then
	help
	exit 0
fi

if [ "XXX$DRY_RUN" == "XXXyes" ];
then
	echo "${_bold_}Testing prerequisities:${_norm_}"

	if type -P oc > /dev/null;
	then
		echo "  * ${_bold_}oc${_norm_} present..."
	else
		echo "  * ${_bold_}oc${_norm_} not present, for installation follow https://console.redhat.com/openshift/downloads."
		exit 2
	fi

	if [ "x${SUBCTL}" = "xyes" ]; then
		if type -P subctl > /dev/null;
		then
			echo "  * ${_bold_}subctl${_norm_} present..."
		else
			echo "  * ${_bold_}subctl${_norm_} not present, for installation follow https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.7/html/add-ons/add-ons-overview#installing-subctl-command-utility."
			exit 2
		fi
	fi

	if type -P jq > /dev/null;
	then
		echo "  * ${_bold_}jq${_norm_} present..."
	else
		echo "  * ${_bold_}jq${_norm_} not present, please install."
		exit 2
	fi

	echo "Prerequisities ${_bold_}OK${_norm_}"
	echo

	isretired
fi

if ! oc whoami &> /dev/null;
then
	echo "${_bold_}You are not logged to your cluster now. Please, login first${_norm_}"
	echo "Use i.e.: oc login -u <cluster admin> <cluster hostname>"
	exit 3
fi

echo -n "${_bold_}You are logged to cluster:${_norm_} "
oc whoami --show-server
echo

CLUSTER_CHANNEL=`oc get -o json clusterversion version | jq '.spec.channel' | tr -d '"'`
CLUSTER_VERSION=`oc get -o json clusterversion version | jq '.status.desired.version' | tr -d '"'`


if [ "XXX${ACM_VERSION}" == "XXX-" ];
then
	ACM_CHANNEL=`oc get subscriptions.operators.coreos.com -n open-cluster-management -o json | jq '.items[].spec.channel' | tr -d '"'`
	ACM_VERSION=`oc get subs advanced-cluster-management -n open-cluster-management -o json | jq '.status.currentCSV' | sed -e 's/.*\.v//; s/"//'`
fi

ACM_IMAGE="UNSUPPORTED"

MCE_IMAGE="-"
MCE_VERSION="-"

case ${ACM_CHANNEL:0:12} in
	release-2.4|release-2.5|release-2.6|release-2.7|release-2.8|release-2.9)
		ACM_IMAGE="${REGISTRY}/rhacm2/acm-must-gather-rhel8:v${ACM_CHANNEL#release-}"
	;;
	release-2.10)
		ACM_IMAGE="${REGISTRY}/rhacm2/acm-must-gather-rhel9:v${ACM_CHANNEL#release-}"
	;;
esac

MCE_IMAGE=`mcemgimage $ACM_VERSION $MCE_ENFORCE`
MCE_VERSION=`oc get subs -n multicluster-engine multicluster-engine -o json 2>/dev/null | jq '.status.currentCSV' | sed -e 's/.*\.v//; s/"//'`

if [ "XXX${MCE_VERSION}" == "XXXnull" ];
then
	MCE_VERSION=`oc get subs -n multicluster-engine multicluster-engine -o json | jq '.spec.channel' | sed -e 's/.*-\(.*\)"/\1/'`
fi


echo -e "${_bold_}Detected versions:${_norm_}
  ${_bold_}* This script:${_norm_} ${VERSION}-${GENERATION}
  ${_bold_}* Cluster:${_norm_}\t$CLUSTER_VERSION
  ${_bold_}* ACM:${_norm_}\t$ACM_VERSION
  ${_bold_}* MCE:${_norm_}\t$MCE_VERSION"

isupdate $ACM_VERSION

if [ "xxx$ACM_IMAGE" == "xxxUNSUPPORTED" ];
then
	echo "${_bold_}*** THIS ACM VERSION IS NOT SUPPORTED ***${_norm_}"
	exit 5
fi

echo

if [ -d "${DIR}/acm/" ];
then
	echo "${_bold_}FAIL:${_norm_} destination directory ('${DIR}/acm/') exists, please select another destination."
	exit 4
fi

if [ "xxx$MCE_IMAGE" != "xxx-" -a -d "${DIR}/mce/" ];
then
	echo "${_bold_}FAIL:${_norm_} destination directory ('${DIR}/mce/') exists, please select another destination."
	exit 4
fi

if [ "xxx$SUBCTL" != "xxx-" -a -d "${DIR}/subctl/" ];
then
	echo "${_bold_}FAIL:${_norm_} destination directory ('${DIR}/subctl/') exists, please select another destination."
	exit 4
fi

echo "${_bold_}Creating must-gather for ACM to '${DIR}/acm/'${_norm_}"

if [ "XXX$DRY_RUN" == "XXXyes" ];
then
	echo "mkdir -p \"${DIR}/acm/\""
	echo "oc adm must-gather ${LONGRUN} --image=\"${ACM_IMAGE}\" --dest-dir=\"${DIR}/acm/\" |& tee \"${DIR}/acm-must-gather.log\" | grep -q -m 1 'OUT gather did not start: unable to pull image: ImagePullBackOff: Back-off pulling image'"
else
	mkdir -p "${DIR}/acm/"
	oc adm must-gather ${LONGRUN} --image="${ACM_IMAGE}" --dest-dir="${DIR}/acm/" |& tee "${DIR}/acm-must-gather.log" | grep -q -m 1 'OUT gather did not start: unable to pull image: ImagePullBackOff: Back-off pulling image'

	if [ $? -eq 0 ];
	then
		echo "---------------------------------------------"
		echo "Unable to download image \"acm-must-gather-rhel8:v${ACM_CHANNEL#release-}\" from registry \"${REGISTRY}\""
		echo "Please, use ${_bold_}-r${_norm_} parameter to specify your registry and run script again"
		echo "For details, please use '$0 -h'"
		echo "---------------------------------------------"
		exit 10
	fi
fi

echo "${_bold_}ACM must-gather done${_norm_}"
echo

if [ "xxx$MCE_IMAGE" != "xxx-" ];
then
	echo "${_bold_}Creating must-gather for MCE to '${DIR}/mce/'${_norm_}"
	if [ "XXX$DRY_RUN" == "XXXyes" ];
	then
		echo "mkdir -p \"${DIR}/mce/\""
		echo "oc adm must-gather ${LONGRUN} --image=\"${MCE_IMAGE}\" --dest-dir=\"${DIR}/mce/\" &> \"${DIR}/mce-must-gather.log\""
	else
		mkdir -p "${DIR}/mce/"
		oc adm must-gather ${LONGRUN} --image="${MCE_IMAGE}" --dest-dir="${DIR}/mce/" |& tee "${DIR}/mce-must-gather.log" | grep -q -m 1 'OUT gather did not start: unable to pull image: ImagePullBackOff: Back-off pulling image'

		if [ $? -eq 0 ];
		then
			echo "---------------------------------------------"
			echo "Unable to download image \"multicluster-engine/must-gather-rhel8:v2.X\" from registry \"${REGISTRY}\""
			echo "Please, use ${_bold_}-r${_norm_} parameter to specify your registry and run script again"
			echo "For details, please use '$0 -h'"
			echo "---------------------------------------------"
			exit 10
		fi
	fi

	echo "${_bold_}MCE must-gather done${_norm_}"
	echo
fi

if [ "XXX$SUBCTL" == "XXXyes" ];
then
	echo "${_bold_}Collecting data from Submariner to '${DIR}/subctl/'${_norm_}"

	if [ "XXX$DRY_RUN" == "XXXyes" ];
	then
		echo "mkdir -p \"${DIR}/subctl/\""
		echo "subctl diagnose all &> \"${DIR}/subctl-diagnose-all.log\""
		echo "subctl gather --dir \"${DIR}/subctl/\" &> \"${DIR}/subctl-gather.log\""
	else
		mkdir -p "${DIR}/subctl/"
		subctl diagnose all &> "${DIR}/subctl-diagnose-all.log"
		subctl gather --dir "${DIR}/subctl/" &> "${DIR}/subctl-gather.log"
	fi

	echo "${_bold_}Submariner data collecting done${_norm_}"
	echo
fi

TIMESTAMP=`date +%s`

if [ "XXX$DRY_RUN" == "XXXyes" ];
then
	echo "Used version: ${VERSION}-${GENERATION}" 
	echo "Command: \"$0 $@\"" 
else
	echo "Used version: ${VERSION}-${GENERATION}" > "${DIR}/VERSION.txt"
	echo "Command: \"$0 $@\"" >> "${DIR}/VERSION.txt"
fi

echo -n "Creating archive with collected data... "

RETVAL=255
if [ "XXX$DRY_RUN" == "XXXyes" ];
then
	echo -e "\n"
	echo "tar -cJf \"acm_must_gather-${TIMESTAMP}.tar.xz\" \"${DIR}\";"
	echo
	RETVAL=0
else
	tar -cJf "acm_must_gather-${TIMESTAMP}.tar.xz" "${DIR}"
	RETVAL=$?
fi

if [ $RETVAL == 0 ];
then
	echo "done. Archive ${_bold_}acm_must_gather-$TIMESTAMP.tar.xz${_norm_} created."
	echo "Archive is prepared to be shared with support team."
else	
	echo "${_bold_}FAILED${_norm_}. Archive not created."
	exit $RETVAL
fi


ASK_MNGD='no'
if find "${DIR}/acm/" -type d -name open-cluster-management-hub 2>/dev/null | grep -q open-cluster-management-hub;
then
	echo -e ""
	echo -e "\t${_bold_}This cluster looks like a HUB cluster."
	ASK_MNGD='yes'
else
	if [ "XXX$DRY_RUN" == "XXXyes" ];
	then
		echo -e ""
		echo -e "\t${_bold_}Is this cluster a HUB cluster?"
		ASK_MNGD='yes'
	fi
fi

if [ "XXX$ASK_MNGD" == "XXXyes" ];
then
	echo -e "\tPlease, if you have issue related to some managed cluster,"
	echo -e "\tlog to affected managed cluster via '${_norm_}oc login ...${_bold_}' and"
	echo -e "\tuse following command to gather data from managed cluster:${_norm_}"
	echo -en "\t# $0 -m $ACM_VERSION -d <dest> "
	[ "xxx$OWNREGISTRY" == "xxxyes" ] && echo -en "-r \"${REGISTRY}\" "
	[ "xxx$SUBCTL" == "xxxyes" ] && echo -en "-s"
	echo
fi
