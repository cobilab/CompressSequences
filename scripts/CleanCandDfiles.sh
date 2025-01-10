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
sequencesPath="$(grep 'sequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
find $sequencesPath -maxdepth 1 ! -name "*.fa" ! -name "*.seq" -type f -delete
