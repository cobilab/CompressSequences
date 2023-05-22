#!/bin/bash
#
# This script can only be executed after running the script below
./PlotEachDS.sh 
#
resultsPath="../results";
#
declare -A sizesToBytes;

sizes=("xs" "s" "m" "l" "xl");
sizes_bytes=(1048576 104857600 1073741824 10737418240 10737418240);

for (( i=0; i<${#sizes[@]}; i++ )); do
    sizesToBytes[${sizes[$i]}]=${sizes_bytes[$i]}
done
#
# ==============================================================================
#
function CHECK_INPUT () {
  FILE=$1
  if [ -f "$FILE" ];
    then
    echo "Input filename: $FILE"
    else
    echo -e "\e[31mERROR: input file not found ($FILE)!\e[0m";
    exit;
    fi
  }
#
function GET_NUM_GENS() {
  # read the input file
  input_file="$resultsPath/bench-results.txt"

  while IFS= read -r line; do
    # check if the line contains a dataset name
    if [[ $line == DS* ]]; then
      # create a new output file for the dataset
      dataset_name=$(echo "$line" | cut -d" " -f1)
    fi
  done < "$input_file"

  num_gens=$(($(echo "$dataset_name" | sed 's/ds//gi')))
}
#
function GRP_DS_BY_SIZE() {
  # group ds by its size
  bytes_col_unique_vals=($(awk -F' ' '!/-/ && $2 != "BYTES" {print $2}' $resultsPath/bench-results-DS$gen_i.csv | sort -u));

  seq_num_bytes=${bytes_col_unique_vals[0]}
  for val in "${bytes_col_unique_vals[@]}"; do
      if [[ $val -lt $seq_num_bytes ]]; then
          seq_num_bytes=$val
      fi
  done

  sucess=false;

  first=${sizes_bytes[0]};
  if (( seq_num_bytes < first )); then # lower than 1MB
    while IFS= read -r line; do
        # Check if the line starts with "DS" or "PROGRAM"
        if [[ "$line" != DS* && "$line" != PROGRAM* ]]; then
            echo "$line" >> "$resultsPath/bench-results-grp-${sizes[0]}.csv"
        fi
    done < "$resultsPath/bench-results-DS$gen_i.csv"
    success=true;
  fi

  length=$(( ${#sizes_bytes[@]} - 2 ))
  for ((i = 1; i <= length; i++ )); do
    lower_elem=${sizes_bytes[i]};
    higher_elem=${sizes_bytes[i+1]}
    if (( seq_num_bytes >= lower_elem && seq_num_bytes < higher_elem )); then # lower than 100MB
      while IFS= read -r line; do
          # Check if the line starts with "DS" or "PROGRAM"
          if [[ "$line" != DS* && "$line" != PROGRAM* ]]; then
              echo "$line" >> "$resultsPath/bench-results-grp-${sizes[i]}.csv"
          fi
      done < "$resultsPath/bench-results-DS$gen_i.csv"
      success=true;
    fi
  done

  last=${sizes_bytes[-1]}
  if (( seq_num_bytes >= last )); then # higher than or equal to 10GB
        while IFS= read -r line; do
        # Check if the line starts with "DS" or "PROGRAM"
        if [[ "$line" != DS* && "$line" != PROGRAM* ]]; then
            echo "$line" >> "$resultsPath/bench-results-grp-${sizes[4]}.csv"
        fi
    done < "$resultsPath/bench-results-DS$gen_i.csv"
    success=true;
  fi

  if [ ! "$success" ]; then
    echo "error assigning ds$gen_i to a grp"
  fi
}
#
function SPLIT_GRP() {
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
  # plots ds results and stores it in folder
  gnuplot << EOF
    reset
    set terminal pdfcairo enhanced color font 'Verdade,12'
    set output "$resultsPath/split_grp_$size/bench-plot-grp-$size.pdf"
    set style line 101 lc rgb '#000000' lt 1 lw 2 
    set border 3 front ls 101
    # set tics nomirror out scale 0.01
    set key outside right top vertical Right noreverse noenhanced autotitle nobox
    set style histogram clustered gap 1 title textcolor lt -1
    set xtics border in scale 0,0 nomirror #rotate by -60  autojustify
    set yrange [auto:auto]
    set xrange [auto:auto]
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
    set ylabel "Real time (seconds)"
    set xlabel "Average number of bits per symbol"
    plot $plotnames
EOF
}
#
# === MAIN ===========================================================================
#

# recreate grp files
rm -fr $resultsPath/bench-results-grp*.csv
for size in ${sizes[@]}; do
    touch $resultsPath/bench-results-grp-$size.csv;
done

GET_NUM_GENS;

gen_i=1;
while (( gen_i <= num_gens )); do
  GRP_DS_BY_SIZE;
  (( gen_i++ ))
done

for size in ${sizes[@]}; do
    SPLIT_GRP;
    PLOT_GRP;
done
