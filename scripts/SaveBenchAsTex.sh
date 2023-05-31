#!/bin/bash

resultsPath="../results";

BENCH_FILE="$resultsPath/bench-results.txt"
TEX_FILE="$resultsPath/bench-results.tex"

function store_bench_to_latex_file() {
    header="\\\\begin{longtblr}[label = {tab:benchmark_%s}, caption = %s benchmark.]{rowhead = 1,hlines, vlines,colspec = {X[c] X[0.6,c] X[0.4,c] X[0.45,l] X[0.45,l] X[0.5,l] X[0.54,l] X[0.23,c] X[0.23,c]},colsep  = 4pt,row{1}  = {font=\\\\small\\\\bfseries, c},measure = vbox}"
    footer="\\end{longtblr}"

    data=()
    first_ds=true;

    # Read the file line by line
    while IFS= read -r line; do
        if [[ "$line" == DS* ]]; then 
            if [ "$first_ds" = false ]; then data+=("$footer" "" "%" "% ==============================================" "%" ""); fi 
            # Line starts with "DS" - format as "caption = genome_name"
            dsi=$(echo "$line" | awk '{print $1}')
            caption=$(echo "$line" | awk '{print $3}')
            formatted_line=$(printf "$header" "$dsi" "${caption^}")
            first_ds=false;
        elif [[ "$line" == PROGRAM* ]]; then
            formatted_line=${line//$'\t'/' & '}
            formatted_line="$formatted_line \\\\ \\hline"
        else
            formatted_line=${line//$'\t'/' & '}
            formatted_line="$formatted_line \\\\"
        fi
        # Append the line and empty line to data
        data+=("$formatted_line" "")
    done < "$BENCH_FILE"

    data+=("$footer")

    # Write the array to a file
    for line in "${data[@]}"; do
        echo "$line" >> "$TEX_FILE"
    done
}

rm -fr $TEX_FILE;

if [ ! -f "$BENCH_FILE" ]; then
  echo "bench file does not exist - run ./RunSeqs.sh on terminal"
  exit 1
fi

store_bench_to_latex_file;
echo "Results saved in LaTeX format: $TEX_FILE"
