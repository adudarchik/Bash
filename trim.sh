#!/usr/bin/env bash
# Check for ssd in /dev and make trin 

disc_search(){
	LIST=`lsblk -d -o name,rota | awk '{if (NR!=1) print $1}'`
	for disk in $LIST; do
		if [ `lsblk -d -o name,rota | grep $disk | awk '{print $2}'` == "0" ]
		then
			M_POINT=`mount | grep $disk | awk '{print $3}'`
			DIRS="$DIRS $M_POINT"
		fi
	done
	echo $DIRS
}

trim(){
	POINTS=$(disc_search)
	for dir in $POINTS;do
		fstrim -v $dir
	done
}

trim
