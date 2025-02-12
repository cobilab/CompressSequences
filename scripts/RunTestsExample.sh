#!/bin/bash
#
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    *) 
        echo "This program does not have options"
        exit 1;
        ;;
    esac
done
#
resultsPath="../results";
mkdir -p $resultsPath;
#
configJson="../config.json"
sequencesPath="$(grep 'sequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
sequences=( $sequencesPath/*.seq )
#
nthreads=2
for i in $(seq 1 $nthreads ${#sequences[@]}); do 
    for j in $(seq 0 $((nthreads-1))); do
        dsid=$((i+j))
        (( $dsid <= "${#sequences[@]}" )) && ./Run.sh -ds $i 1> out$i 2> err$i &
    done
    wait 
done
