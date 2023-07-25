#!/bin/bash

resultsPath="../results";
errPath="$resultsPath/err";

mkdir -p $resultsPath $errPath;

./RunTests.sh --size xs 1> $resultsPath/bench-results-raw-xs.txt 2> $errPath/stderr_xs.txt &
./RunTests.sh --size s 1> $resultsPath/bench-results-raw-s.txt 2> $errPath/stderr_s.txt &
./RunTests.sh --size m 1> $resultsPath/bench-results-raw-m.txt 2> $errPath/stderr_m.txt &
# ./RunTests.sh --size l 1> $resultsPath/bench-results-raw-l.txt 2> $errPath/stderr_l.txt &

./RunTests.sh --genome chm13v2.0 1> $resultsPath/bench-results-raw-ds25-l.txt 2> $errPath/stderr_ds25_l.txt &
