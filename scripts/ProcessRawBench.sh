#!/bin/bash
#
resultsPath="../results";
#
function FILTER_INNACURATE_DATA() {
  rm -fr $resultsPath/bench-results.txt
  touch $resultsPath/bench-results.txt
  awk '$2 != -1 && $3 != -1 && $2 != 0 && $3 != 0' "$resultsPath/bench-results-raw.txt" > $resultsPath/bench-results.txt
}

function AVG_RESULTS_REPEATED_TESTS() {
    echo "work in progress..."
}

FILTER_INNACURATE_DATA;
