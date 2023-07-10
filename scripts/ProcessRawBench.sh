#!/bin/bash

resultsPath="../results";
sizes=("xs" "s" "m" "l" "xl");

#
# === FUNCTIONS ===========================================================================
#
function FILTER_INNACURATE_DATA() {
  rawGrps=("-raw");
  cleanGrps=("");
  #
  for size in ${sizes[@]}; do
    rawGrps+=("-raw-$size");
    cleanGrps+=("-grp-$size");
  done

  # new results may have size grps different from previous grps, so old results are removed
  rm -fr $resultsPath/*.csv
  rm -fr $resultsPath/split*

  # remove tests that failed to compress the sequence
  for i in ${!rawGrps[@]}; do
    rawGrp="${rawGrps[$i]}"
    rawFile="$resultsPath/bench-results$rawGrp.txt"

    cleanGrp="${cleanGrps[$i]}"
    cleanFile="$resultsPath/bench-results$cleanGrp.csv"

    if [ -f "$rawFile" ]; then 
      awk '$2 != -1 && $3 != -1 && $2 != 0 && $3 != 0 && NF' "$rawFile" > "$cleanFile";
    fi
  done
}
#
function SPLIT_FILES_BY_DS() {
  clean_bench_grps=( $(find "$resultsPath" -maxdepth 1 -type f -name "*-grp-*" | sort -t '-' -k2,2 -k4,4 -r) );
  
  # read the input file
  file_prefix="$resultsPath/bench-results-"

  # remove datasets before recreating them
  rm -fr ${file_prefix}DS*-*.csv

  ds_i=0;
  for input_file in ${clean_bench_grps[@]}; do
    while IFS= read -r line; do
      # check if the line contains a dataset name
      if [[ $line == DS* ]]; then
        # create a new output file for the dataset
        dsX=$(echo "$line" | cut -d" " -f1)
        size=$(echo "$line" | cut -d" " -f5)

        output_file="${file_prefix}$dsX-$size.csv"
        
        echo "$line" > "$output_file"
      else
        # append the line to the current dataset's file
        echo "$line" >> "$output_file"
      fi
    done < "$input_file"
  done 

  num_gens=$(($(echo "$dsX" | sed 's/ds//gi')));
}

#
# === MAIN ===========================================================================
#
FILTER_INNACURATE_DATA;
SPLIT_FILES_BY_DS;
