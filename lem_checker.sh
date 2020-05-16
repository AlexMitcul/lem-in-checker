#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'

FO="--flow-one"
FT="--flow-ten"
FTH="--flow-thousand"
B="--big"
BS="--big-superposition"

# LEM_FILE_PATH="../test_project/lem-in"

FO_DIR="maps/flow_one"
FT_DIR="maps/flow_ten"
FTH_DIR="maps/flow_thousand"
B_DIR="maps/big"
BS_DIR="maps/big_superposition"

RE="--re"

delete_dir () {
	rm -rf ./maps
}

create_dir () {
	mkdir maps
	mkdir maps/flow_one | \
	mkdir maps/flow_ten | \
	mkdir maps/flow_thousand | \
	mkdir maps/big | \
	mkdir maps/big_superposition
}

generate_one_batch () {
	./generator $FO > "maps/flow_one/$INDEX.map"
	./generator $FT > "maps/flow_ten/$INDEX.map"
	./generator $FTH > "maps/flow_thousand/$INDEX.map"
	./generator $B > "maps/big/$INDEX.map"
	./generator $BS > "maps/big_superposition/$INDEX.map"
}

if [ "$1" = "--re" ]; then
	delete_dir
	exit 1
elif [[ $1 = "--d" ]]; then
	mkdir src
	printf "Enter lem-in dir\n"
	read LEM_FILE_PATH
	echo $LEM_FILE_PATH > ./src/dir
	exit 1
elif ! [[ $1 =~ ^[0-9]+$ ]]; then
	printf "$RED  Usage:\n\
	--re : remove directory maps.\n\
	--d : set a path to binary lem-in file
	<int n> : generate n maps each kind.\n$NC"
	exit 1
elif [ ! "$1" = "--re" ] && [ ! -d ./maps/ ]
then
	printf "${CYAN} Generating maps ${NC}\n"
	create_dir
fi


LEM_FILE_PATH=$(head -1 ./src/dir)
# echo $LEM_FILE_PATH

if [ -z LEM_FILE_PATH ]; then
	printf "error\n enter path to lemin binary file"
fi

INDEX=$(find . -name "*.map" | sort -r | head -1 | cut -d '.' -f2 | cut -d '/' -f4)

if [ "$1" -ge 1 ]; then
	for (( i=1; i<=$1; i++ ))
	do
		INDEX=$((INDEX+1))
		generate_one_batch
	done
fi

for (( j=1; j<=5; j++ ))
do
	if [ $j -eq 1 ]; then
		printf "	$RED Testing flow-one maps\n$NC"
		FILE_PATH=$FO_DIR
	elif [ $j -eq 2 ]; then
		printf "	$RED Testing flow-ten maps\n$NC"
		FILE_PATH=$FT_DIR
	elif [ $j -eq 3 ]; then
		printf "	$RED Testing flow-thousand maps\n$NC"
		FILE_PATH=$FTH_DIR
	elif [ $j -eq 4 ]; then
		printf "	$RED Testing big maps\n$NC"
		FILE_PATH=$B_DIR
	elif [ $j -eq 5 ]; then
		printf "	$RED Testing big-superposition maps\n$NC"
		FILE_PATH=$BS_DIR
	fi
	# find $FILE_PATH -name "*.map" | sort | head -2 | tail -1 | cut -d '/' -f3
	for (( i=1; i<=$INDEX; i++ ))
	do
		# echo $FILE_PATH
		FILE=$(find $FILE_PATH -name "*.map" | sort | head -$i | tail -1 | cut -d '/' -f3)
		REQ=$(find $FILE_PATH -name "$FILE" | head -1)
		REQ=$(cat $REQ | tail -1 | cut -d ':' -f2)
		F=$(find $FILE_PATH -name "$FILE")
		RES=$($LEM_FILE_PATH < $F | wc -l)
		printf "$WHITE case $i : filename : $FILE\n"
		if [ $REQ -ge $RES ]; then
			printf "$GREEN OK"
		else
			printf "$RED KO"
		fi
		printf "$CYAN Requared : $REQ  Result : $RES\n"
	done
done
