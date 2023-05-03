#!/bin/bash
#
# ==============================================================================
#
function RUN_GECO3 {
  #
  IN_FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.co | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $IN_FILE.co \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $IN_FILE.de $IN_FILE > cmp.txt
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_GECO2 {
  #
  IN_FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.co | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $IN_FILE.co \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $IN_FILE.de $IN_FILE > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  }
#
# ==============================================================================
#
function RUN_JARVIS2_BIN {
  #
  IN_FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.jc | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $IN_FILE.jc \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $IN_FILE.jc.jd $IN_FILE > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_JARVIS1 {
  #
  IN_FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.jc | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $IN_FILE.jc \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $IN_FILE.jc.jd $IN_FILE > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
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
  /bin/time -f "TIME\t%e\tMEM\t%M" ./../bin/JARVIS2.sh --level " $C_COMMAND " $6 --input $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.tar | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./../bin/JARVIS2.sh $D_COMMAND $IN_FILE.tar \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $IN_FILE.tar.out $IN_FILE > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "${IN_FILE%.*}$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  }
#
# ==============================================================================
#
function RUN_NAF {
  #
  FILE="$1"_clean.fa;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  FILEC=naf_out/$FILE.naf;
  FILED=naf_out/$FILE.unnaf;
  #
  mkdir -p naf_out/
  rm -f $FILEC $FILED
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -o $FILE 2> naf_tmp_report.txt;
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILEC | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -o $FILED $FILEC 2> naf_tmp_report.txt 
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILED $FILE > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
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
  cp $FILE $FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE.orig 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILE.orig.lzma | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.orig.lzma 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE $FILE.orig > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_BZIP2 {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  cp $FILE $FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE.orig 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILE.orig.bz2 | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.orig.bz2 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE $FILE.orig > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f $FILE.orig $FILE.orig.bz2 c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_BSC {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  cp $FILE $FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ${bin_path}bsc-m03 e $FILE.orig $FILE.bsc $C_COMMAND 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILE.bsc | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND d $FILE.bsc $FILE.out 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE.out $FILE.orig > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f $FILE.orig $FILE.bsc $FILE.out c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
  }
#
# ==============================================================================
#
function RUN_MFC {
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
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -o $FILE.mfc $FILE.orig 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILE.mfc | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -o $FILE.d $FILE.mfc 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE.orig $FILE.d > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
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
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE.orig 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FILE.orig.c | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.orig.c 1> d_stdout.txt 2> d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE.orig $FILE.orig.c.d > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
#
function RUN_MBGC() {
  #
  mkdir -p mbgc_out
  #
  FILE="$1"_clean.fa; # .seq file with relative path
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  FileC=${FILE%.*}_clean.mbgc;
  FileD=mbgc_out/${FILE%.*}_clean.fa;
  #
  # mbgc [-c compressionMode] [-t noOfThreads] -i <inputFastaFile> <archiveFile>
  # exemplo: mbgc -i GCA_lm_concat.fna archive2.mbgc
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE $FileC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FileC | awk '{ print $5 }'`;
  #
  # mbgc -d [-t noOfThreads] [-f pattern] [-l dnaLineLength] <archiveFile> [<outputPath>]
  # exemplo: mbgc -d archive2.mbgc out
  { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FileC mbgc_out; } 2>>d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE $FileD > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f .temp cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
# 
function RUN_AGC() {
  #
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  FileC=$(echo $FILE | sed 's/seq/agc/g');
  FileD=${FILE%.*}.fa.out;
  #
  # agc create .${bin_path}genomes/zika.seq.agc -o .${bin_path}genomes/zika.seq.agc.c
  { /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE > $FileC; } 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FileC | awk '{ print $5 }'`;
  #
  # agc getcol .${bin_path}genomes/zika.fa.agc > zika.fa.agc
  { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FileC > $FileD; } 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  cmp $FILE $FileD > cmp.txt; # may differ due to EOLs
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
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
  FILE="$1".seq;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  # ${bin_path}paq8l -8 HS.seq
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $FILE.paq8l | awk '{ print $5 }'`;
  # ${bin_path}paq8l -d HS.seq.paq8l Hs.seq.de
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.paq8l paq8l_out paq8l_out/$FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE paq8l_out/$FILE > cmp.txt
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
}
#
# ==============================================================================
#
function RUN_CMIX() {
  #
  FILE="$1"_clean.fa;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  FileC=${FILE%.*}_clean.cmix;
  FileD=${FILE%.*}_clean.cmix.out;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -r $FILE -t $FILE -o $FileC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FileC | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -r $FILE -t $FileC -o $FileD 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  cmp $FILE $FileD > cmp.txt; # may differ due to EOLs
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
function RUN_MEMRGC() {
  #
  FILE="$1"_clean.fa;
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  FileC=${FILE%.*}_clean.memrgc;
  FileD=${FILE%.*}_clean.memrgc.out;
  #
  # RUN_MEMRGC "$FILE" "${bin_path}memrgc e -m file " "${bin_path}memrgc d -m file " "MEMRGC" "49"
  #
  # ${bin_path}memrgc e -m file -r testData/ref.fa -t testData/tar.fa -o $FileC
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -r $FILE -t $FILE -o $FileC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $FileC | awk '{ print $5 }'`;
  #
  # ${bin_path}memrgc d -m file -t $FileC -o testData/dec.fa
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -r $FILE -t $FileC -o $FileD 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  cmp $FILE $FileD > cmp.txt; # may differ due to EOLs
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$GENOME$space$NAME$space$BYTES$space$C_TIME$space$C_MEME$space$D_TIME$space$D_MEME$space$CMP_SIZE$space$5$EOL";
  #
  rm -f ${FileC}tmp cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
# alternativa manual
GENOMES=(
    # "chm13v2.0.fa.gz" # genoma humano, ~3GB
    # "GRCh38_latest_genomic.fna.gz" # genoma humano, ~3GB

    # "Pseudobrama_simoni.genome" # 886.11MB
    # "Rhodeus_ocellatus.genome" # 860.71MB
    # "CASSAVA" # CASSAVA, 727.09MB
    # "TME204.HiFi_HiC.haplotig2" # 673.62MB
    
    # "MFCexample" # 3.5MB
    # "phyml_tree" # 2.36MB	
    
    "EscherichiaPhageLambda" # 49.2KB
    # "mt_genome_CM029732" # 15.06KB
    # "zika" # 11.0KB
    # "herpes" # 2.7KB
)

# alternativa automatica
# FILES=( $(ls .${bin_path}genomes/ | egrep "*.seq$") )

if [[ "$*" == *"--latex"* ||  "$*" == *"-l"* ]]; then
  space="\t&\t"
  EOL=" \\\\\\\\ \n\n"
  headerEOL="\\\\\\\\ \hline \n\n"
else
  space="\t"
  EOL="\n"
  headerEOL="\n\n"
fi

printf "GENOME $space PROGRAM $space CBYTES $space CTIME (m) $space CMEM (GB) $space DTIME (m) $space DMEM (GB) $space DIFF $space RUN $headerEOL";

run=0;
bin_path="../bin/"

for GENOME in "${GENOMES[@]}"; do
    #
    # ==============================================================================
    #
    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
      RUN_GECO2 "$GENOME" "GeCo2 -v -tm 13:1:0:0:0.7/0:0:0" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9" "GeDe2 -v " "GeCo2" "$((run+=1))"
      
      RUN_GECO3 "$GENOME" "GeCo3 -v -tm 13:1:0:0:0.7/0:0:0" "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:40:0.88/3:10:0.88 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 " "GeDe3 -v " "GeCo3" "$((run+=1))"
      #
      RUN_JARVIS1 "$GENOME" "JARVIS -v " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "JARVIS -v -l 3 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "JARVIS -v -l 5 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "JARVIS -v -l 10 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "JARVIS -v -l 15 " "JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 " "JARVIS -d " "JARVIS1" "$((run+=1))"
      #
      RUN_NAF "$GENOME" "ennaf --strict --temp-dir tmp/ --dna --level 22 " "unnaf " "NAF-22" "$((run+=1))"
      #
      RUN_MBGC "$GENOME" "mbgc -c 0 -i " "mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "mbgc -i " "mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "mbgc -c 2 -i " "mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "mbgc -c 3 -i " "mbgc -d " "MBGC" "$((run+=1))"
      #
      RUN_AGC "$GENOME" "agc create " "agc getcol " "AGC" "$((run+=1))"
      #
      RUN_PAQ8 "$GENOME" "paq8l -8 " "paq8l -d " "PAQ8L" "$((run+=1))"
    else
      RUN_GECO2 "$GENOME" "${bin_path}GeCo2 -v -tm 13:1:0:0:0.7/0:0:0" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "${bin_path}GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      RUN_GECO2 "$GENOME" "${bin_path}GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9" "${bin_path}GeDe2 -v " "GeCo2" "$((run+=1))"
      #
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -tm 13:1:0:0:0.7/0:0:0" "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:40:0.88/3:10:0.88 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      RUN_GECO3 "$GENOME" "${bin_path}GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 " "${bin_path}GeDe3 -v " "GeCo3" "$((run+=1))"
      #
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v -l 3 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v -l 5 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v -l 10 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v -l 15 " "${bin_path}JARVIS -v -d " "JARVIS1" "$((run+=1))"
      RUN_JARVIS1 "$GENOME" "${bin_path}JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 " "${bin_path}JARVIS -d " "JARVIS1" "$((run+=1))"
      #
      RUN_NAF "$GENOME" "${bin_path}ennaf --strict --temp-dir tmp/ --dna --level 22 " "${bin_path}unnaf " "NAF-22" "$((run+=1))"
      #
      RUN_MBGC "$GENOME" "${bin_path}mbgc -c 0 -i " "${bin_path}mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "${bin_path}mbgc -i " "${bin_path}mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "${bin_path}mbgc -c 2 -i " "${bin_path}mbgc -d " "MBGC" "$((run+=1))"
      RUN_MBGC "$GENOME" "${bin_path}mbgc -c 3 -i " "${bin_path}mbgc -d " "MBGC" "$((run+=1))"
      #
      RUN_AGC "$GENOME" "${bin_path}agc create " "${bin_path}agc getcol " "AGC" "$((run+=1))"
      #
      RUN_PAQ8 "$GENOME" "${bin_path}paq8l -8 " "${bin_path}paq8l -d " "PAQ8L" "$((run+=1))"
    fi
    #
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 1" "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 2 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 3 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 4 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 5 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 10 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 15 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 20 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -l 24 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -lr 0.005 -hs 48 -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    RUN_JARVIS2_BIN "$GENOME" "${bin_path}JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "${bin_path}JARVIS2 -d" "JARVIS2-bin" "$((run+=1))"
    #
    cp ../bin/* . 
    #
    RUN_JARVIS2_SH "$GENOME" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "20" " --block 270MB --threads 3 --dna "
    RUN_JARVIS2_SH "$GENOME" " -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "21" " --block 270MB --threads 3 --dna "
    RUN_JARVIS2_SH "$GENOME" " -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 6 --dna --input " "JARVIS2-sh" "22" " --block 150MB --threads 6 --dna "
    RUN_JARVIS2_SH "$GENOME" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 8 --dna --input " "JARVIS2-sh" "23" " --block 100MB --threads 8 --dna "
    #
    # remove all stuff copied from bin (they were added to current directory to run JARVIS2.sh properly)
    find . -maxdepth 1 ! -name "*.*" -type f -delete && rm -fr JARVIS2.sh v0.2.1.tar.gz
    #
    RUN_LZMA "$GENOME" "lzma -9 -f -k " "lzma -f -k -d " "LZMA-9" "$((run+=1))"
    RUN_BZIP2 "$GENOME" "bzip2 -9 -f -k " "bzip2 -f -k -d " "BZIP2-9" "$((run+=1))"
    #
    RUN_BSC "$GENOME" " -b800000000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    RUN_BSC "$GENOME" " -b400000000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    RUN_BSC "$GENOME" " -b4096000 " "${bin_path}bsc-m03 " "BSC-m03" "$((run+=1))"
    #
    RUN_MFC "$GENOME" "${bin_path}MFCompressC -v -1 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    RUN_MFC "$GENOME" "${bin_path}MFCompressC -v -2 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    RUN_MFC "$GENOME" "${bin_path}MFCompressC -v -3 -p 1 -t 1 " "${bin_path}MFCompressD " "MFC" "$((run+=1))"
    #
    RUN_DMcompress "$GENOME" "${bin_path}DMcompressC " "${bin_path}DMcompressD " "DMcompress" "$((run+=1))"
    #
    RUN_MEMRGC "$GENOME" "${bin_path}memrgc e -m file " "${bin_path}memrgc d -m file " "MEMRGC" "49"
    #
    RUN_CMIX "$GENOME" "${bin_path}cmix -c " "${bin_path}cmix -d " "CMIX" "$((run+=1))"
    #
    # ==============================================================================
    #
done
