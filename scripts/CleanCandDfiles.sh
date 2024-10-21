#!/bin/bash
#
sequencesPath="$(grep 'sequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
find $sequencesPath -maxdepth 1 ! -name "*.fa" ! -name "*.seq" -type f -delete
