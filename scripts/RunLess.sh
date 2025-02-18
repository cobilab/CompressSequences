#!/bin/bash
#
# ./RunSeqs.sh [--size xs|s|m|l|xl]1> ../results/bench-results-raw.txt 2> ../results/sterr.txt
#
# ==============================================================================
#
function SHOW_HELP() {
  echo " -------------------------------------------------------";
  echo "                                                        ";
  echo " CompressSequences - benchmark                          ";
  echo " Run Script                                             ";
  echo "                                                        ";
  echo " Program options ---------------------------------------";
  echo "                                                        ";
  echo "-h|--help......................................Show this";
  echo "-v|--view-ds|--view-datasets...View sequence names, size";
  echo "           of each in bytes, MB, and GB, and their group";
  echo "-s|--seq|--sequence..........Select sequence by its name";
  echo "-sg|--sequence-grp|--seq-group.Select group of sequences";
  echo "                                           by their size";
  echo "-a|-ga|--genetic-algorithm...Define (folder) name of the";
  echo "                                       genetic algorithm";
  echo "-ds|--dataset......Select sequence by its dataset number";
  echo "-dr|--drange|--dsrange|--dataset-range............Select";
  echo "                   sequences by range of dataset numbers";
  echo "-g|--gen-num....................Define generation number";
  echo "-to|--timeout.............................Define timeout";
  echo "-t|--nthreads....Define number of threads to run JARVIS3"; 
  echo "                                             in parallel";
  echo "                                                        ";
}
#
function CHECK_INPUT () {
  FILE=$1
  if [ -f "$FILE" ]; then
    echo "Input filename exists: $FILE"
  else
    echo -e "\e[31mERROR: input file not found ($FILE)!\e[0m";
    exit;
  fi
}
#
function FIX_SEQUENCE_NAME() {
    sequence="$1"
    echo $sequence
    sequence=$(echo $sequence | sed 's/.mfasta//g; s/.fasta//g; s/.mfa//g; s/.fa//g; s/.seq//g')
    #
    if [ "${sequence^^}" == "CY" ]; then 
        sequence="CY"
    elif [ "${sequence^^}" == "CASSAVA" ]; then 
        sequence="TME204.HiFi_HiC.haplotig1"
    elif [ "${sequence^^}" == "HUMAN" ]; then
        sequence="chm13v2.0"
    fi
    #
    echo "$sequence"
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
  c_time_mem="${sequenceName}_c_time_mem.txt";
  timeout "$timeOut" /bin/time -o $c_time_mem -f "TIME\t%e\tMEM\t%M" $C_COMMAND
  VALIDITY=$?
  # echo "time (s) and mem (GB)"; cat $c_time_mem
  #
  BYTES_CF=`ls -la $FILEC | awk '{ print $5 }'`
  BPS=$(echo "scale=3;$BYTES_CF*8/$BYTES" | bc)
  #
  C_TIME=`printf "%0.3f\n" $(cat $c_time_mem | grep TIME | awk '{ print $2 }')`; 
  C_MEME=`printf "%0.3f\n" $(cat $c_time_mem | grep TIME | awk '{ print $4/1024/1024 }')`;
  #
  # d_time_mem="${sequenceName}_d_time_mem.txt";
  # timeout $timeOut /bin/time -o $d_time_mem -f "TIME\t%e\tMEM\t%M" $D_COMMAND
  # # echo "time (s) and mem (GB)"; cat $d_time_mem
  # #
  # # compare input file to decompressed file; they should have the same sequence
  # diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  # #
  # D_TIME=`printf "%0.3f\n" $(cat $d_time_mem | grep TIME | awk '{ print $2 }')`; 
  # D_MEME=`printf "%0.3f\n" $(cat $d_time_mem | grep TIME | awk '{ print $4/1024/1024 }')`;
  #
  # invalid BYTES_CF and BPS results are marked with -1
  if [ -e "$FILEC" ]; then
    BYTES_CF=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES_CF*8 / $BYTES" | bc);
  else 
    BYTES_CF=-1;
    BPS=-1;
  fi
  #
  # invalid time and mem results are marked with -1
  if [[ ! -s "$c_time_mem" ]]; then # if file is not empty...
    C_TIME=-1;
    C_MEME=-1;
  fi
  #
  if [[ ! -s "$d_time_mem" ]]; then # if file is not empty...
    D_TIME=-1;
    D_MEME=-1;
  fi
  #
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$VALIDITY\t$BYTES\t$BYTES_CF\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$nrun\t$C_COMMAND\n" >> "$output_file_ds";
  #
  rm -fr $FILEC $FILED;
  rm -fr $c_time_mem $d_time_mem
  #
  # remove compressed and uncompressed files
  find $sequencesPath -maxdepth 1 ! -name "*.fa" ! -name "*.seq" -type f -delete
}
#
# ==============================================================================
#
configJson="../config.json"
#
toolsPath="$(grep 'toolsPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )"
numHeadersPerDS="$(grep 'DS_numHeaders' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
DS_sizesBase2="$(grep 'DS_sizesBase2' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
DS_sizesBase10="$(grep 'DS_sizesBase10' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
rawSequencesPath="$(grep 'rawSequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
sequencesPath="$(grep 'sequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
#
timeOut=3600
#
# === ARG PARSING ==============================================================================
#
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --help|-h)
      SHOW_HELP;
      exit;
      shift;
      ;;
    --view-datasets|--view-ds|-v)
      cat $DS_sizesBase2; echo; cat $DS_sizesBase10;
      exit;
      shift;
      ;;
    --genetic-algorithm|--algorithm|--ga|-ga|-a)
      ga="$2";
      shift 2; 
      ;;
    --sequence|--seq|-s)
      sequence="$2";
      FIX_SEQUENCE_NAME "$sequence"
      SEQUENCES+=( "$sequence" );
      shift 2; 
      ;;
    --sequence-group|--sequence-grp|--seq-group|--seq-grp|-sg|-grp)
      size=$(echo "$2" | tr -d "grpGRP")
      SEQUENCES+=( $(awk '/[[:space:]]'$size'/ { print $2 }' "$DS_sizesBase2") );
      shift 2; 
      ;;
    --dataset|-ds)
      dsnum=$(echo "$2" | tr -d "dsDS");
      SEQUENCES+=( "$(awk '/DS'$dsnum'[[:space:]]/{print $2}' "$DS_sizesBase2")" );
      shift 2;
      ;;
    --dataset-range|--dsrange|--drange|-dr)
      input=( $(echo "$2" | sed 's/[:/]/ /g') );
      sortedInput=( $(printf "%s\n" ${input[@]} | sort -n ) );
      dsmin="${sortedInput[0]}";
      dsmax="${sortedInput[1]}";
      SEQUENCES+=( $(awk -v m=$dsmin -v M=$dsmax 'NR>=1+m && NR <=1+M {print $2}' "$DS_sizesBase2") );
      shift 2;
      ;;
    --gen-num|-g)
      gnum="$2";
      shift 2;
      ;;
    --timeout|-to)
      timeOut="$2"
      shift 2;
      ;;
    --nthreads|-t)
      nthreads="$2";
      shift 2;
      ;;
    *) 
      echo "Invalid option: $1"
      exit 1;
      ;;
  esac
