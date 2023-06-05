#!/bin/bash
#
resultsPath="../results";
sizes=("xs" "s" "m" "l" "xl")
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
  rm -fr *grp*

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
FILTER_INNACURATE_DATA;
