#!/bin/bash

resultsPath="../results";
mkdir -p $resultsPath;

./RunTests.sh --size xs > ../results/bench-results-raw-xs.txt 2>&1 &
# ./RunTests.sh --size s > ../results/bench-results-raw-s.txt 2>&1 &
# ./RunTests.sh --size m > ../results/bench-results-raw-m.txt 2>&1 &
# ./RunTests.sh --size l > ../results/bench-results-raw-l.txt 2>&1
# 
# ./RunTests.sh --genome chm13v2.0 > ../results/bench-results-raw-ds25-l.txt 2>&1 &
