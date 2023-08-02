#!/bin/bash
#
# ./RunSeqs.sh [--size xs|s|m|l|xl]1> ../results/bench-results-raw.txt 2> ../results/sterr.txt
#
resultsPath="../results";
binPath="../bin/";
#
csv_dsToSize="dsToSize.csv";
declare -A dsToSize;

sizes=("xs" "s" "m" "l" "xl"); # to be able to filter SEQUENCES_NAMES to run by size 

  sequencesPath="$HOME/sequences";
ALL_SEQUENCES_IN_DIR=( $(ls $sequencesPath -S | egrep ".seq$" | sed 's/\.seq$//' | tac) ) # ( "test" ) # manual alternative
SEQUENCES_NAMES=() # gens that have the required size will be added here
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
# ==============================================================================
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
  timeout $timeOut /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND \
  |& grep "TIME" \
  |& awk '{ printf $2"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    BYTES_CF=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES_CF*8 / $BYTES" | bc);
  else 
    BYTES_CF=-1;
    BPS=-1;
  fi
  #
  timeout $timeOut /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND \
  |& grep "TIME" \
  |& awk '{ printf $2"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  if [[ -s "c_time_mem.txt" ]]; then # if file is not empty...
    C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
    C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`; 
  else
    C_TIME=-1;
    C_MEME=-1;
  fi
  #
  if [[ -s "d_time_mem.txt" ]]; then # if file is not empty...
    D_TIME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $1 }')`;
    D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  else
    D_TIME=-1;
    D_MEME=-1;
  fi
  #
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$BYTES_CF\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$nrun\t$C_COMMAND\n";
  #
  rm -fr $FILEC $FILED;
  rm -fr c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  ./CleanCandDfiles.sh;
  #
}
#
# === MAIN ===========================================================================
#
LOAD_CSV_DSTOSIZE;

mkdir -p $resultsPath;

# Initialize variables
timeOut=3600;

# if one or more sizes are choosen, select all SEQUENCES_NAMES with those sizes
for size in "${sizes[@]}"; do
  if [[ "$*" == *"--size $size"* || "$*" == *"-s $size"* ]]; then
    for seq in "${ALL_SEQUENCES_IN_DIR[@]}"; do
        if [[ "${dsToSize[$seq]}" == "$size" ]]; then
            SEQUENCES_NAMES+=("$seq");
        fi
    done
  fi
done

# if one or more gens are choosen, add them to array if they aren't there yet
for seq in "${ALL_SEQUENCES_IN_DIR[@]}"; do
  if [[ "$*" == *"--sequence $seq"* || "$*" == *"-s $seq"* ]]; then
    if ! echo "${SEQUENCES_NAMES[@]}" | grep -q -w "$seq"; then
      SEQUENCES_NAMES+=("$seq");
    fi
  fi
done

# if nothing is choosen, all SEQUENCES_NAMES will be selected
if [ ${#SEQUENCES_NAMES[@]} -eq 0 ]; then
  SEQUENCES_NAMES=("${ALL_SEQUENCES_IN_DIR[@]}");
fi

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --timeout|-to)
      timeOut="$2"
      shift # past argument
      shift # past value
      ;;
    *) 
      # Ignore any other arguments
      shift
      ;;
  esac
done

