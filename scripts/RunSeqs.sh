#!/bin/bash

GENOMES=( $(ls | egrep ".seq$" | sed 's/\.seq$//') )

#
# ==============================================================================
#
function RUN_GECO3 {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.co;
  FILED=$IN_FILE.de;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_GECO2 {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.co;
  FILED=$IN_FILE.de;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  }
#
# ==============================================================================
#
function RUN_JARVIS2_BIN {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.jc;
  FILED=$IN_FILE.jc.jd;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_JARVIS1 {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.jc;
  FILED=$IN_FILE.jc.jd;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_JARVIS2_SH {
  #
  IN_FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./../bin/JARVIS2.sh --level " $C_COMMAND " $6 --input $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$IN_FILE.tar" ]; then
    C_BYTES=`ls -la $IN_FILE.tar | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./../bin/JARVIS2.sh $D_COMMAND $IN_FILE.tar \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $IN_FILE.tar.out | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
}
#
# ==============================================================================
#
function RUN_NAF {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  IN_FILE=${GENOME}.fa;
  FILEC=naf_out/${GENOME}.naf;
  FILED=naf_out/$IN_FILE;
  #
  mkdir -p naf_out
  #
  # compress: ennaf file.fa -o file.naf
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE -o $FILEC 2> naf_tmp_report.txt;
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  # decompress: unnaf file.naf -o file.fa
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC -o $FILED 2> naf_tmp_report.txt 
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_LZMA {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  cp $FILE $FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE.orig 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILE.orig.lzma" ]; then
    C_BYTES=`ls -la $FILE.orig.lzma | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.orig.lzma 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $FILE | tr -d '\n') <(tail -n +2 $FILE.orig | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
}
#
# ==============================================================================
#
function RUN_BZIP2 {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.orig.bz2;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  cp $IN_FILE $IN_FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE.orig 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $IN_FILE.orig | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_BSC {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.bsc;
  FILED=$IN_FILE.out;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ${bin_path}bsc-m03 e $IN_FILE $FILEC $C_COMMAND 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND d $FILEC $FILED 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILED $IN_FILE > cmp.txt;
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $IN_FILE.orig | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
  }
#
# ==============================================================================
#
function RUN_MFC  {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  echo ">x" > $FILE.orig;
  cat $FILE >> $FILE.orig;
  printf "\n" >> $FILE.orig;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -o $FILE.mfc $FILE.orig 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILE.mfc" ]; then
    C_BYTES=`ls -la $FILE.mfc | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -o $FILE.d $FILE.mfc 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $FILE.orig | tr -d '\n') <(tail -n +2 $FILE.d | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f $FILE.orig $FILE.mfc $FILE.d c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
# 
function RUN_DMcompress() {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  echo ">x" > $FILE.orig;
  cat $FILE >> $FILE.orig;
  printf "\n" >> $FILE.orig;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE.orig 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILE.orig.c" ]; then
    C_BYTES=`ls -la $FILE.orig.c | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.orig.c 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $FILE.orig | tr -d '\n') <(tail -n +2 $FILE.orig.c.d | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
#
function RUN_MBGC() {
  #
  GENOME="$1"; # .seq file with relative path
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=${GENOME}.fa;
  FILEC=$GENOME.mbgc;
  FILED=mbgc_out/$IN_FILE;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  mkdir -p mbgc_out
  #
  # mbgc [-c compressionMode] [-t noOfThreads] -i <inputFastaFile> <archiveFile>
  # exemplo: ./mbgc -i input.fasta comp.mbgc
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE $FILEC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  # mbgc -d [-t noOfThreads] [-f pattern] [-l dnaLineLength] <archiveFile> [<outputPath>]
  # exemplo: ./mbgc -l 80 -d comp.mbgc out
  { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC mbgc_out; } 2>> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f .temp cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
# 
function RUN_AGC() {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=${GENOME}.fa;
  FILEC=$GENOME.agc;
  FILED=${GENOME}_agc_out.fa;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  # agc create .${bin_path}genomes/zika.seq.agc -o .${bin_path}genomes/zika.seq.agc.c
  { /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE -o $FILEC; } 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  # alternative #1: ./agc getcol in.agc > out.fa  
  { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC > $FILED; } 1> c_stdout.txt 2> d_tmp_report.txt;
  # alternative #2: ./agc getcol -o out_path/ in.agc
  # mkdir -p agc_out;
  # FILED=agc_out/$IN_FILE;
  # { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -o agc_out $FILEC; } 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
function RUN_PAQ8() {
  #
  # Data compression:
  # time ${bin_path}paq8l -8 HS.seq 1> report_c_stdout.txt 2> report_c_stderr.txt

  # # Data decompression:
  # time ${bin_path}paq8l -d HS.seq.paq8l Hs.seq.de 1> report_d_stdout.txt 2> report_d_stderr.txt;
  # #
  # # Lossless validation:
  # cmp HS.seq.de HS.seq > cmp.txt;
  mkdir -p paq8l_out
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=$GENOME.seq;
  FILEC=$IN_FILE.paq8l;
  FILED=paq8l_out/$IN_FILE;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  # ${bin_path}paq8l -8 HS.seq
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  # ${bin_path}paq8l -d HS.seq.paq8l Hs.seq.de
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILEC paq8l_out \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
}
#
# ==============================================================================
#
function RUN_CMIX() {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=${GENOME}.fa;
  FILEC=$GENOME.cmix;
  FILED=${GENOME}_cmix_out.fa;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE $FILEC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -r $IN_FILE -t $FILEC -o $FILED 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
function RUN_MEMRGC() {
  #
  GENOME="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  IN_FILE=${GENOME}.fa;
  FILEC=$GENOME.memrgc;
  FILED=${GENOME}_memrgc_out.fa;
  #
  BYTES=`ls -la $IN_FILE | awk '{ print $5 }'`;  
  #
  # RUN_MEMRGC "$IN_FILE" "${bin_path}memrgc e -m file " "${bin_path}memrgc d -m file " "MEMRGC" "49"
  #
  # ${bin_path}memrgc e -m file -r testData/ref.fa -t testData/tar.fa -o $FILEC
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -r $IN_FILE -t $IN_FILE -o $FILEC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  if [ -e "$FILEC" ]; then
    C_BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
    BPS=$(echo "scale=3; $BYTES / $C_BYTES" | bc);
  else 
    C_BYTES=-1;
    BPS=-1;
  fi
  #
  # ${bin_path}memrgc d -m file -t $FILEC -o testData/dec.fa
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -r $IN_FILE -t $FILEC -o $FILED 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  # compare input file to decompressed file; they should have the same sequence
  diff <(tail -n +2 $IN_FILE | tr -d '\n') <(tail -n +2 $FILED | tr -d '\n') > cmp.txt;
  #
  C_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  C_MEME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $2 }')`;
  D_TIME=`printf "%0.3f\n" $(cat c_time_mem.txt | awk '{ print $1 }')`;
  D_MEME=`printf "%0.3f\n" $(cat d_time_mem.txt | awk '{ print $2 }')`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_BYTES\t$BPS\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n" | tee -a ../bench-results.txt;
  #
  rm -f ${FILEC}tmp cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
rm -fr ../bench-results.*;
bin_path="../bin/"
run=0;
#
for i in "${!GENOMES[@]}"; do
    #
    printf "DS$i - ${GENOMES[i]}\nPROGRAM\tBYTES\tC_BYTES\tBPS\tC_TIME (m)\tC_MEM (GB)\tD_TIME (m)\tD_MEM (GB)\tDIFF\tRUN\n" | tee -a ../bench-results.txt;
    #
    # ==============================================================================
    #
    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
      RUN_GECO2 "${GENOMES[i]}" "GeCo2 -v -tm 13:1:0:0:0.7/0:0:0" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      #
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -tm 13:1:0:0:0.7/0:0:0" "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:40:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      #
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v -l 3 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v -l 5 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v -l 10 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v -l 15 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 " "JARVIS -d " "JARVIS1" "$((run+=1))"
      #
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ " "unnaf " "NAF-1" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ --level 5 " "unnaf " "NAF-5" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ --level 10 " "unnaf " "NAF-10" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ --level 15 " "unnaf " "NAF-15" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ --level 20 " "unnaf " "NAF-20" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "ennaf --fasta --temp-dir naf_out/ --level 22 " "unnaf " "NAF-22" "$((run+=1))"
      #
      RUN_MBGC "${GENOMES[i]}" "mbgc -c 0 -i " "mbgc -d " "MBGC-0" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "mbgc -i " "mbgc -d " "MBGC-1" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "mbgc -c 2 -i " "mbgc -d " "MBGC-2" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "mbgc -c 3 -i " "mbgc -d " "MBGC-3" "$((run+=1))"
      #
      RUN_AGC "${GENOMES[i]}" "agc create " "agc getcol " "AGC" "$((run+=1))"
      #
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -1 " "paq8l -d " "PAQ8L-1" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -2 " "paq8l -d " "PAQ8L-2" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -3 " "paq8l -d " "PAQ8L-3" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -4 " "paq8l -d " "PAQ8L-4" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -5 " "paq8l -d " "PAQ8L-5" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -6 " "paq8l -d " "PAQ8L-6" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -7 " "paq8l -d " "PAQ8L-7" "$((run+=1))"
      RUN_PAQ8 "${GENOMES[i]}" "paq8l -8 " "paq8l -d " "PAQ8L-8" "$((run+=1))"
    else
      RUN_GECO2 "${GENOMES[i]}" "${bin_path}GeCo2 -v -tm 13:1:0:0:0.7/0:0:0" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "${GENOMES[i]}" "${bin_path}GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      #
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -tm 13:1:0:0:0.7/0:0:0" "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:40:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "${GENOMES[i]}" "${bin_path}GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      #
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v -l 3 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v -l 5 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v -l 10 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v -l 15 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "${GENOMES[i]}" "${bin_path}JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 " "${bin_path}JARVIS -d " "JARVIS1" "$((run+=1))"
      #
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ " "${bin_path}unnaf " "NAF-1" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 5 " "${bin_path}unnaf " "NAF-5" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 10 " "${bin_path}unnaf " "NAF-10" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 15 " "${bin_path}unnaf " "NAF-15" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 20 " "${bin_path}unnaf " "NAF-20" "$((run+=1))"
      RUN_NAF "${GENOMES[i]}" "${bin_path}ennaf --fasta --temp-dir naf_out/ --level 22 " "${bin_path}unnaf " "NAF-22" "$((run+=1))"
      #
      RUN_MBGC "${GENOMES[i]}" "${bin_path}mbgc -c 0 -i " "${bin_path}mbgc -d " "MBGC-0" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "${bin_path}mbgc -i " "${bin_path}mbgc -d " "MBGC-1" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "${bin_path}mbgc -c 2 -i " "${bin_path}mbgc -d " "MBGC-2" "$((run+=1))"
      RUN_MBGC "${GENOMES[i]}" "${bin_path}mbgc -c 3 -i " "${bin_path}mbgc -d " "MBGC-3" "$((run+=1))"
      #
      RUN_AGC "${GENOMES[i]}" "${bin_path}agc create " "${bin_path}agc getcol " "AGC" "$((run+=1))"
      #
      RUN_PAQ8 "${GENOMES[i]}" "${bin_path}paq8l -1 " "${bin_path}paq8l -d " "PAQ8L-1" "$((run+=1))" # other paq8l tests are very slow
    fi
    #
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 1" "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 2 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 3 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 4 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 5 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 10 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 15 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 20 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -l 24 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -lr 0.005 -hs 48 -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "${GENOMES[i]}" "${bin_path}JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    #
    cp ../bin/* . 
    RUN_JARVIS2_SH "${GENOMES[i]}" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "$((run+=1))" " --block 270MB --threads 3 --dna "
    RUN_JARVIS2_SH "${GENOMES[i]}" " -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "$((run+=1))" " --block 270MB --threads 3 --dna "
    RUN_JARVIS2_SH "${GENOMES[i]}" " -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 6 --dna --input " "JARVIS2-sh" "$((run+=1))" " --block 150MB --threads 6 --dna "
    RUN_JARVIS2_SH "${GENOMES[i]}" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 8 --dna --input " "JARVIS2-sh" "$((run+=1))" " --block 100MB --threads 8 --dna "
    # remove all stuff copied from bin (they were added to current directory to run JARVIS2.sh properly)
    find . -maxdepth 1 ! -name "*.*" -type f -delete && rm -fr JARVIS2.sh v0.2.1.tar.gz
    #
    RUN_LZMA "${GENOMES[i]}" "lzma -9 -f -k " "lzma -f -k -d " "LZMA-9" "$((run+=1))"
    RUN_BZIP2 "${GENOMES[i]}" "bzip2 -9 -f -k " "bzip2 -f -k -d " "BZIP2-9" "$((run+=1))"
    #
    RUN_BSC "${GENOMES[i]}" " -b800000000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    RUN_BSC "${GENOMES[i]}" " -b400000000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    RUN_BSC "${GENOMES[i]}" " -b4096000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    #
    RUN_MFC "${GENOMES[i]}" "${bin_path}MFCompressC -v -1 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    RUN_MFC "${GENOMES[i]}" "${bin_path}MFCompressC -v -2 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    RUN_MFC "${GENOMES[i]}" "${bin_path}MFCompressC -v -3 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    #
    RUN_DMcompress "${GENOMES[i]}" "${bin_path}DMcompressC " "${bin_path}DMcompressD " "DMcompress" "$((run+=1))"
    #
    RUN_MEMRGC "${GENOMES[i]}" "${bin_path}memrgc e -m file " "${bin_path}memrgc d -m file " "MEMRGC" "$((run+=1))"
    #
    RUN_CMIX "${GENOMES[i]}" "${bin_path}cmix -n " "${bin_path}cmix -d " "CMIX" "$((run+=1))"
    #
    # ==============================================================================
    #
    printf "\n\n"
    #
done
# 
# save bench to latex and markdown files
./SaveBench.sh
