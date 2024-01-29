#!/bin/bash

MYWORKDIR="/var/tmp/operators-extracted-data"
IMAGE="registry.redhat.io/redhat/redhat-operator-index:v4.14"

get_term_width () {
	
	TERM_WIDTH=$(stty -a <"$(tty)" | grep -Po '(?<=columns )\d+')
	LINE=""
	for ((i=1 ; i <$TERM_WIDTH ; i++ )) ; do
		LINE+="="
	done
}

cleanup () {
	rm -rf $MYWORKDIR 2> /dev/null
	podman stop operators-list --timeout 1 2> /dev/null
	podman rm operators-list -f 2> /dev/null
	mkdir $MYWORKDIR
}

pull_image () {
	ERROR=$(podman pull $IMAGE 2>&1)
	if [[ $? -eq "0" ]]; then
		echo
		echo
		IMAGE_NAME=$(podman inspect $IMAGE | jq -r .[0].RepoTags[0])
		IMAGE_ID=$(podman inspect $IMAGE | jq -r .[0].Id)
		IMAGE_DIGEST=$(podman inspect $IMAGE | jq -r .[0].Digest)
		IMAGE_CREATIONTIME=$(podman inspect $IMAGE | jq -r .[0].Created)
		echo -e "\e[92m/// Image Details /// \e[0m"
		echo "Image Name          = $IMAGE_NAME"
		echo "Image Id            = $IMAGE_ID"
		echo "Image Digest        = $IMAGE_DIGEST"
		echo "Image Creation Time = $IMAGE_CREATIONTIME"
	else
		echo -e "\e[91mERROR while trying to pull the image:\e[0m"
		echo "$ERROR"
		exit
	fi
}


start_container () {
	ERROR=$(podman run --name operators-list -d $IMAGE 2>&1)
	if [[ $? -ne "0" ]]; then
		echo -e "\e[91mERROR while trying to start the container:\e[0m"
		echo "$ERROR"
		exit
	fi
		
}

extract_operators_data () {
	ERROR=$(podman cp operators-list:/configs/. $MYWORKDIR 2>&1)
	if [[ $? -ne "0" ]]; then
		echo -e "\e[91mERROR while trying to extract operators meta data:\e[0m"
		echo "$ERROR"
		exit
	fi
}

build_operators_map () {
	
	echo -e NAME DEFAULT_CHANNEL OTHER_CHANNELS > $MYWORKDIR/operators-data.txt
	for i in `ls $MYWORKDIR/configs/` ; do 
		NAME=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.defaultChannel != null) | .name')
		DEFAULTCHANNEL=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.defaultChannel != null) | .defaultChannel')
		CHANNELS=$(cat $MYWORKDIR/configs/$i/catalog.json | jq -r ' . | select (.schema == "olm.channel") | .name ')
	        MODIFIEDCHANNELS=""
		for x in $CHANNELS ; do
			if [ $x == $DEFAULTCHANNEL ]; then
				echo 1 > /dev/null
			else
				MODIFIEDCHANNELS+="$x "
			fi
		done
		echo -e $NAME $DEFAULTCHANNEL $MODIFIEDCHANNELS >> $MYWORKDIR/operators-data.txt
	done

	echo
	echo "Operators data is saved under $MYWORKDIR/operators-data.txt"
	echo
	cat $MYWORKDIR/operators-data.txt | column -t
}

if [ -z $IMAGE ]; then
	echo -e "\e[93m >> Please provide the target Operators Index Image \e[0m"
	exit 0
else
	get_term_width
	echo -e "\e[93m >> CLEANING UP OLD USED DIRECTORIES (if exists) \e[0m"
	cleanup
	echo
	echo "$LINE"
	echo
	echo -e "\e[93m >> Trying to pull the target image if not already downloaded \e[0m"
	pull_image
	echo
	echo "$LINE"
	echo
	echo -e "\e[93m >> Trying to start a temporary container from the provided image \e[0m"
	start_container
	echo
	echo "$LINE"
	echo
	echo -e "\e[93m >> Extracting Operators data from the temporary container \e[0m"
	extract_operators_data
	echo
	echo "$LINE"
	echo
	echo -e "\e[93m >> Building up the Operators data map file \e[0m"
	build_operators_map
fi
