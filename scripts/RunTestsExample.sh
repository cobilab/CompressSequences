./RunSeqs.sh --size xs 1>  ../results/bench-results-raw-xs.txt 2> stderr_xs.txt & 
./RunSeqs.sh --size s 1> ../results/bench-results-raw-s.txt 2> stderr_s.txt &
./RunSeqs.sh --size m 1> ../results/bench-results-raw-m.txt 2> stderr_m.txt &
./RunSeqs.sh --genome chm13v2.0 1> ../results/bench-results-raw-ds25-l.txt 2> stderr_ds25_l.txt &
