#!/bin/bash

MYWORKDIR="/var/tmp/operators-extracted-data"
IMAGE="registry.redhat.io/redhat/redhat-operator-index:v4.14"


function cleanup () {
	rm -rf $MYWORKDIR 2> /dev/null
	podman stop operators-list --timeout 1 2> /dev/null
	podman rm operators-list -f 2> /dev/null
	mkdir $MYWORKDIR
}

function pull_image () {
	podman pull $IMAGE
}


function start_container () {
	podman run --name operators-list -d $IMAGE
}

function extract_operators_data () {
	podman cp operators-list:/configs/. $MYWORKDIR
}

function build_operators_map () {
	
	echo -e NAME DEFAULT_CHANNEL CHANNELS > $MYWORKDIR/operators-data.txt
	for i in `ls $MYWORKDIR/configs/` ; do 
		NAME=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.defaultChannel != null) | .name')
		DEFAULTCHANNEL=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.defaultChannel != null) | .defaultChannel')
		CHANNELS=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.schema == "olm.channel") | .name ')
	        MODIFIEDCHANNELS=""
		for i in $CHANNELS ; do
			if [ $i == $DEFAULTCHANNEL ]; then
				echo 1 > /dev/null
			else
				MODIFIEDCHANNELS+="$i "
			fi
		done
		echo -e $NAME $DEFAULTCHANNEL $MODIFIEDCHANNELS >> $MYWORKDIR/operators-data.txt
	done
	
	cat $MYWORKDIR/operators-data.txt | column -t
}

if [ -z $IMAGE ]; then
	echo "Please provide the target Operators Index Image"
	exit 0
else
	echo "CLEANING UP OLD USED DIRECTORIES (if exists)"
	cleanup
	echo "================================================================="
	echo
	echo
	echo "Trying to pull the target image if not already downloaded"
	pull_image
	echo "================================================================="
	echo
	echo
	echo "Trying to start a temporary container from the provided image"
	start_container
	echo "================================================================="
	echo
	echo
	echo "Extracting Operators data from the temporary container"
	extract_operators_data
	echo "================================================================="
	echo
	echo
	echo "Building up the Operators data map file"
	build_operators_map
fi
