#!/bin/bash
#
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    *) 
        echo "This program does not have options"
        exit 1;
        ;;
    esac
done
#
configJson="../config.json"
sequencesPath="$(grep 'sequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )"
#
wget http://sweet.ua.pt/pratas/datasets/DNACorpus.zip -P "$sequencesPath"
unzip "$sequencesPath/DNACorpus" -d $sequencesPath
#
corpusSequences=( $(ls "$sequencesPath/DNACorpus") )
for seq in ${corpusSequences[@]}; do
    echo ">x" > $sequencesPath/DNACorpus/$seq.fa
    cat $sequencesPath/DNACorpus/$seq >> $sequencesPath/DNACorpus/$seq.fa
    #
    echo "$sequencesPath/DNACorpus/$seq ---> $sequencesPath/$seq.seq"
    mv $sequencesPath/DNACorpus/$seq $sequencesPath/$seq.seq
    #
    echo "$sequencesPath/DNACorpus/$seq.fa ---> $sequencesPath/$seq.fa"
    mv $sequencesPath/DNACorpus/$seq.fa $sequencesPath/$seq.fa
done
#
rm -fr $sequencesPath/DNACorpus*
