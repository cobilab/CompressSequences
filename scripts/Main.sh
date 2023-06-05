#!/bin/bash
#
./CleanCandDfiles.sh # optional but recommended
./Install_Tools.sh
./GetSeqs.sh
./CategorizeSeqBySize.sh
./RunSeqs.sh 1> ../results/bench-results-raw.txt 2> sterr.txt  # ./RunSeqs.sh --size [xs|s|m|l|xl]
./SaveBenchAsTex.sh # optional 
./ProcessRawBench.sh
./Plot.sh
