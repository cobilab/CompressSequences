# clean compressed and decompressed files
find . -maxdepth 1 ! -name "*.sh" ! -name "*.fa" ! -name "*.seq" -type f -delete

rm -fr *_out*
rm -fr *_agc.fa
