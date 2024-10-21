#!/bin/bash
#
configJson="../config.json"
ds_sizesBase2="$(grep 'DS_sizesBase2' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
ds_sizesBase10="$(grep 'DS_sizesBase10' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
#
# ==============================================================================
#
function CHECK_INPUT () {
  FILE=$1
  if [ -f "$FILE" ]; then
    echo "Input filename: $FILE"
  else
    echo -e "\e[31mERROR: input file not found ($FILE)!\e[0m";
    exit;
  fi
}
#
function SPLIT_FILE_BY_COMPRESSOR() {
  # recreate grp folder
  rm -fr $plotsSubFolder;
  mkdir -p $plotsSubFolder;

  CHECK_INPUT "$tsvFile";
  # create names.txt inside each ds folder; it contains all compressor names
  cat $tsvFile | awk '{ print $1} ' | sort -V | uniq | grep -vE "DS\*|PROGRAM" > "$compressor_names";
  CHECK_INPUT "$compressor_names";

  # splits ds into subdatasets by compressor and store them in folder
  c_i=1;
  plotnames="";
  plotnames_log="";
  mapfile -t compressors < "$compressor_names";
  for compressor in "${compressors[@]}"; do
    if [[ $compressor != PROGRAM && $compressor != DS* ]]; then
      compressor_tsv="$compressor_tsv_prefix$c_i.tsv";
      grep $compressor $tsvFile > "$compressor_tsv";
      
      tmp="'$compressor_tsv' u 5:6 w points ls $c_i title '$compressor', ";
      plotnames="$plotnames $tmp";
      
      tmp_log="'$compressor_tsv' u 5:(pseudo_log(6)) w points ls $c_i title '$compressor', ";
      plotnames_log="$plotnames_log $tmp_log";
      
      ((++c_i));
    fi
  done

  echo -e "${plotnames//, /\\n}";
  echo -e "${plotnames_log//, /\\n}";
}
#
function GET_PLOT_BOUNDS() {
    # row structure: Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    Rscript -e 'summary(as.numeric(readLines("stdin")))' < <(awk '{if ($5 ~ /^[0-9.]+$/) print $5}' $tsvFile) > tempX.txt
    bps_Q1=$(awk 'NR==2{print $2}' "tempX.txt");
    bps_Q3=$(awk 'NR==2{print $5}' "tempX.txt");

    # row structure: Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    Rscript -e 'summary(as.numeric(readLines("stdin")))' < <(awk '{if ($6 ~ /^[0-9.]+$/) print $6}' $tsvFile) > tempY.txt
    timeS_Q1=$(awk 'NR==2{print $2}' "tempY.txt");
    timeS_Q3=$(awk 'NR==2{print $5}' "tempY.txt");

    # IQR (Inter Quartile Range) = Q3 - Q1
    bps_IQR=$(echo "$bps_Q3-$bps_Q1" | bc);
    timeS_IQR=$(echo "$timeS_Q3-$timeS_Q1" | bc);

    # lower bound = Q1 – 1.5*IQR
    bps_lowerBound=$(echo "$bps_Q1-1.5*$bps_IQR" | bc);
    timeS_lowerBound=$(echo "$timeS_Q1-1.5*$timeS_IQR" | bc);

    # upper bound = Q3 + 1.5*IQR
    bps_upperBound=$(echo "$bps_Q3+1.5*$bps_IQR" | bc);
    timeS_upperBound=$(echo "$timeS_Q3+1.5*$timeS_IQR" | bc);

    if (( $(echo "$bps_lowerBound < 0" | bc -l) )); then
      bps_lowerBound=-0.01;
    fi

    if (( $(echo "$bps_upperBound > 2.05" | bc -l) )); then
      bps_upperBound=2.05;
    fi

    if (( $(echo "$timeS_lowerBound < 0" | bc -l) )); then
      timeS_lowerBound=-0.01;
    fi

    if (( $(echo "$bps_IQR < 1" | bc -l) )); then
      bps_lowerBound="$bps_Q1";
      bps_upperBound="$bps_Q3";
    fi

    if (( $(echo "$timeS_IQR < 1" | bc -l) )); then
      timeS_lowerBound="$timeS_Q1";
      timeS_upperBound="$timeS_Q3";
    fi

    cat tempX.txt;
    printf "bps Q1: $bps_Q1 \n";
    printf "bps Q3: $bps_Q3 \n";
    printf "bps IQR: $bps_IQR \n";
    printf "bps lower bound: $bps_lowerBound \n";
    printf "bps upper bound: $bps_upperBound \n";

    cat tempY.txt;
    printf "bytesCF Q1: $timeS_Q1 \n";
    printf "bytesCF Q3: $timeS_Q3 \n";
    printf "bytesCF IQR: $timeS_IQR \n";
    printf "bytesCF lower bound: $timeS_lowerBound \n";
    printf "bytesCF upper bound: $timeS_upperBound \n\n";

    # rm -fr tempX.txt tempY.txt;
}
#
function PLOT() {
  gnuplot -d << EOF
    reset
    set title noenhanced "${plot_title}"
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$plot_file"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set xrange [$bps_upperBound:$bps_lowerBound]
    set yrange [0.000:20]
    set xtics auto
    set ytics auto
    set key top right
    set style line 1 lc rgb '#990099'  pt 1 ps 0.6  # circle
    set style line 2 lc rgb '#004C99'  pt 2 ps 0.6  # circle
    set style line 3 lc rgb '#CCCC00'  pt 3 ps 0.6  # circle
    #set style line 4 lc rgb '#CC0000' lt 2 dashtype '---' lw 4 pt 5 ps 0.4 # --- red
    set style line 4 lc rgb 'red'  pt 7 ps 0.6  # circle 
    set style line 5 lc rgb '#009900'  pt 5 ps 0.6  # circle
    set style line 6 lc rgb '#990000'  pt 6 ps 0.6  # circle
    set style line 7 lc rgb '#009999'  pt 4 ps 0.6  # circle
    set style line 8 lc rgb '#99004C'  pt 8 ps 0.6  # circle
    set style line 9 lc rgb '#CC6600'  pt 9 ps 0.6  # circle
    set style line 10 lc rgb '#322152' pt 10 ps 0.6  # circle    
    set style line 11 lc rgb '#425152' pt 11 ps 0.6  # circle  
    set style line 12 lc rgb '#00CCCC' pt 11 ps 0.6  # circle  
    set grid
    set ylabel "Compression time (s)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
function PLOT_LOG() {
  gnuplot << EOF
    reset

    # define a function to adjust zero or near-zero values
    pseudo_log(x) = (x <= 0) ? -10 : log10(x)

    set title noenhanced "$plot_title_log"
    set logscale xy 2
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$plot_file_log"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set xrange [$bps_upperBound:$bps_lowerBound]
    set yrange [0.000:20]
    set xtics auto
    set ytics auto 
    set key top right
    set style line 1 lc rgb '#990099'  pt 1 ps 0.6  # circle
    set style line 2 lc rgb '#004C99'  pt 2 ps 0.6  # circle
    set style line 3 lc rgb '#CCCC00'  pt 3 ps 0.6  # circle
    #set style line 4 lc rgb '#CC0000' lt 2 dashtype '---' lw 4 pt 5 ps 0.4 # --- red
    set style line 4 lc rgb 'red'  pt 7 ps 0.6  # circle 
    set style line 5 lc rgb '#009900'  pt 5 ps 0.6  # circle
    set style line 6 lc rgb '#990000'  pt 6 ps 0.6  # circle
    set style line 7 lc rgb '#009999'  pt 4 ps 0.6  # circle
    set style line 8 lc rgb '#99004C'  pt 8 ps 0.6  # circle
    set style line 9 lc rgb '#CC6600'  pt 9 ps 0.6  # circle
    set style line 10 lc rgb '#322152' pt 10 ps 0.6  # circle    
    set style line 11 lc rgb '#425152' pt 11 ps 0.6  # circle    
    set grid
    set ylabel "Compression time (s)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames_log
EOF
}
#
# ==================================================================================================
#
resultsPath="../results";
plotsPath="../plots"
groups=( $(ls "$resultsPath" | grep "DS.*\.txt" | sed -n 's/.*-grp\([0-9]\+\)\.txt/grp\1/p' | sort | uniq -c | awk '{print $2}') )
#
# === MAIN: PLOT EACH TSV FILE ===========================================================================
#
tsvFiles=( $(find "$resultsPath" -maxdepth 1 -type f -name "*.tsv" | sort -V) );
for tsvFile in ${tsvFiles[@]}; do
  if [[ $tsvFile == *DS* ]]; then 
    header=$(head -n 1 "$tsvFile")
    IFS=' - ' read -r dsx sequence size <<< "$header" # split the header into variables
    dsxOrGrp="$dsx"
  else
    dsxOrGrp=$(head -n 1 "$tsvFile")
    sequence=$dsxOrGrp
  fi
  #
  # str_time="m";
  # if [ "$size" = "xs" ] || [ "$size" = "s" ]; then # smaller files => faster tests => time measured in seconds
  #   str_time="s";
  # fi
  #
  plotsSubFolder="$plotsPath/plots-${dsxOrGrp}";
  mkdir -p $plotsSubFolder
  compressor_names="$plotsSubFolder/compressors.txt";
  compressor_tsv_prefix="$plotsSubFolder/bench-results-$dsxOrGrp-c";
  #
  plot_file="$plotsSubFolder/bench-plot.pdf";
  plot_file_log="$plotsSubFolder/bench-plot-$dsxOrGrp-log.pdf";
  #
  plot_title="Compression efficiency of $sequence";
  plot_title_log="Compression efficiency of $sequence (log scale)";
  #
  SPLIT_FILE_BY_COMPRESSOR;
  GET_PLOT_BOUNDS;
  PLOT;
  PLOT_LOG;
done
