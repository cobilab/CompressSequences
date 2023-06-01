#!/bin/bash
#
resultsPath="../results";
#
function FILTER_INNACURATE_DATA() {
  rm -fr $resultsPath/bench-results.txt
  touch $resultsPath/bench-results.txt

  # remove tests that failed to compress the sequence
  awk '$2 != -1 && $3 != -1 && $2 != 0 && $3 != 0' "$resultsPath/bench-results-raw.txt" > $resultsPath/bench-results.txt
}

FILTER_INNACURATE_DATA;
