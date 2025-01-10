#!/bin/bash
#
configJson="../config.json"
ds_sizesBase2="$(grep 'DS_sizesBase2' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
ds_sizesBase10="$(grep 'DS_sizesBase10' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
#
# ==============================================================================
#
function SHOW_HELP() {
  echo " -------------------------------------------------------";
  echo "                                                        ";
  echo " CompressSequences - benchmark                          ";
  echo "                                                        ";
  echo " Program options ---------------------------------------";
  echo "                                                        ";
  echo "-h|--help......................................Show this";
  echo "-iwc|--install-with-conda........Install only with conda";
  echo "-iwb|--install-with-both..Install with and without conda";
  echo "-g|-grp|--group....................Select sequence group";
  echo "-s|--sequence............................Select sequence";
  echo "-br|--b-range..................Define x-axis (BPS) range";
  echo "-trs|--trange-s...Define y-axis (compression time) range";
  echo "                                              in seconds";
  echo "-trm|--trange-m...Define y-axis (compression time) range";
  echo "                                              in minutes";
  echo "-trh|--trange-h...Define y-axis (compression time) range";
  echo "                                                in hours";
  echo "                                                        ";
  echo " -------------------------------------------------------";
}
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
  # rm -fr $plotsSubFolder;
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
    if [[ $compressor != PROGRAM && $compressor != DS* && $compressor != grp* ]]; then
      compressor_tsv="$compressor_tsv_prefix$c_i.tsv";
      grep $compressor $tsvFile > "$compressor_tsv";
      
      tmp="'$compressor_tsv' u 5:6 w points ls ${compressor/-/_} title '$compressor', ";
      plotnames="$plotnames $tmp";
      
      tmp_log="'$compressor_tsv' u 5:(pseudo_log(6)) w points ls ${compressor/-/_} title '$compressor', ";
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
    bps_min=$(awk 'NR==2{print $1}' "tempX.txt");
    bps_Q1=$(awk 'NR==2{print $2}' "tempX.txt");
    bps_Q3=$(awk 'NR==2{print $5}' "tempX.txt");
    bps_max=$(awk 'NR==2{print $NF}' "tempX.txt");

    # row structure: Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
    Rscript -e 'summary(as.numeric(readLines("stdin")))' < <(awk '{if ($6 ~ /^[0-9.]+$/) print $6}' $tsvFile) > tempY.txt
    timeS_min=$(awk 'NR==2{print $1}' "tempY.txt");
    timeS_Q1=$(awk 'NR==2{print $2}' "tempY.txt");
    timeS_Q3=$(awk 'NR==2{print $5}' "tempY.txt");
    timeS_max=$(awk 'NR==2{print $NF}' "tempY.txt");

    # IQR (Inter Quartile Range) = Q3 - Q1
    bps_IQR=$(echo "$bps_Q3-$bps_Q1" | bc);
    timeS_IQR=$(echo "$timeS_Q3-$timeS_Q1" | bc);

    # # lower bound = Q1 – 0.025*IQR
    # bps_lowerBound=$(echo "$bps_Q1-0.025*$bps_IQR" | bc);
    # timeS_lowerBound=$(echo "$timeS_Q1-0.025*$timeS_IQR" | bc);

    # # upper bound = Q3 + 0.025*IQR
    # bps_upperBound=$(echo "$bps_Q3+0.025*$bps_IQR" | bc);
    # timeS_upperBound=$(echo "$timeS_Q3+0.025*$timeS_IQR" | bc);

    bps_lowerBound=$(echo "$bps_min" | bc);
    bps_upperBound=$(echo "$bps_max" | bc);
    timeS_lowerBound=$(echo "$timeS_min" | bc);
    timeS_upperBound=$(echo "$timeS_max" | bc);

    if (( $(echo "$bps_lowerBound < 0" | bc -l) )); then
      bps_lowerBound=-0.01;
    fi
    if (( $(echo "$bps_upperBound > 2" | bc -l) )); then
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
    printf "ctime (s) Q1: $timeS_Q1 \n";
    printf "ctime (s) Q3: $timeS_Q3 \n";
    printf "ctime (s) IQR: $timeS_IQR \n";
    printf "ctime (s) lower bound: $timeS_lowerBound \n";
    printf "ctime (s) upper bound: $timeS_upperBound \n\n";

    rm -fr tempX.txt tempY.txt;

    [[ ! -n "$bps_lb" ]] && bps_lb="*" # $bps_lowerBound
    [[ ! -n "$bps_ub" ]] && (( $(echo "$bps_max>=2"|bc) )) && bps_ub="2.05"
    [[ ! -n "$bps_ub" ]] && (( $(echo "$bps_max<2"|bc) )) && bps_ub="$bps_max"
    [[ ! -n "$tlb_s" ]] && tlb_s="0" # $timeS_lowerBound
    [[ ! -n "$tub_s" ]] && tub_s="$timeS_upperBound"
}
#
# BSC-m03
# BZIP2
# CMIX
# DMcompress
# GeCo2
# GeCo3
# JARVIS2_BIN
# JARVIS3_BIN
# LZMA
# MFC
# NAF
# PAQ8
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
    set xrange [$bps_lb:$bps_ub]
    set yrange [$tlb_s:$tub_s]
    set xtics auto
    set ytics auto
    set key top right
    #
    BSC_m03 = 1
    BZIP2=2
    CMIX=3
    DMcompress=4
    GeCo2=5
    GeCo3=6
    JARVIS2_BIN=7
    JARVIS3_BIN=8
    LZMA=9
    MFC=10
    NAF=11
    PAQ8=12
    #
    set style line BSC_m03 lc rgb '#990099'  pt 1 ps 0.6  # circle
    set style line BZIP2 lc rgb '#004C99'  pt 2 ps 0.6  # circle
    set style line CMIX lc rgb '#CCCC00'  pt 3 ps 0.6  # circle
    set style line DMcompress lc rgb 'red'  pt 7 ps 0.6  # circle 
    set style line GeCo2 lc rgb '#009900'  pt 5 ps 0.6  # circle
    set style line GeCo3 lc rgb '#990000'  pt 6 ps 0.6  # circle
    set style line JARVIS2_BIN lc rgb '#009999'  pt 4 ps 0.6  # circle
    set style line JARVIS3_BIN lc rgb '#99004C'  pt 8 ps 0.6  # circle
    set style line LZMA lc rgb '#CC6600'  pt 9 ps 0.6  # circle
    set style line MFC lc rgb '#322152' pt 10 ps 0.6  # circle    
    set style line NAF lc rgb '#425152' pt 11 ps 0.6  # circle  
    set style line PAQ8 lc rgb '#00CCCC' pt 11 ps 0.6  # circle  
    #
    set grid
    set ylabel "Compression time (s)"
    set xlabel "BPS"
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
    set xrange [$bps_lb:$bps_ub]
    set yrange [$tlb_s:$tub_s]
    set xtics auto
    set ytics auto 
    set key top right
    #
    BSC_m03 = 1
    BZIP2=2
    CMIX=3
    DMcompress=4
    GeCo2=5
    GeCo3=6
    JARVIS2_BIN=7
    JARVIS3_BIN=8
    LZMA=9
    MFC=10
    NAF=11
    PAQ8=12
    #
    set style line BSC_m03 lc rgb '#990099'  pt 1 ps 0.6  # circle
    set style line BZIP2 lc rgb '#004C99'  pt 2 ps 0.6  # circle
    set style line CMIX lc rgb '#CCCC00'  pt 3 ps 0.6  # circle
    set style line DMcompress lc rgb 'red'  pt 7 ps 0.6  # circle 
    set style line GeCo2 lc rgb '#009900'  pt 5 ps 0.6  # circle
    set style line GeCo3 lc rgb '#990000'  pt 6 ps 0.6  # circle
    set style line JARVIS2_BIN lc rgb '#009999'  pt 4 ps 0.6  # circle
    set style line JARVIS3_BIN lc rgb '#99004C'  pt 8 ps 0.6  # circle
    set style line LZMA lc rgb '#CC6600'  pt 9 ps 0.6  # circle
    set style line MFC lc rgb '#322152' pt 10 ps 0.6  # circle    
    set style line NAF lc rgb '#425152' pt 11 ps 0.6  # circle  
    set style line PAQ8 lc rgb '#00CCCC' pt 11 ps 0.6  # circle   
    set grid
    set ylabel "Compression time (s)"
    set xlabel "BPS"
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
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      SHOW_HELP;
      shift;
      ;;
    -g|-grp|--group)
        data=$(echo "$2" | tr -d "grpGRP")
        tsvFile="bench-results-grp$data.tsv"
        tsvFiles+=( $(find "$resultsPath" -maxdepth 1 -type f -name "$tsvFile" | sort -V) );
        shift 2;
        ;; 
    -s|--sequence)
        data=$(echo "$2" | tr -d "dsDS")
        tsvFile="bench-results-DS$data-*.tsv"
        tsvFiles+=( $(find "$resultsPath" -maxdepth 1 -type f -name "$tsvFile" | sort -V) );
        shift 2;
        ;; 
    -br|--b-range)
        bps_lb="$(echo $2 | cut -d':' -f1)";
        bps_ub="$(echo $2 | cut -d':' -f2)";
        shift 2;
        ;;
    -trs|--trange-s)
        tlb_s="$(echo $2 | cut -d':' -f1)";
        tub_s="$(echo $2 | cut -d':' -f2)";
        shift 2;
        ;;
    -trm|--trange-m)
        tlb_m="$(echo $2 | cut -d':' -f1)";
        tub_m="$(echo $2 | cut -d':' -f2)";
        shift 2;
        ;;
    -trh|--trange-h)
        tlb_h="$(echo $2 | cut -d':' -f1)";
        tub_h="$(echo $2 | cut -d':' -f2)";
        shift 2;
        ;;
    *) 
        echo "Invalid option: $1"
        exit 1;
        ;;
    esac
done
#
# === MAIN: PLOT EACH TSV FILE ===========================================================================
#
defaultTsvFiles=( $(find "$resultsPath" -maxdepth 1 -type f -name "*.tsv" | sort -V) );
[ ${#tsvFiles[@]} -eq 0 ] && tsvFiles=( "${defaultTsvFiles[@]}" )
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
  plot_title="${sequence/_/.}";
  plot_title_log="${sequence/_/.} (log scale)";
  #
  SPLIT_FILE_BY_COMPRESSOR;
  GET_PLOT_BOUNDS;
  PLOT;
  PLOT_LOG;
done
