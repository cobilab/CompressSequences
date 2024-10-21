#!/bin/bash
#
./InstallTools.sh
./DownloadFASTA.sh     # downloads FASTA files by NBCI id
./GetAlcoRFASTA.sh     # simulates and stores 2 synthetic FASTA sequences
./FASTA2seq.sh         # cleans FASTA files and stores raw sequence files
./DownloadDNAcorpus.sh # download raw sequences from a balanced sequence corpus
./GetDSinfo.sh         # map sequences into their ids, sorted by size; view sequences info
#
./RunTestsExample.sh   # run bench
./ProcessRawBench.sh   # sort results by BPS and time
./Plot.sh              # plot sorted results