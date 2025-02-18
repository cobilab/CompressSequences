#!/bin/bash
#
configJson="../config.json"
DS_sizesBase2="$(grep 'DS_sizesBase2' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
DS_sizesBase10="$(grep 'DS_sizesBase10' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
#
# === FUNCTIONS ===========================================================================
#
function SHOW_HELP() {
 echo " -------------------------------------------------------";
 echo "                                                        ";
 echo " OptimJV3 - optimize JARVIS3 CM and RM parameters       ";
 echo " Process Bench Script"
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
datasetsArr=($(ls $resultsPath| grep 'DS[0-9]*' | sort -u|sort -V))
datasetsArr=(bench-results-raw-DS37-chm13v2.0-JV3_localSearch-grp5.txt 
bench-results-raw-DS37-chm13v2.0-JV3_sampling2-grp5.txt 
bench-results-raw-DS37-chm13v2.0-JV3_sampling2_200gens-grp5.txt 
bench-results-raw-DS37-chm13v2.0-grp5.txt)
#
for dsFile in "${datasetsArr[@]}"; do
    dsx=$(echo $dsFile|grep -o 'DS[0-9]*')
    sequenceName=$(awk '/'$dsx'[[:space:]]/{print $2}' "$DS_sizesBase2")
    size=$(awk '/'$sequenceName'[[:space:]]/ { print $NF }' "$DS_sizesBase2")
    output="bench-results-$dsx-$sequenceName-$size.tsv"

    allResFromDsx=( $( ls $resultsPath/*-$dsx-*.txt) )
    (
        head -n2 "$resultsPath/${allResFromDsx[0]}"
        for resFile in "${allResFromDsx[@]}"; do
            awk -F'\t' -v OFS="\t" 'NR>2 {
                if ($2==0 && $4!=-1 && $5!=-1 && $6!=-1 && $7!=-1) { 
                    if ($1 ~ /^BSC-m03/) $1="BSC_m03"
                    if ($1 ~ /^JV3_e/) $1="JV3_GA"
                    if ($1 ~ /^JV3_sampling/ && $1 !~ /200gens/) $1="JV3_SG"
                    if ($1 ~ /^JV3_sampling2_200gens/) $1="JV3_SG200"
                    if ($1 ~ /^JV3-randomSearch/) $1="JV3_RS"
                    if ($1 ~ /^JV3_randomSearch/) $1="JV3_RS"
                    if ($1 ~ /^JV3-localSearch/) $1="JV3_LS"
                    if ($1 ~ /^JV3_localSearch/) $1="JV3_LS"
                    print 
                }
            }' $resultsPath/$resFile
        done | sort -k2n -k4n -k6n | awk -F'\t' -v OFS="\t" -v gaCounter=0 '
            # Filter top 10 JV3_GA entries after sorting
            $1 ~ /JV3_GA/ && gaCounter < 10 { gaCounter++; print }
            $1 !~ /JV3_GA/ { print }'
    ) > $resultsPath/$output
done
#
grpsArr=($(ls $resultsPath/*.tsv |grep -o 'grp[0-9]*'|sort -V|uniq))
for grp in ${grpsArr[@]}; do
    datasetsArr=($(ls $resultsPath/*$grp*.tsv | grep 'DS[0-9]*' | sort -u|sort -V))
    output="$resultsPath/bench-results-$grp.tsv"
    ( echo "$grp"
    awk 'NR==2' "${datasetsArr[0]}"
    for dsFile in "${datasetsArr[@]}"; do
        awk 'NR>2' $dsFile
    done | sort -k2n -k5n -k6n ) > $output
done