done
#
# === MAIN ===========================================================================
#
sizes=("grp1" "grp2" "grp3" "grp4" "grp5"); # to be able to filter SEQUENCES to run by size 
#
resultsPath="../results";
mkdir -p $resultsPath;
#
[ ${#SEQUENCES[@]} -eq 0 ] && SEQUENCES=( $(ls $sequencesPath -S | egrep ".seq$" | sed 's/\.seq$//' | tac) ) 
#
# ------------------------------------------------------------------------------
#
run=1;
for sequenceName in "${SEQUENCES[@]}"; do
    sequence="$sequencesPath/$sequenceName";
    #
    dsx=$(awk '/'$sequenceName'[[:space:]]/ { print $1 }' "$DS_sizesBase2");
    size=$(awk '/'$sequenceName'[[:space:]]/ { print $NF }' "$DS_sizesBase2");
    #
    output_file_ds="$resultsPath/bench-results-raw-${dsx}-${sequenceName}-${size}.txt";
    #
    # --- RUN sequence TESTS ---------------------------------------------------------------------------
    #
    printf "$dsx - $sequenceName - $size \nPROGRAM\tVALIDITY\tBYTES\tBYTES_CF\tBPS\tC_TIME (s)\tC_MEM (GB)\tD_TIME (s)\tD_MEM (GB)\tDIFF\tRUN\tC_COMMAND\n" > "$output_file_ds";
    #
    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
        RUN_TEST "compressor_name" "original_file" "compressed_file" "decompressed_file" "c_command" "d_command" "$run"; run=$((run+1));
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
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo2 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "$toolsPath/GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9 $sequence.seq" "$toolsPath/GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9 $sequence.seq" "$toolsPath/GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9 $sequence.seq" "$toolsPath/GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo2" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9 $sequence.seq" "$toolsPath/GeDe2 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -tm 13:1:0:0:0.7/0:0:0 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        # RUN_TEST "GeCo3" "$sequence.seq" "$sequence.seq.co" "$sequence.seq.de" "$toolsPath/GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 $sequence.seq" "$toolsPath/GeDe3 -v $sequence.seq.co" "$run"; run=$((run+1));
        #
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath --level 5 $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        # RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath --level 10 $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        # RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath --level 15 $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        # RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath --level 20 $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        # RUN_TEST "NAF" "$sequence.fa" "$sequence.naf" "$sequence.naf.out" "$toolsPath/ennaf --fasta --temp-dir $sequencesPath --level 22 $sequence.fa -o $sequence.naf" "$toolsPath/unnaf $sequence.naf -o $sequence.fa.out" "$run"; run=$((run+1));
        #
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "$toolsPath/mbgc -c 0 -i $sequence.fa $sequence.mbgc" "$toolsPath/mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "$toolsPath/mbgc -i $sequence.fa $sequence.mbgc" "$toolsPath/mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        # RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "$toolsPath/mbgc -c 2 -i $sequence.fa $sequence.mbgc" "$toolsPath/mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        # RUN_TEST "MBGC" "$sequence.fa" "$sequence.mbgc" "$sequence.mbgc.out" "$toolsPath/mbgc -c 3 -i $sequence.fa $sequence.mbgc" "$toolsPath/mbgc -d $sequence.mbgc $sequencesPath" "$run"; run=$((run+1));
        # #
        # RUN_TEST "AGC" "$sequence.fa" "$sequence.agc" "$sequence.agc.out" "$toolsPath/agc create $sequence.fa -o $sequence.agc" "$toolsPath/agc getcol $sequence.agc > $sequence.agc.out" "$run"; run=$((run+1));
        #
        RUN_TEST "PAQ8" "$sequence.seq" "$sequence.seq.paq8l" "$sequence.seq.paq8l.out" "$toolsPath/paq8l -1 $sequence.seq" "$toolsPath/paq8l -d $sequence.seq.paq8l.out $sequencesPath" "$run"; run=$((run+1));
    fi
    #
    #
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 1 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 5 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 10 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 15 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 20 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -l 24 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS2_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 $sequence.seq" "$toolsPath/JARVIS2 -d $sequence.seq.jc" "$run"; run=$((run+1));
    #
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 1 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 5 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 10 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 15 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 20 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 25 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    # RUN_TEST "JARVIS3_BIN" "$sequence.seq" "$sequence.seq.jc" "$sequence.seq.jc.jd" "$toolsPath/JARVIS3 -v -l 27 $sequence.seq" "$toolsPath/JARVIS3 -d $sequence.seq.jc" "$run"; run=$((run+1));
    #
    # JARVIS2/3.sh were developed to run on larger sequences
    # if [ "$size" = "grp4" ] || [ "$size" = "grp5" ]; then 
    #   # necessary to run JARVIS2/3.sh
    #   cp ../bin/bbb ../bin/bzip2 ../bin/*Fast* ../bin/XScore* ../bin/JARVIS* . 
    #   RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input $sequence.seq" "./$toolsPath/JARVIS2.sh --decompress --threads 3 --dna --input $sequence.seq.tar" "$((run+=1))"
    #   RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS2.sh --level -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 270MB --threads 3 --dna --input $sequence.seq" "./$toolsPath/JARVIS2.sh --decompress --threads 3 --dna --input $sequence.seq.tar" "$((run+=1))"
    #   RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS2.sh --level -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 --block 150MB --threads 6 --dna --input $sequence.seq" "./$toolsPath/JARVIS2.sh --decompress --threads 6 --dna --input $sequence.seq.tar" "$((run+=1))"
    #   RUN_TEST "JARVIS2_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS2.sh --level -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 --block 100MB --threads 8 --dna --input $sequence.seq" "./$toolsPath/JARVIS2.sh --decompress --threads 8 --dna --input $sequence.seq.tar" "$((run+=1))"
    #   #
    #   # note: JARVIS3.sh can compress but cannot decompress
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh --block 16MB --threads 8 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 1 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 5 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 10 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 15 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 20 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 25 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   RUN_TEST "JARVIS3_SH" "$sequence.seq" "$sequence.seq.tar" "$sequence.seq.tar.out" "./$toolsPath/JARVIS3.sh -l 27 --input $sequence.seq" "./$toolsPath/JARVIS3 --decompress --threads 4 --input $sequence.seq.tar" "$run"; run=$((run+1));
    #   # remove all stuff copied from bin which was necessary to run JARVIS2/3.sh
    #   rm -fr bbb bzip2 *Fast* XScore* JARVIS*
    # fi
    #
    RUN_TEST "LZMA" "$sequence.seq.orig" "$sequence.seq.orig.lzma" "$sequence.seq.orig" "lzma -9 -f -k $sequence.seq.orig" "lzma -f -k -d $sequence.seq.orig.lzma" "$run"; run=$((run+1));
    #
    RUN_TEST "BZIP2" "$sequence.seq.orig" "$sequence.seq.orig.bz2" "$sequence.seq.orig" "bzip2 -9 -f -k $sequence.seq.orig" "bzip2 -f -k -d $sequence.seq.orig.lzma" "$run"; run=$((run+1));
    #
    # RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "$toolsPath/bsc-m03 e $sequence.seq $sequence.seq.bsc -b800000000" "$toolsPath/bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    # RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "$toolsPath/bsc-m03 e $sequence.seq $sequence.seq.bsc -b400000000" "$toolsPath/bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    RUN_TEST "BSC-m03" "$sequence.seq" "$sequence.seq.bsc" "$sequence.seq.bsc.out" "$toolsPath/bsc-m03 e $sequence.seq $sequence.seq.bsc -b4096000" "$toolsPath/bsc-m03 d $sequence.seq.bsc $sequence.seq.bsc.out" "$run"; run=$((run+1));
    #
    # RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "$toolsPath/MFCompressC -v -1 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "$toolsPath/MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    # RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "$toolsPath/MFCompressC -v -2 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "$toolsPath/MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    RUN_TEST "MFC" "$sequence.seq.orig" "$sequence.seq.mfc" "$sequence.seq.d" "$toolsPath/MFCompressC -v -3 -p 1 -t 1 -o $sequence.seq.mfc $sequence.seq.orig" "$toolsPath/MFCompressD -o $sequence.seq.d $sequence.seq.mfc" "$run"; run=$((run+1));
    #
    RUN_TEST "DMcompress" "$sequence.seq.orig" "$sequence.seq.orig.c" "$sequence.seq.orig.c.d" "$toolsPath/DMcompressC $sequence.seq.orig" "$toolsPath/DMcompressD $sequence.seq.orig.c" "$run"; run=$((run+1));
    #
    # note: this MEMRGC test always returns CBYTES=52, regarless of sequence length or complexity, thus this test is not executed
    # # RUN_TEST "MEMRGC" "$sequence.fa" "$sequence.memrgc" "$genome_memrgc_out.fa" "$toolsPath/memrgc e -m file -r $sequence.fa -t $sequence.fa -o $sequence.memrgc" "$toolsPath/memrgc d -m file -r $sequence.fa -t $sequence.memrgc -o $genome_memrgc_out.fa" "$run"; run=$((run+1));
    #
    RUN_TEST "CMIX" "$sequence.fa" "$sequence.cmix" "$genome_cmix_out.fa" "$toolsPath/cmix -n $sequence.fa $sequence.cmix" "$toolsPath/cmix -d -r $sequence.fa -t $sequence.cmix -o $genome_cmix_out.fa" "$run"; run=$((run+1));
    #
    # ==============================================================================
    #
done
# 
