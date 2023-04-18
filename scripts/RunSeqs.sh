#!/bin/bash
#
# ==============================================================================
#
function RUN_GECO3 {
  #
  IN_FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  }
#
# ==============================================================================
#
function RUN_GECO2 {
  #
  IN_FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  }
#
# ==============================================================================
#
function RUN_JARVIS2_BIN {
  #
  IN_FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  }
#
# ==============================================================================
#
function RUN_JARVIS1 {
  #
  IN_FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  }
#
# ==============================================================================
#
function RUN_JARVIS2_SH {
  #
  IN_FILE="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./JARVIS2.sh --level " $C_COMMAND " $6 --input $IN_FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $IN_FILE.tar | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./JARVIS2.sh $D_COMMAND $IN_FILE.tar \
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  }
#
# ==============================================================================
#
function RUN_NAF {
  #
  mkdir -p tmp/
  TMP="tmp/tmp-x.fa";
  rm -f $TMP.naf $TMP.unnaf
  echo ">x" > $TMP;
  cat $1 >> $TMP;
  printf "\n" >> $TMP;
  #
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $TMP 2> naf_tmp_report.txt;
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $TMP.naf | awk '{ print $5 }'`;
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -o $TMP.unnaf $TMP.naf 2> naf_tmp_report.txt 
  cat naf_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $TMP.unnaf $TMP > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f $TMP $TMP.unnaf
  #
  }
#
# ==============================================================================
#
function RUN_LZMA {
  #
  FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f $FILE.orig $FILE.orig.lzma c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_BZIP2 {
  #
  FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f $FILE.orig $FILE.orig.bz2 c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt
  #
  }
#
# ==============================================================================
#
function RUN_BSC {
  #
  FILE="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  cp $FILE $FILE.orig
  #
  /bin/time -f "TIME\t%e\tMEM\t%M" ./bsc-m03 e $FILE.orig $FILE.bsc $C_COMMAND 1> c_stdout.txt 2> c_tmp_report.txt;
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f $FILE.orig $FILE.bsc $FILE.out c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
  }
#
# ==============================================================================
#
function RUN_MFC {
  #
  FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f $FILE.orig $FILE.mfc $FILE.d c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
  }
#
# ==============================================================================
# 
function RUN_DMcompress() {
  #
  FILE="$1";
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
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
#
function RUN_MBGC() {
  #
  FILE="$1"; # .seq file with relative path
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  mbgcFileOrig=$(echo $FILE | sed 's/seq/fa/g').clean;
  mbgcFileC=$(echo $FILE | sed 's/seq/mbgc/g');
  mbgcFileD=out/$(echo $FILE | sed 's/seq/fa/g').clean;
  #
  # mbgc [-c compressionMode] [-t noOfThreads] -i <inputFastaFile> <archiveFile>
  # exemplo: ./mbgc -i GCA_lm_concat.fna archive2.mbgc
  /bin/time -f "TIME\t%e\tMEM\t%M" ./mbgc -i $mbgcFileOrig $mbgcFileC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $mbgcFileC | awk '{ print $5 }'`;
  #
  # mbgc -d [-t noOfThreads] [-f pattern] [-l dnaLineLength] <archiveFile> [<outputPath>]
  # exemplo: ./mbgc -d archive2.mbgc out
  { /bin/time -f "TIME\t%e\tMEM\t%M" ./mbgc -d $mbgcFileC out; } 2>>d_tmp_report.txt
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $mbgcFileOrig $mbgcFileD > cmp.txt;
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f .temp cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt
  #
}
#
# ==============================================================================
# 
function RUN_AGC() {
  #
  FILE="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  agcFileOrig=$(echo $FILE | sed 's/seq/fa/g').clean;
  agcFileC=$(echo $FILE | sed 's/seq/agc/g');
  agcFileD=$(echo $FILE | sed 's/seq/agc/g').out;
  #
  # agc create ../genomes/zika.seq.agc -o ../genomes/zika.seq.agc.c
  { /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $agcFileOrig > $agcFileC; } 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $agcFileC | awk '{ print $5 }'`;
  #
  # agc getcol ../genomes/zika.fa.agc > zika.fa.agc
  { /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $agcFileC > $agcFileD; } 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  cmp $agcFileOrig $agcFileD > cmp.txt; # may differ due to EOLs
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
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
  # time ./paq8l -8 HS.seq 1> report_c_stdout.txt 2> report_c_stderr.txt

  # # Data decompression:
  # time ./paq8l -d HS.seq.paq8l Hs.seq.de 1> report_d_stdout.txt 2> report_d_stderr.txt;
  # #
  # # Lossless validation:
  # cmp HS.seq.de HS.seq > cmp.txt;
  #
  #
  FILE="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  # ./paq8l -8 HS.seq
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND $FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  BYTES=`ls -la $FILE.paq8l | awk '{ print $5 }'`;
  # ./paq8l -d HS.seq.paq8l Hs.seq.de
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND $FILE.paq8l paq8l_out ./paq8l_out/$FILE \
  |& grep "TIME" \
  |& tr '.' ',' \
  |& awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  #
  cmp $FILE ./paq8l_out/$FILE > cmp.txt
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
}
#
# ==============================================================================
#
function RUN_CMIX() {
  printf "";
}
#
# ==============================================================================
#
function RUN_MEMRGC() {
  #
  FILE="$1";
  C_COMMAND="$2";
  D_COMMAND="$3";
  NAME="$4";
  #
  agcFileOrig=$(echo $FILE | sed 's/seq/fa/g').clean;
  agcFileC=$(echo $FILE | sed 's/seq/fa/g').clean.memrgc;
  agcFileD=$(echo $FILE | sed 's/seq/fa/g').clean.memrgc.out;
  #
  # RUN_MEMRGC "$FILE" "./memrgc e -m file -t " "./memrgc d -m file -t " "MEMRGC" "49"
  #
  # ./memrgc e -m file -r testData/ref.fa -t testData/tar.fa -o $agcFileC
  /bin/time -f "TIME\t%e\tMEM\t%M" $C_COMMAND -r $agcFileOrig -t $agcFileOrig -o $agcFileC 1> c_stdout.txt 2> c_tmp_report.txt;
  cat c_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > c_time_mem.txt;
  #
  BYTES=`ls -la $agcFileC | awk '{ print $5 }'`;
  #
  # ./memrgc d -m file -t $agcFileC -o testData/dec.fa
  /bin/time -f "TIME\t%e\tMEM\t%M" $D_COMMAND -r $agcFileOrig -t $agcFileC -o $agcFileD 1> c_stdout.txt 2> d_tmp_report.txt;
  cat d_tmp_report.txt | grep "TIME" | tr '.' ',' | awk '{ printf $2/60"\t"$4/1024/1024"\n" }' > d_time_mem.txt;
  # 
  cmp $agcFileOrig $agcFileD > cmp.txt; # may differ due to EOLs
  #
  C_TIME=`cat c_time_mem.txt | awk '{ print $1}'`;
  C_MEME=`cat c_time_mem.txt | awk '{ print $2}'`;
  D_TIME=`cat d_time_mem.txt | awk '{ print $1}'`;
  D_MEME=`cat d_time_mem.txt | awk '{ print $2}'`;
  VERIFY="0";
  CMP_SIZE=`ls -la cmp.txt | awk '{ print $5}'`
  if [[ "$CMP_SIZE" != "0" ]]; then CMP_SIZE="1"; fi
  #
  printf "$NAME\t$BYTES\t$C_TIME\t$C_MEME\t$D_TIME\t$D_MEME\t$CMP_SIZE\t$5\n";
  #
  rm -f cmp.txt c_tmp_report.txt d_tmp_report.txt c_time_mem.txt d_time_mem.txt c_stdout.txt d_stdout.txt;
  #
}
#
# ==============================================================================
#
# alternativa manual
FILES=(
    # "chm13v2.0.fa.gz" # genoma humano, ~3GB
    # "GRCh38_latest_genomic.fna.gz" # genoma humano, ~3GB

    # "Pseudobrama_simoni.genome.seq" # 886.11MB
    # "Rhodeus_ocellatus.genome.seq" # 860.71MB
    # "CASSAVA.seq" # CASSAVA, 727.09MB
    # "TME204.HiFi_HiC.haplotig2.seq" # 673.62MB
    
    # "MFCexample.seq" # 3.5MB
    # "phyml_tree.seq" # 2.36MB	
    
    # "EscherichiaPhageLambda.seq" # 49.2KB
    "mt_genome_CM029732.seq" # 15.06KB
    "zika.seq" # 11.0KB
    "herpes.seq" # 2.7KB
)

# alternativa automatica
# FILES=( $(ls ../genomes/ | egrep "*.seq$") )

for FILE in "${FILES[@]}"; do
    #
    # ==============================================================================
    #
    printf "$FILE \nPROGRAM\tC_BYTES\tC_TIME (m)\tC_MEM (GB)\tD_TIME (m)\tD_MEM (GB)\tDIFF\tRUN\n";
    #
    # ------------------------------------------------------------------------------
    #
    # RUN_GECO2 "$FILE" "./GeCo2 -v -tm 13:1:0:0:0.7/0:0:0" "./GeDe2 -v " "GeCo2" "1"
    # RUN_GECO2 "$FILE" "./GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 13:500:1:20:0.9/1:20:0.9" "./GeDe2 -v " "GeCo2" "2"
    # RUN_GECO2 "$FILE" "./GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 14:500:1:20:0.9/1:20:0.9" "./GeDe2 -v " "GeCo2" "3"
    # RUN_GECO2 "$FILE" "./GeCo2 -v -tm 3:1:0:0:0.7/0:0:0 -tm 17:1000:1:10:0.9/3:20:0.9" "./GeDe2 -v " "GeCo2" "4"
    # RUN_GECO2 "$FILE" "./GeCo2 -v -tm 12:1:0:0:0.7/0:0:0 -tm 17:1000:1:20:0.9/3:20:0.9" "./GeDe2 -v " "GeCo2" "5"
    # #
    # RUN_GECO3 "$FILE" "./GeCo3 -v -tm 13:1:0:0:0.7/0:0:0" "./GeDe3 -v " "GeCo3" "6"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.005 -hs 160 -tm 1:1:1:0:0.6/0:0:0 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 4:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 8:1:0:0:0.85/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:10:2:0:0.9/0:0:0 -tm 11:10:0:0:0.88/0:0:0 -tm 12:20:1:0:0.88/0:0:0 -tm 14:50:1:1:0.89/1:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:160:0.88/3:15:0.88 " "./GeDe3 -v " "GeCo3" "7"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 12:20:0:0:0.88/0:0:0 -tm 14:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:120:0.88/3:10:0.88 " "./GeDe3 -v " "GeCo3" "8"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 6:1:0:0:0.7/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1000:1:70:0.88/3:10:0.88 " "./GeDe3 -v " "GeCo3" "9"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.005 -hs 90 -tm 1:1:0:0:0.6/0:0:0 -tm 2:1:2:0:0.90/0:0:0 -tm 2:1:1:0:0.8/0:0:0 -tm 3:1:0:0:0.8/0:0:0 -tm 5:1:0:0:0.8/0:0:0 -tm 7:1:1:0:0.7/0:0:0 -tm 9:1:1:0:0.88/0:0:0 -tm 11:20:0:0:0.88/0:0:0 -tm 13:50:1:1:0.89/0:10:0.89 -tm 17:2000:1:10:0.88/2:50:0.88 -tm 20:1200:1:40:0.88/3:10:0.88 " "./GeDe3 -v " "GeCo3" "10"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.03 -hs 72 -tm 1:1:0:0:0.6/0:0:0 -tm 3:1:0:1:0.70/0:0:0 -tm 8:1:0:1:0.85/0:0:0 -tm 13:20:0:1:0.9/0:1:0.9 -tm 20:1500:1:50:0.9/4:10:0.9 " "./GeDe3 -v " "GeCo3" "11"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -hs 24 -lr 0.02 -tm 12:1:0:0:0.9/0:0:0 -tm 19:1200:1:10:0.8/3:20:0.9 " "./GeDe3 -v " "GeCo3" "12"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -lr 0.02 -tm 3:1:0:0:0.7/0:0:0 -tm 18:1200:1:10:0.9/3:10:0.9 " "./GeDe3 -v " "GeCo3" "13"
    # RUN_GECO3 "$FILE" "./GeCo3 -v -tm 3:1:0:0:0.7/0:0:0 -tm 19:1000:0:20:0.9/0:20:0.9 " "./GeDe3 -v " "GeCo3" "14"
    # #
    # RUN_JARVIS1 "$FILE" "./JARVIS -v " "./JARVIS -v -d " "JARVIS1" "15"  
    # RUN_JARVIS1 "$FILE" "./JARVIS -v -l 3 " "./JARVIS -v -d " "JARVIS1" "16"  
    # RUN_JARVIS1 "$FILE" "./JARVIS -v -l 5 " "./JARVIS -v -d " "JARVIS1" "17"  
    # RUN_JARVIS1 "$FILE" "./JARVIS -v -l 10 " "./JARVIS -v -d " "JARVIS1" "18"  
    # RUN_JARVIS1 "$FILE" "./JARVIS -v -l 15 " "./JARVIS -v -d " "JARVIS1" "19"  
    # RUN_JARVIS1 "$FILE" "./JARVIS -v -rm 2000:12:0.1:0.9:6:0.10:1 -cm 4:1:1:0.7/0:0:0:0 -z 6 " "./JARVIS -d " "JARVIS1" "20"
    # #
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 1" "./JARVIS2 -d" "JARVIS2-bin" "16"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 2 " "./JARVIS2 -d" "JARVIS2-bin" "17"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 3 " "./JARVIS2 -d" "JARVIS2-bin" "18"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 4 " "./JARVIS2 -d" "JARVIS2-bin" "19"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 5 " "./JARVIS2 -d" "JARVIS2-bin" "20"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 10 " "./JARVIS2 -d" "JARVIS2-bin" "21"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 15 " "./JARVIS2 -d" "JARVIS2-bin" "22"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 20 " "./JARVIS2 -d" "JARVIS2-bin" "23"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -l 24 " "./JARVIS2 -d" "JARVIS2-bin" "24"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -rm 50:11:1:0.9:7:0.4:1:0.2:200000 -cm 1:1:0:0.7/0:0:0:0 " "./JARVIS2 -d" "JARVIS2-bin" "25"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -lr 0.005 -hs 48 -rm 2000:14:1:0.9:7:0.4:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "./JARVIS2 -d" "JARVIS2-bin" "26"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -lr 0.005 -hs 92 -rm 2000:15:1:0.9:7:0.3:1:0.2:250000 -cm 1:1:0:0.7/0:0:0:0 -cm 4:1:0:0.85/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 11:1:1:0.85/0:0:0:0 -cm 14:1:1:0.85/1:1:1:0.9 " "./JARVIS2 -d" "JARVIS2-bin" "27"
    # RUN_JARVIS2_BIN "$FILE" "./JARVIS2 -v -lr 0.01 -hs 42 -rm 1000:13:1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " "./JARVIS2 -d" "JARVIS2-bin" "28"
    # #
    # RUN_JARVIS2_SH "$FILE" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "29" " --block 270MB --threads 3 --dna "
    # RUN_JARVIS2_SH "$FILE" " -lr 0.01 -hs 42 -rm 1000:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:10:1:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 3 --dna --input " "JARVIS2-sh" "30" " --block 270MB --threads 3 --dna "
    # RUN_JARVIS2_SH "$FILE" " -lr 0.01 -hs 42 -rm 500:12:0.1:0.9:7:0.4:1:0.2:220000 -cm 1:1:0:0.7/0:0:0:0 -cm 7:1:0:0.7/0:0:0:0 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 6 --dna --input " "JARVIS2-sh" "31" " --block 150MB --threads 6 --dna "
    # RUN_JARVIS2_SH "$FILE" " -lr 0.01 -hs 42 -rm 200:11:1:0.9:7:0.3:1:0.2:220000 -cm 12:1:1:0.85/0:0:0:0 " " --decompress --threads 8 --dna --input " "JARVIS2-sh" "32" " --block 100MB --threads 8 --dna "
    # #
    # RUN_NAF "$FILE" "ennaf --strict --temp-dir tmp/ --dna --level 22 " "unnaf " "NAF-22" "33"
    # RUN_LZMA "$FILE" "lzma -9 -f -k " "lzma -f -k -d " "LZMA-9" "34"
    # RUN_BZIP2 "$FILE" "bzip2 -9 -f -k " "bzip2 -f -k -d " "BZIP2-9" "35"
    # RUN_BSC "$FILE" " -b800000000 " "./bsc-m03 " "BSC-m03" "36"
    # RUN_BSC "$FILE" " -b400000000 " "./bsc-m03 " "BSC-m03" "37"
    # RUN_BSC "$FILE" " -b4096000 " "./bsc-m03 " "BSC-m03" "38"
    # RUN_MFC "$FILE" "./MFCompressC -v -1 -p 1 -t 1 " "./MFCompressD " "MFC-1" "39"
    # RUN_MFC "$FILE" "./MFCompressC -v -2 -p 1 -t 1 " "./MFCompressD " "MFC-2" "40"
    # RUN_MFC "$FILE" "./MFCompressC -v -3 -p 1 -t 1 " "./MFCompressD " "MFC-3" "41"
    # RUN_DMcompress "$FILE" "./DMcompressC " "./DMcompressD " "DMcompress" "42"
    # #
    # mbgc [-c compressionMode] [-t noOfThreads] -i <inputFastaFile> <archiveFile>
    # mbgc -d [-t noOfThreads] [-f pattern] [-l dnaLineLength] <archiveFile> [<outputPath>]
    # RUN_MBGC "$FILE" "./mbgc -c 0 -i " "./mbgc -d " "MBGC" "43"
    # RUN_MBGC "$FILE" "./mbgc -i " "./mbgc -d " "MBGC" "44"
    # RUN_MBGC "$FILE" "./mbgc -c 2 -i " "mbgc -d " "MBGC" "45"
    # RUN_MBGC "$FILE" "./mbgc -c 3 -i " "mbgc -d " "MBGC" "46"
    # #
    # ./agc create ref.fa in1.fa in2.fa > col.agc
    # agc getcol [options] <in.agc> > <out.fa>
    # RUN_AGC "$FILE" "./agc create " "./agc getcol " "AGC" "47"
    # #
    RUN_PAQ8 "$FILE" "./paq8l -8 " "./paq8l -d " "PAQ8L" "48"
    # #
    RUN_MEMRGC "$FILE" "./memrgc e -m file " "./memrgc d -m file " "MEMRGC" "49"
    # #
    # # ==============================================================================
    # #
    printf "\n"
done
