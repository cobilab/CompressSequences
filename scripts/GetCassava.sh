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
configJson="../config.json"
rawSequencesPath="$(grep 'rawSequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
mkdir -p $rawSequencesPath;
rawCassavaPath="../cassava_raw"
#
cassavaFiles=( $rawCassavaPath/*.gz )
for cassavaFile in "${cassavaFiles[@]}";do
    gunzip -c "$cassavaFile" > "$rawSequencesPath/${cassavaFile/.gz/}"
    mv "$rawSequencesPath/${cassavaFile/.gz/}" $rawSequencesPath
done
