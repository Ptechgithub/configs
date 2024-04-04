#!/bin/bash

# Usage:
# $1: Hostname
# $2: Starting MTU (default 1540)
# $3: Timeout in seconds (default 0.3)
# $4: Starting MTU increment (default 10)

# Ensure hostname is provided
[ -z $1 ] && echo "Hostname must be specified." && exit 1

# Set default values if arguments are not provided
mtu=${2:-1540}
timeout=${3:-0.3}
increment=${4:-10}

# Initialize variables
goodjob=0

# Loop until optimal MTU is found
while :; do
    # Ping with adjusted MTU size
    timeout $timeout ping -s $(($mtu-28)) -M do -c 1 -q -n $1 >/dev/null 2>/dev/null

    # Check ping result
    if [ $? != 0 ]; then
        mtu=$(($mtu-$increment))
        [ "$goodjob" = 1 ] && break
    else
        [ "$increment" = 1 ] && goodjob=1
        increment=1
        mtu2=$mtu
        mtu=$(($mtu+$increment))
    fi
done

# Print the optimal MTU size
echo "Optimal MTU size: $mtu2"