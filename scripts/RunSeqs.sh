#!/bin/bash
#
resultsPath="../results";
csv_dsToSize="dsToSize.csv";
#
declare -A dsToSize;
#
GENOMES=( $(ls -S | egrep ".seq$" | sed 's/\.seq$//' | tac) ) # ( "test" ) # manual alternative
#
# ==============================================================================
#
function LOAD_CSV_DSTOSIZE() {
  while IFS=, read -r ds bytes size; do
    # Skip the header line
    if [[ "$ds" != "ds" ]]; then
      dsToSize[$ds]=$size;
    fi
  done < $csv_dsToSize;
}
#
# RUN_TEST "compressor_name" "original_file" "compressed_file" "decompressed_file" "c_command" "d_command" "$run"; run=$((run+1));
function RUN_TEST() {
  #
  NAME="$1";
  IN_FILE="$2";
  FILEC="$3";
  FILED="$4";
  C_COMMAND="$5";
  D_COMMAND="$6";
  nrun="$7";
  #
  # some compressors need extra preprocessing
  if [[ $NAME == MFC* || $NAME == DMcompress* ]]; then 
    echo ">x" > $IN_FILE;
    cat ${IN_FILE%.orig} >> $IN_FILE;
    printf "\n" >> $IN_FILE;
  elif [[ $NAME == LZMA* || $NAME == BZIP2* ]]; then
    cp ${IN_FILE%.orig} $IN_FILE;
  fi
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;
  #
  # https://man7.org/linux/man-pages/man1/time.1.html
  # %e: (Not in tcsh(1).)  Elapsed real time (in seconds).
  # %M: Maximum resident set size of the process during its lifetime, in Kbytes.
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/1"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $C_BYTES*8 / $BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/1"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$nrun\n" | tee -a $resultsPath/bench-results-raw.txt;
  #
  rm -fr c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
}
#
# === MAIN ===========================================================================
#
LOAD_CSV_DSTOSIZE;
#
mkdir -p $resultsPath naf_out mbgc_out paq8l_out;
rm -fr $resultsPath/bench-results-raw.*;
#
bin_path="../bin/";
run=0;
#
for i in "${!GENOMES[@]}"; do
    # before running the tests, determine size type of sequence to know: 
    # - the number of times each test should be executed;
    # - whether c/d time should be in ms, s, m,...
    size=${dsToSize[${GENOMES[i]}]};
    num_runs_to_repeat=1;
    str_time="m";
    if [ $size == "xs" ]; then
      num_runs_to_repeat=10;
      str_time="ms";
    fi
    #
    # --- RUN GENOME TESTS ---------------------------------------------------------------------------
    #
    printf "DS$(($i+1)) - ${GENOMES[i]}\nPROGRAM\tBYTES\tC_BYTES\tBPS\tC_TIME ($str_time)\tC_MEM (GB)\tD_TIME ($str_time)\tD_MEM (GB)\tDIFF\tRUN\n" | tee -a $resultsPath/bench-results-raw.txt;
    #
    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
        # RUN_TEST "compressor_name" "original_file" "compressed_file" "decompressed_file" "c_command" "d_command" "$run"; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo2 -v -tm 13:1:0:0:0.7/0:0:0 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo2 -v -tm -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -tm 13:1:0:0:0.7/0:0:0 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 ${GENOMES[i]}.seq" "GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v -l 3 ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v -l 5 ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v -l 10 ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v -l 15 ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 ${GENOMES[i]}.seq" "JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ --level 5 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ --level 10 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ --level 15 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ --level 20 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "ennaf --fasta --temp-dir naf_out/ --level 22 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "mbgc -c 0 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "mbgc -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "mbgc -c 2 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "mbgc -c 3 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "AGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.agc" "${GENOMES[i]}_agc_out.fa" "agc create ${GENOMES[i]}.fa -o ${GENOMES[i]}.agc" "agc getcol ${GENOMES[i]}.agc > ${GENOMES[i]}_agc_out.fa" "$run"; done; run=$((run+1));
        #
        # other paq tests are very slow;
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "PAQ8" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.paq8l" "paq8l_out/${GENOMES[i]}.seq" "paq8l -1 ${GENOMES[i]}.seq" "paq8l -d ${GENOMES[i]}.seq.paq8l paq8l_out" "$run"; done; run=$((run+1));
    else
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo2 -v -tm 13:1:0:0:0.7/0:0:0 ${GENOMES[i]}.seq" "${bin_path}GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo2" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo2 -v -tm -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe2 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -tm 13:1:0:0:0.7/0:0:0 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "GeCo3" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.co" "${GENOMES[i]}.seq.de" "${bin_path}GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 ${GENOMES[i]}.seq" "${bin_path}GeDe3 -v ${GENOMES[i]}.seq.co" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v -l 3 ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v -l 5 ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v -l 10 ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v -l 15 ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS1" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 ${GENOMES[i]}.seq" "${bin_path}JARVIS -v -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 5 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 10 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 15 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 20 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "NAF" "${GENOMES[i]}.fa" "naf_out/${GENOMES[i]}.naf" "naf_out/${GENOMES[i]}.fa" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 22 ${GENOMES[i]}.fa -o naf_out/${GENOMES[i]}.naf" "${bin_path}unnaf naf_out/${GENOMES[i]}.naf -o naf_out/${GENOMES[i]}.fa" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "${bin_path}mbgc -c 0 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "${bin_path}mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "${bin_path}mbgc -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "${bin_path}mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "${bin_path}mbgc -c 2 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "${bin_path}mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MBGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.mbgc" "mbgc_out/${GENOMES[i]}.fa" "${bin_path}mbgc -c 3 -i ${GENOMES[i]}.fa ${GENOMES[i]}.mbgc" "${bin_path}mbgc -d ${GENOMES[i]}.mbgc mbgc_out" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "AGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.agc" "${GENOMES[i]}_agc_out.fa" "${bin_path}agc create ${GENOMES[i]}.fa -o ${GENOMES[i]}.agc" "${bin_path}agc getcol ${GENOMES[i]}.agc > ${GENOMES[i]}_agc_out.fa" "$run"; done; run=$((run+1));
        #
        for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "PAQ8" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.paq8l" "paq8l_out/${GENOMES[i]}.seq" "${bin_path}paq8l -1 ${GENOMES[i]}.seq" "${bin_path}paq8l -d ${GENOMES[i]}.seq.paq8l paq8l_out" "$run"; done; run=$((run+1));
    fi
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 1 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 2 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 3 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 4 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 5 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 10 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 15 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 20 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -l 24 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_BIN" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.jc" "${GENOMES[i]}.seq.jc.jd" "${bin_path}JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 ${GENOMES[i]}.seq" "${bin_path}JARVIS2 -d ${GENOMES[i]}.seq.jc" "$run"; done; run=$((run+1));
    #
    cp ../bin/* . 
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_SH" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.tar" "${GENOMES[i]}.seq.tar.out" "$./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input ${GENOMES[i]}.seq" "./JARVIS2.sh --decompress --threads 3 --dna --input ${GENOMES[i]}.seq.tar" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_SH" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.tar" "${GENOMES[i]}.seq.tar.out" "$./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input ${GENOMES[i]}.seq" "./JARVIS2.sh --decompress --threads 3 --dna --input ${GENOMES[i]}.seq.tar" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_SH" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.tar" "${GENOMES[i]}.seq.tar.out" "$./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 150MB --threads 6 --dna --input ${GENOMES[i]}.seq" "./JARVIS2.sh --decompress --threads 6 --dna --input ${GENOMES[i]}.seq.tar" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "JARVIS2_SH" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.tar" "${GENOMES[i]}.seq.tar.out" "$./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 100MB --threads 8 --dna --input ${GENOMES[i]}.seq" "./JARVIS2.sh --decompress --threads 8 --dna --input ${GENOMES[i]}.seq.tar" "$run"; done; run=$((run+1));
    # remove all stuff copied from bin (they were added to current directory to run JARVIS2.sh properly)
    find . -maxdepth 1 ! -name "*.*" -type f -delete && rm -fr JARVIS2.sh v0.2.1.tar.gz
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "LZMA" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.orig.lzma" "${GENOMES[i]}.seq.orig" "lzma -9 -f -k ${GENOMES[i]}.seq.orig" "lzma -f -k -d ${GENOMES[i]}.seq.orig.lzma" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "BZIP2" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.orig.bz2" "${GENOMES[i]}.seq.orig" "bzip2 -9 -f -k ${GENOMES[i]}.seq.orig" "bzip2 -f -k -d ${GENOMES[i]}.seq.orig.lzma" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "BSC-m03" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.bsc" "${GENOMES[i]}.seq.bsc.out" "${bin_path}bsc-m03 e ${GENOMES[i]}.seq ${GENOMES[i]}.seq.bsc -b800000000" "${bin_path}bsc-m03 d ${GENOMES[i]}.seq.bsc ${GENOMES[i]}.seq.bsc.out" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "BSC-m03" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.bsc" "${GENOMES[i]}.seq.bsc.out" "${bin_path}bsc-m03 e ${GENOMES[i]}.seq ${GENOMES[i]}.seq.bsc -b400000000" "${bin_path}bsc-m03 d ${GENOMES[i]}.seq.bsc ${GENOMES[i]}.seq.bsc.out" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "BSC-m03" "${GENOMES[i]}.seq" "${GENOMES[i]}.seq.bsc" "${GENOMES[i]}.seq.bsc.out" "${bin_path}bsc-m03 e ${GENOMES[i]}.seq ${GENOMES[i]}.seq.bsc -b4096000" "${bin_path}bsc-m03 d ${GENOMES[i]}.seq.bsc ${GENOMES[i]}.seq.bsc.out" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MFC" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.mfc" "${GENOMES[i]}.seq.d" "${bin_path}MFCompressC -v -1 -p 1 -t 1 -o ${GENOMES[i]}.seq.mfc ${GENOMES[i]}.seq.orig" "${bin_path}MFCompressD -o ${GENOMES[i]}.seq.d ${GENOMES[i]}.seq.mfc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MFC" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.mfc" "${GENOMES[i]}.seq.d" "${bin_path}MFCompressC -v -2 -p 1 -t 1 -o ${GENOMES[i]}.seq.mfc ${GENOMES[i]}.seq.orig" "${bin_path}MFCompressD -o ${GENOMES[i]}.seq.d ${GENOMES[i]}.seq.mfc" "$run"; done; run=$((run+1));
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MFC" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.mfc" "${GENOMES[i]}.seq.d" "${bin_path}MFCompressC -v -3 -p 1 -t 1 -o ${GENOMES[i]}.seq.mfc ${GENOMES[i]}.seq.orig" "${bin_path}MFCompressD -o ${GENOMES[i]}.seq.d ${GENOMES[i]}.seq.mfc" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "DMcompress" "${GENOMES[i]}.seq.orig" "${GENOMES[i]}.seq.orig.c" "${GENOMES[i]}.seq.orig.c.d" "${bin_path}DMcompressC ${GENOMES[i]}.seq.orig" "${bin_path}DMcompressD ${GENOMES[i]}.seq.orig.c" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "MEMRGC" "${GENOMES[i]}.fa" "${GENOMES[i]}.memrgc" "${GENOMES[i]}_memrgc_out.fa" "${bin_path}memrgc e -m file -r ${GENOMES[i]}.fa -t ${GENOMES[i]}.fa -o ${GENOMES[i]}.memrgc" "${bin_path}memrgc d -m file -r ${GENOMES[i]}.fa -t ${GENOMES[i]}.memrgc -o ${GENOMES[i]}_memrgc_out.fa" "$run"; done; run=$((run+1));
    #
    for (( subrun=0; subrun<$num_runs_to_repeat; subrun++ )); do RUN_TEST "CMIX" "${GENOMES[i]}.fa" "${GENOMES[i]}.cmix" "${GENOMES[i]}_cmix_out.fa" "${bin_path}cmix -n ${GENOMES[i]}.fa ${GENOMES[i]}.cmix" "${bin_path}cmix -d -r ${GENOMES[i]}.fa -t ${GENOMES[i]}.cmix -o ${GENOMES[i]}_cmix_out.fa" "$run"; done; run=$((run+1));
    #
    # ==============================================================================
    #
    printf "\n\n"
    #
done
# 
