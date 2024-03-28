#!/bin/bash

# guide:
# arg 1 must be host
# arg 2 could be starting mtu (default 1540)
# arg 3 could be timeout in sec (default 0.3)
# arg 4 could be starting mtu increment (default 10)"

[ -z $1 ] && echo "specifying host is a must" && exit 1
[ -z $2 ] && mtu=1540 || mtu=$2
[ -z $3 ] && timeout=0.3 || timeout=$3
[ -z $4 ] && increment=10 || increment=$4

goodjob=0;while :; do
	timeout $timeout ping -s $(($mtu-28)) -M do -c 1 -q -n $1 >/dev/null 2>/dev/null
	if [ $? != 0 ];then
		mtu=$(($mtu-$increment))
		[ "$goodjob" = 1 ] && break
	else
		[ "$increment" = 1 ] && goodjob=1
		increment=1
		mtu2=$mtu
		mtu=$(($mtu+$increment))
	fi
done

echo $mtu2