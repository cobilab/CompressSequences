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
             awk '{flag=0; for(i=1; i<=NF; i++) if ($i == -1) {flag=1; next}; if (flag==0) print $0}' "$rawFile" > "$cleanFile";
        fi
    done
}
#
function SPLIT_FILES_BY_DS() {
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
                DSN=$(echo "$line" | cut -d" " -f1)
                size=$(echo "$line" | cut -d" " -f5)
                
                output_file="${file_prefix}$DSN-$size.csv"
                
                echo "$line" > "$output_file"
            else
                # append the line to the current dataset's file
                echo "$line" >> "$output_file"
            fi
        done < "$input_file"
    done
}

#
# === MAIN ===========================================================================
#

# bench-results-raw-$size.txt ----> bench-results-grp-$size.csv
FILTER_INNACURATE_DATA;

# bench-results-grp-$size.csv ----> bench-results-DS1-$size.csv, bench-results-DS2-$size.csv...
clean_bench_grps=( $(find "$resultsPath" -maxdepth 1 -type f -name "*-grp-*" | sort -t '-' -k2,2 -k4,4 -r) );
SPLIT_FILES_BY_DS;
