#!/bin/bash

#
# Name: netdog
#
# Version: 0.2
#
# Description:
# Check if default gateway DOES exist, if so, output network and mask number
#
# Params:
# $1 - what kind of network will be processed
#		0: A-Sec Net
#		1: B-Sec Net
#		2: C-Sec Net
# $2 - network ID without masks, such as 10, 10.0, 10.10.0
#
#
# Change Log:
# 20210711:
#	-- $3 added. This param defines a user specific ICMP packet to be sent, default 1,
#		if network is in jam, this may be increased to a larger integer
#	-- $4 added. This param defines a user specific deadline for waiting for income ICMP
#		response, default 1 second. This usually works well for IoT network or intranet.
#		However, this may be tuned by user to cope with network in jam.
#	-- As Darwin and Linux are NOT the same in ping command options, so discover_cnet is
#		modified to detect the OS running. This means you can run this script on darwin &
#		linux from now on without considering the diffierences any more.
#	-- have a new constant variable NDIS_IP_MAGIC to cope with possible new default gateways
#

#
# CONSTANT DEFINITION
#
MAX_PARAM_NUM=4

# enum for OS
NDIS_OS_DARWIN=1
NDIS_OS_LINUX=2
NDIS_OS_UNIX=3		# placeholder for the incoming future

# enum for network type
A_SEC_NET=0
B_SEC_NET=1
C_SEC_NET=2

# default num of ICMP packet
gNDIS_PACKET_NUM=1

# default timeout of ping
gNDIS_TIMEOUT=1

# optimised ping command
gNDIS_PING_COMM_DARWIN="ping -c ${gNDIS_PACKET_NUM} -W ${gNDIS_TIMEOUT} "
gNDIS_PING_COMM_LINUX="ping -c $gNDIS_PACKET_NUM -w $gNDIS_TIMEOUT "

#
# Global var
#
output=`date +%s`".net"

#
# Show menu
#
function show_menu () {
	echo "--------------------------------------------"
	echo "      Net Discover of Sub-Networks"
	echo "A-Sec Net: 0, with Net ID like 10"
	echo "B-Sec Net: 1, with Net ID like 10.10"
	echo "A-Sec Net: 2, with Net ID like 10.10.10"
	echo "--------------------------------------------"
	echo "For example: ./net_discover.sh 1 192.168 1 2"
	echo "--------------------------------------------"
}

#
# Check default gateways of c-section network.
# Inupt param MUST be like "192.168.0"
#
function discover_cnet () {
	# check params
	if [[ $2 -ne "" ]]
	then
		gNDIS_PACKET_NUM=$2
	fi
	if [[ $3 -ne "" ]]
	then
		gNDIS_TIMEOUT=$3
	fi

	# judge what kind OS is, Darwin or Linux
	os=0
	if [[ `uname` == 'Darwin' ]]
	then
		os=$NDIS_OS_DARWIN
	elif [[ `uname` == 'Linux' ]]
	then
		os=$NDIS_OS_LINUX
	fi

	# optimise this func so that we can easily add new possible ip
	# for gateway
	for gateway in 1 254
	do
		case $os in
			1)
				echo ${gNDIS_PING_COMM_DARWIN} $1.$gateway
				${gNDIS_PING_COMM_DARWIN} $1.$gateway
				;;
			2)
				echo ${gNDIS_PING_COMM_LINUX} $1.$gateway
				${gNDIS_PING_COMM_LINUX} $1.$gateway
				;;
			3)
				echo "[!]Not implemented now!"
				;;
			*)
				echo "[!]Current OS running NOT supported!"
		esac

		if [[ $? -eq 0 ]]
		then
			echo $1".0/24">>$output
			break
		fi
	done
}

#
# Check all possible gateways in B-section network
#
function discover_bnet () {
	# check all the sub networks of B-section
	for i in $(seq 0 255)
	do
		cnet=$1"."$i
		discover_cnet $cnet $2 $3
	done

}

#
# Check all possible gateways in B-section network
#
function discover_anet () {
	# check all the sub networks of B-section
	for i in $(seq 0 255)
	do
		cnet=$1"."$i
		discover_bnet $cnet $2 $3
	done

}


#
# >-- ******* ENTRANCE OF THE SCRIPT FILE *******--<
#

# Check  Params
if [[ $# -gt MAX_PARAM_NUM ]]
then
	echo "[!]Plz check your input!"
	show_menu
	exit 1
fi

case $1 in
	$A_SEC_NET)
		discover_anet $2 $3 $4
		;;
	$B_SEC_NET)
		discover_bnet $2 $3 $4
		;;
	$C_SEC_NET)
		discover_cnet $2 $3 $4
		;;
	*)
	show_menu
esac
