#!/bin/bash
#
configJson="../config.json"
ds_sizesBase2="$(grep 'DS_sizesBase2' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
ds_sizesBase10="$(grep 'DS_sizesBase10' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
#
# === FUNCTIONS ===========================================================================
#
function SHOW_HELP() {
 echo " -------------------------------------------------------";
 echo "                                                        ";
 echo " OptimJV3 - optimize JARVIS3 CM and RM parameters       ";
 echo "                                                        ";
 echo " Program options ---------------------------------------";
 echo "                                                        ";
 echo " -h|--help.....................................Show this";
 echo " -v|--view-ds|--view-datasets....View sequences and size"; 
 echo "                                                 of each";
 echo "                                                        ";
 echo " -------------------------------------------------------";
}
#
# === PARSING ===========================================================================
#
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            SHOW_HELP;
            exit;
            shift;
            ;;
        -v|--view-ds|--view-datasets)
            cat $ds_sizesBase2; echo; cat $ds_sizesBase10;
            exit;
            shift;
            ;;
        *) 
            echo "Invalid option: $1"
            exit 1;
            ;;
    esac
done
#
# === MAIN ===========================================================================
#
#
resultsPath="../results"
#
groups=( $(ls "$resultsPath" | grep "DS.*\.txt" | sed -n 's/.*-grp\([0-9]\+\)\.txt/grp\1/p' | sort | uniq -c | awk '{print $2}') )
for grp in ${groups[@]}; do
    #
    # build grp .txt files
    results=( $(find "$resultsPath" -maxdepth 1 -type f -name "*DS*$grp.txt" | sort -V) )
    output="$resultsPath/bench-results-raw-${grp}.txt"
    echo "$grp" > $output
    awk 'NR==2' "${results[0]}" >> $output
    for res in ${results[@]}; do
        awk 'NR>2' $res >> $output
    done
    #
    # sort results from each sequence and from group of sequences
    results=( $(find "$resultsPath" -maxdepth 1 -type f -name "*$grp.txt" | sort -V) )
    for result in ${results[@]}; do
        result="$resultsPath/$result"
        output="${result//.txt/.tsv}"
        output="${output//-raw/}"
        #
        ( head -n2 $result
        #
        # \nPROGRAM\tVALIDITY\tBYTES\tBYTES_CF\tBPS\tC_TIME (s)\tC_MEM (GB)\tD_TIME (s)\tD_MEM (GB)\tDIFF\tRUN\tC_COMMAND\n" > "$output_file_ds";
        awk -F'\t' 'NR>2 {if ($2==0 && $4!=-1 && $5!=-1 && $6!=-1 && $7!=-1) print $0}' "$result" | sort -k2n -k4n -k6n ) > "$output"
    done
done