#
# ------------------------------------------------------------------------------
#
run=1;
for sequenceName in "${SEQUENCES_NAMES[@]}"; do
    sequence="$sequencesPath/$sequenceName";
    #
    size=${dsToSize[$sequenceName]};
    output_file_ds="$resultsPath/bench-results-raw-ds${ds_id}-${size}.txt";
    #
    # --- RUN sequence TESTS ---------------------------------------------------------------------------
    #
    printf "DS$ds_id - $sequenceName - $size \nPROGRAM\tBYTES\tBYTES_CF\tBPS\tC_TIME (s)\tC_MEM (GB)\tD_TIME (s)\tD_MEM (GB)\tDIFF\tRUN\tC_COMMAND\n";
    #
    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
        # RUN_TEST "compressor_name" "original_file" "compressed_file" "decompressed_file" "c_command" "d_command" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo2 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo2 -v -tm -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 $sequence.seq" "GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v -l 3 $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v -l 5 $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v -l 10 $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v -l 15 $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 $sequence.seq" "JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        #
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath --level 5 $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath --level 10 $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath --level 15 $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath --level 20 $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "ennaf --fasta --temp-dir $sequencesPath --level 22 $sequence.fa -o $sequence.naf" "unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        #
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "mbgc -c 0 -i $sequence.fa $sequence.mbgc" "mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "mbgc -i $sequence.fa $sequence.mbgc" "mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "mbgc -c 2 -i $sequence.fa $sequence.mbgc" "mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "mbgc -c 3 -i $sequence.fa $sequence.mbgc" "mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        #
        RUN_TEST "AGC" "$sequence.fa" "$sequence.agc" "$sequence.agc.out" "agc create $sequence.fa -o $sequence.agc" "agc getcol $sequence.agc > $sequence.agc.out" "$run"; run=$((run+1));
        #
        # other paq tests are very slow;
        RUN_TEST "PAQ8" "$sequence.seq" "$sequence.seq.paq8l" "$sequence.seq.paq8l.out" "paq8l -1 $sequence.seq" "paq8l -d $sequence.seq.paq8l.out $sequencesPath" "$run"; run=$((run+1));
    else
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo2 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "${binPath}GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9 $sequence.seq" "${binPath}GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9 $sequence.seq" "${binPath}GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9 $sequence.seq" "${binPath}GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9 $sequence.seq" "${binPath}GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "${binPath}GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 $sequence.seq" "${binPath}GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v -l 3 $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v -l 5 $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v -l 10 $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v -l 15 $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        RUN_TEST "JARVIS1" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 $sequence.seq" "${binPath}JARVIS -v -d $sequence.seq.jc" "$run"; run=$((run+1));
        #
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath --level 5 $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath --level 10 $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath --level 15 $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath --level 20 $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "${binPath}ennaf --fasta --temp-dir $sequencesPath --level 22 $sequence.fa -o $sequence.naf" "${binPath}unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        #
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "${binPath}mbgc -c 0 -i $sequence.fa $sequence.mbgc" "${binPath}mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "${binPath}mbgc -i $sequence.fa $sequence.mbgc" "${binPath}mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "${binPath}mbgc -c 2 -i $sequence.fa $sequence.mbgc" "${binPath}mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "${binPath}mbgc -c 3 -i $sequence.fa $sequence.mbgc" "${binPath}mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        #
        RUN_TEST "AGC" "$sequence.fa" "$sequence.agc" "$sequence.agc.out" "${binPath}agc create $sequence.fa -o $sequence.agc" "${binPath}agc getcol $sequence.agc > $sequence.agc.out" "$run"; run=$((run+1));
        #
        RUN_TEST "PAQ8" "$sequence.seq" "$sequence.seq.paq8l" "$sequence.seq.paq8l.out" "${binPath}paq8l -1 $sequence.seq" "${binPath}paq8l -d $sequence.seq.paq8l.out $sequencesPath" "$run"; run=$((run+1));
    fi
    #
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 1 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 5 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 10 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 15 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 20 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -l 24 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 $sequence.seq" "${binPath}JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    #
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 1 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 5 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 10 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 15 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 20 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 25 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "${binPath}JARVIS3 -v -l 27 $sequence.seq" "${binPath}JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    #
    # JARVIS2/3.sh were developed to run on larger sequences
    if [ "$size" = "l" ] || [ "$size" = "xl" ]; then 
      # necessary to run JARVIS2/3.sh
      cp ../bin/bbb ../bin/bzip2 ../bin/*Fast* ../bin/XScore* ../bin/JARVIS* . 
      RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input $sequence.seq" "./JARVIS2.sh --decompress --threads 3 --dna --input $sequence.seq.tar" "$((run+=1))"
      RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input $sequence.seq" "./JARVIS2.sh --decompress --threads 3 --dna --input $sequence.seq.tar" "$((run+=1))"
      RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 150MB --threads 6 --dna --input $sequence.seq" "./JARVIS2.sh --decompress --threads 6 --dna --input $sequence.seq.tar" "$((run+=1))"
      RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 100MB --threads 8 --dna --input $sequence.seq" "./JARVIS2.sh --decompress --threads 8 --dna --input $sequence.seq.tar" "$((run+=1))"
      #
      # note: JARVIS3.sh can compress but cannot decompress
      # for now jarvis3_bin is used to decompress
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh --block 16MB --threads 8 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 1 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 5 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 10 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 15 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 20 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 25 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./JARVIS3.sh -l 27 --input $sequence.seq" "./JARVIS3.sh --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
      # remove all stuff copied from bin which was necessary to run JARVIS2/3.sh
      rm -fr bbb bzip2 *Fast* XScore* JARVIS*
    fi
    #
    RUN_TEST "LZMA" "$sequence.seq.orig" "$sequence.seq.orig.lzma" "$sequence.seq.orig" "lzma -9 -f -k $sequence.seq.orig" "lzma -f -k -d $sequence.seq.orig.lzma" "$run"; run=$((run+1));
    #
    RUN_TEST "BZIP2" "$sequence.seq.orig" "$sequence.seq.orig.bz2" "$sequence.seq.orig" "bzip2 -9 -f -k $sequence.seq.orig" "bzip2 -f -k -d $sequence.seq.orig.lzma" "$run"; run=$((run+1));
    #
    RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "${binPath}bsc-m03 e $sequence.seq $sequence.seq.bsc -b800000000" "${binPath}bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "${binPath}bsc-m03 e $sequence.seq $sequence.seq.bsc -b400000000" "${binPath}bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "${binPath}bsc-m03 e $sequence.seq $sequence.seq.bsc -b4096000" "${binPath}bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    #
    RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "${binPath}MFCompressC -v -1 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "${binPath}MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "${binPath}MFCompressC -v -2 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "${binPath}MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "${binPath}MFCompressC -v -3 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "${binPath}MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    #
    RUN_TEST "DMcompress" "$sequence.seq.orig" "$sequence.seq.orig.c" "$sequence.seq.orig.c.d" "${binPath}DMcompressC $sequence.seq.orig" "${binPath}DMcompressD $sequence.seq.orig.c" "$run"; run=$((run+1));
    #
    RUN_TEST "MEMRGC" "$sequence.fa" "$sequence.memrgc" "$genome_memrgc_out.fa" "${binPath}memrgc e -m file -r $sequence.fa -t $sequence.fa -o $sequence.memrgc" "${binPath}memrgc d -m file -r $sequence.fa -t $sequence.memrgc -o $genome_memrgc_out.fa" "$run"; run=$((run+1));
    #
    RUN_TEST "CMIX" "$sequence.fa" "$sequence.cmix" "$genome_cmix_out.fa" "${binPath}cmix -n $sequence.fa $sequence.cmix" "${binPath}cmix -d -r $sequence.fa -t $sequence.cmix -o $genome_cmix_out.fa" "$run"; run=$((run+1));
    #
    # ==============================================================================
    #
    rm -fr $cleanOrdFaFile $cleanOrdSeqFile *_sortmf* *_fastaAnaly*;
done
# 
