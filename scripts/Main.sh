#!/bin/bash
#
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    *) 
        echo "This program does not have options"
        exit 1;
        ;;
    esac
done
#
./InstallTools.sh      # install listed compressors, GTO, and AlcoR
./DownloadFASTA.sh     # downloads FASTA files
./GetCassava.sh        # gunzip cassava files
./GetAlcoRFASTA.sh     # simulates and stores 2 synthetic FASTA sequences
./FASTA2seq.sh         # cleans FASTA files and stores raw sequence files
./DownloadDNAcorpus.sh # download raw sequences from a balanced sequence corpus
./GetDSinfo.sh         # map sequences into their ids, sorted by size; view sequences info
#
./RunTestsExample.sh   # run bench
./ProcessBenchRes.sh   # sort results by BPS and time
./Plot.sh              # plot sorted results from bench, for each sequence and eache sequence group
#
./Plot.sh --mode NGA   # plot bench results with added results from random and local search, for each sequence and eache sequence group
./Plot.sh --mode all   # plot bench results with added results from all implemented search algorithms, for each sequence and eache sequence group
