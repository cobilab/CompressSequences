# clean compressed and decompressed files
sequencesPath="$HOME/sequences"
find $sequencesPath -maxdepth 1 ! -name "*.sh" ! -name "*.fa" ! -name "*.seq" ! -name "*.csv" -type f -delete && rm -fr *_out*
