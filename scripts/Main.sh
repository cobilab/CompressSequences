#!/bin/bash
#
./CleanCandDfiles.sh # optional but recommended
./Install_Tools.sh
./GetSeqs.sh
./CategorizeSeqBySize.sh
./RunSeqs.sh
./SaveBenchAsTex.sh # optional 
./ProcessRawBench.sh
./Plot.sh
