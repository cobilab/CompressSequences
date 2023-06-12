#!/bin/bash
#
resultsPath="../results";
#
sizes=("xs" "s" "m" "l" "xl");
#
csv_dsToSize="dsToSize.csv";
declare -A dsToSize;
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
function LOAD_CSV_DSTOSIZE() {
  while IFS=, read -r ds bytes size; do
    # Skip the header line
    if [[ "$ds" != "ds" ]]; then
      dsToSize[$ds]=$size;
    fi
  done < $csv_dsToSize;
}
#
function GET_STATS() {
    str_time="m";
    if [ "$size" = "xs" ] || [ "$size" = "s" ]; then # smaller files => faster tests => time measured in seconds
      str_time="s";
    fi

    # row structure: Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    Rscript -e 'summary(as.numeric(readLines("stdin")))' < <(awk '{if ($4 ~ /^[0-9.]+$/) print $4}' $clean_grp) > tempX.txt
    bps_Q1=$(awk 'NR==2{print $2}' "tempX.txt");
    bps_Q3=$(awk 'NR==2{print $5}' "tempX.txt");

    # row structure: Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    Rscript -e 'summary(as.numeric(readLines("stdin")))' < <(awk '{if ($5 ~ /^[0-9.]+$/) print $5}' $clean_grp) > tempY.txt
    bytesCF_Q1=$(awk 'NR==2{print $2}' "tempY.txt");
    bytesCF_Q3=$(awk 'NR==2{print $5}' "tempY.txt");

    # IQR (Inter Quartile Range) = Q3 - Q1
    bps_IQR=$(echo "$bps_Q3-$bps_Q1" | bc);
    bytesCF_IQR=$(echo "$bytesCF_Q3-$bytesCF_Q1" | bc);

    # lower bound = Q1 – 1.5*IQR
    bps_lowerBound=$(echo "$bps_Q1-1.5*$bps_IQR" | bc);
    bytesCF_lowerBound=$(echo "$bytesCF_Q1-1.5*$bytesCF_IQR" | bc);

    # upper bound = Q3 + 1.5*IQR
    bps_upperBound=$(echo "$bps_Q3+1.5*$bps_IQR" | bc);
    bytesCF_upperBound=$(echo "$bytesCF_Q3+1.5*$bytesCF_IQR" | bc);

    cat tempX.txt;
    # printf "bps IQR: $bps_IQR";
    printf "bps lower bound: $bps_lowerBound \n";
    printf "bps upper bound: $bps_upperBound \n";

    cat tempY.txt;
    # printf "bytesCF IQR: $bytesCF_IQR";
    printf "bytesCF lower bound: $bytesCF_lowerBound \n";
    printf "bytesCF upper bound: $bytesCF_upperBound \n\n";

    # rm -fr tempX.txt tempY.txt;
}
#
# === FUNCTIONS TO PLOT EACH DS ===========================================================================
#
function SPLIT_BENCH_RESULTS_BY_DS() {
  # read the input file
  input_file="$resultsPath/bench-results.csv"
  file_prefix="$resultsPath/bench-results-"

  # remove datasets before recreating them
  rm -fr ${file_prefix}DS*.csv

  while IFS= read -r line; do
    # check if the line contains a dataset name
    if [[ $line == DS* ]]; then
      # create a new output file for the dataset
      dataset_name=$(echo "$line" | cut -d" " -f1)
      output_file="${file_prefix}$dataset_name.csv"
      echo "$line" > "$output_file"
    else
      # append the line to the current dataset's file
      echo "$line" >> "$output_file"
    fi
  done < "$input_file"

  num_gens=$(($(echo "$dataset_name" | sed 's/ds//gi')))
}
#
function SPLIT_DS_BY_COMPRESSOR() {
  # recreate ds folder
  rm -fr $resultsPath/split_ds$gen_i;
  mkdir -p $resultsPath/split_ds$gen_i;

  CHECK_INPUT "$resultsPath/bench-results-DS$gen_i.csv";
  # create names.txt inside each ds folder; it contains all compressor names only, hence the exclusion of DS* and PROGRAM
  cat $resultsPath/bench-results-DS$gen_i.csv | awk '{ print $1} ' | sort -V | uniq | grep -vE "DS\*|PROGRAM" > $resultsPath/split_ds$gen_i/names_ds$gen_i.txt;
  CHECK_INPUT "$resultsPath/split_ds$gen_i/names_ds$gen_i.txt";

  # splits ds into subdatasets by compressor and store them in folder
  c_i=1;
  plotnames="";
  mapfile -t INT_DATA < $resultsPath/split_ds$gen_i/names_ds$gen_i.txt;
  for dint in "${INT_DATA[@]}"; do
    grep $dint $resultsPath/bench-results-DS$gen_i.csv > $resultsPath/split_ds$gen_i/bench-results-DS$gen_i-c$c_i.csv
    tmp="'$resultsPath/split_ds$gen_i/bench-results-DS$gen_i-c$c_i.csv' u 4:5 w points ls $c_i title '$dint', ";
    plotnames="$plotnames $tmp";
    ((++c_i));
  done

  echo -e "${plotnames//, /\\n}";
}
#
function PLOT_DS() {
  gnuplot << EOF
    reset
    set title "Compression efficiency of DS$gen_i - $genome"
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$resultsPath/split_ds$gen_i/bench-plot-ds$gen_i.pdf"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set yrange [*:*]
    set xrange [*:*]
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
    set ylabel "Compression time ($str_time)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
function PLOT_DS_LOG() {
  gnuplot << EOF
    reset
    set title "Compression efficiency of DS$gen_i - $genome (log scale)"
    set logscale xy 2
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$resultsPath/split_ds$gen_i/bench-plot-ds$gen_i-log.pdf"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set yrange [*:*]
    set xrange [*:*]
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
    set ylabel "Compression time ($str_time)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
# === FUNCTIONS TO PLOT EACH DS GRP ===========================================================================
#
function SPLIT_GRP_BY_COMPRESSOR() {
  # recreate grp folder
  rm -fr $resultsPath/split_grp_$size;
  mkdir -p $resultsPath/split_grp_$size;

  CHECK_INPUT "$resultsPath/bench-results-grp-$size.csv";
  # create names.txt inside each ds folder; it contains all compressor names
  cat $resultsPath/bench-results-grp-$size.csv | awk '{ print $1} ' | sort -V | uniq | grep -vE "DS\*|PROGRAM" > $resultsPath/split_grp_$size/names_grp_$size.txt;
  CHECK_INPUT "$resultsPath/split_grp_$size/names_grp_$size.txt";

  # splits ds into subdatasets by compressor and store them in folder
  c_i=1;
  plotnames="";
  mapfile -t INT_DATA < $resultsPath/split_grp_$size/names_grp_$size.txt;
  for dint in "${INT_DATA[@]}"; do
    if [[ $dint != PROGRAM && $dint != DS* ]]; then
      grep $dint $resultsPath/bench-results-grp-$size.csv > $resultsPath/split_grp_$size/bench-results-grp-$size-c$c_i.csv
      tmp="'$resultsPath/split_grp_$size/bench-results-grp-$size-c$c_i.csv' u 4:5 w points ls $c_i title '$dint', ";
      plotnames="$plotnames $tmp";
      ((++c_i));
    fi
  done

  echo -e "${plotnames//, /\\n}";
}
#
function PLOT_GRP() {
  gnuplot << EOF
    reset
    set title "Compression efficiency of sequences from group $size"
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$resultsPath/split_grp_$size/bench-plot-grp-$size.pdf"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set yrange [0:$bytesCF_upperBound]
    set xrange [$bps_lowerBound:$bps_upperBound]
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
    set ylabel "Compression time ($str_time)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
function PLOT_GRP_LOG() {
  gnuplot << EOF
    reset
    set title "Compression efficiency of sequences from group $size (log scale)"
    set logscale xy 2
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$resultsPath/split_grp_$size/bench-plot-grp-$size-log.pdf"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set yrange [0:$bytesCF_upperBound]
    set xrange [$bps_lowerBound:$bps_upperBound]
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
    set ylabel "Compression time ($str_time)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
# === PLOT EACH DS ===========================================================================
#
SPLIT_BENCH_RESULTS_BY_DS;

LOAD_CSV_DSTOSIZE;
genomes=( $(awk -F',' 'NR>1 {print $1}' dsToSize.csv));

gen_i=1;
while (( gen_i <= num_gens )); do
  genome="${genomes[$((gen_i-1))]}"
  size="${dsToSize[$genome]}"

  genome="${genome//_/ }"

  str_time="m";
  if [ "$size" = "xs" ] || [ "$size" = "s" ]; then # smaller files => faster tests => time measured in seconds
    str_time="s";
  fi

  SPLIT_DS_BY_COMPRESSOR;
  PLOT_DS;
  PLOT_DS_LOG;

  (( gen_i++ ))
done
#
# === PLOT EACH GROUP OF DS BY SIZE ===========================================================================
#
clean_grps=( $(find $resultsPath -maxdepth 1 -type f -name "*-grp-*") );

for clean_grp in ${clean_grps[@]}; do
    suffix="${clean_grp##*-grp-}";   # remove everything before the last occurrence of "-grp-"
    size="${suffix%%.*}";            # remove everything after the first dot

    str_time="m";
    if [ "$size" = "xs" ] || [ "$size" = "s" ]; then # smaller files => faster tests => time measured in seconds
      str_time="s";
    fi

    SPLIT_GRP_BY_COMPRESSOR;
    GET_STATS;
    PLOT_GRP;
    PLOT_GRP_LOG;
done
