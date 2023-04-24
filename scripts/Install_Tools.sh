#!/bin/bash
#
if [[ "$*" == *"--install-with-conda"* ||  "$*" == *"-iwc"* ]]; then
    #
    # GTO ------------------------------------------------------------------------
    #
    conda install -c cobilab gto --yes
    #
    # JARVIS1 ----------------------------------------------------------------------
    #
    conda install -y -c bioconda jarvis
    #
    # GeCo3 ------------------------------------------------------------------------
    #
    conda install -y -c bioconda geco3
    #
    # GeCo2 ------------------------------------------------------------------------
    #
    conda install -y -c bioconda geco2
    #
    # NAF ------------------------------------------------------------------------
    #
    conda install -y -c bioconda naf
    #
    # AGC ------------------------------------------------------------------------
    #
    conda install -c bioconda agc
    #
    # MBGC ------------------------------------------------------------------------
    #
    conda install -c bioconda mbgc 
    #
    # PAQ8l ------------------------------------------------------------------------
    #
    conda install -c bioconda seqtk -y
else
    #
    # GTO ------------------------------------------------------------------------
    #
    git clone https://github.com/bioinformatics-ua/gto.git
    cd gto/src/
    make
    #
    # JARVIS1 ----------------------------------------------------------------------
    #
    git clone https://github.com/pratas/jarvis.git
    cd jarvis/src/
    make
    cp JARVIS ../../
    cd ../../
    rm -fr jarvis
    #
    # GeCo3 ------------------------------------------------------------------------
    #
    git clone https://github.com/cobilab/geco3.git
    cd geco3/src/
    make
    cp GeCo3 ../../
    cp GeDe3 ../../
    cd ../../
    rm -fr geco3
    #
    # GeCo2 ------------------------------------------------------------------------
    #
    git clone https://github.com/pratas/geco2.git
    cd geco2/src/
    cmake .
    make
    cp GeCo2 ../../
    cp GeDe2 ../../
    cd ../../
    rm -fr geco2
    #
    # NAF ------------------------------------------------------------------------
    #
    sudo apt install git gcc make diffutils perl
    git clone --recurse-submodules https://github.com/KirillKryukov/naf.git
    cd naf && make && make test && sudo make install
    mv ennaf/ennaf ../
    mv unnaf/unnaf ../
    cd ../
    #
    # AGC ------------------------------------------------------------------------
    #
    git clone https://github.com/refresh-bio/agc
    cd agc && make
    mv ../agc ../agc_dir
    mv agc_dir/agc .
    cd ../
    #
    # MBGC ------------------------------------------------------------------------
    #
    git clone https://github.com/kowallus/mbgc.git
    cd mbgc
    mkdir build
    cd build
    cmake ..
    make mbgc
    mv ../../mbgc ../../mbgc_dir # rename mbgc directory to move mbgc executable to scripts
    mv mbgc ../..
    cd ../..
    #
    # PAQ8l ------------------------------------------------------------------------
    #
    mkdir paq8l_dir
    cd paq8l_dir
    wget http://mattmahoney.net/dc/paq8l.zip
    unzip paq8l.zip
    g++ paq8l.cpp -O2 -DUNIX -DNOASM -s -o paq8l
    rm -fr paq8l.zip
    cd ..
    mv paq8l_dir/paq8l .
fi
#
# BSC --------------------------------------------------------------------------
#
rm -fr v0.2.1.tar.gz bsc-m03-0.2.1
wget https://github.com/IlyaGrebnov/bsc-m03/archive/refs/tags/v0.2.1.tar.gz
tar -vxzf v0.2.1.tar.gz
cd bsc-m03-0.2.1/
cmake .
make
cp bsc-m03 ..
cd ..
#
# MFC --------------------------------------------------------------------------
#
rm MFCompress-linux64-1.01.tgz MFCompress-linux64-1.01/ -fr
wget http://sweet.ua.pt/ap/software/mfcompress/MFCompress-linux64-1.01.tgz
tar -xvzf MFCompress-linux64-1.01.tgz
cp MFCompress-linux64-1.01/MFCompressC .
cp MFCompress-linux64-1.01/MFCompressD .
#
# JARVIS2 ----------------------------------------------------------------------
#
rm -rf JARVIS2-bin-64-Linux.zip extra JARVIS2.sh JARVIS2-bin-64-Linux/
wget https://github.com/cobioders/HumanGenome/raw/main/bin/JARVIS2-bin-64-Linux.zip
unzip -o JARVIS2-bin-64-Linux.zip
cp JARVIS2-bin-64-Linux/extra/* .
cp JARVIS2-bin-64-Linux/JARVIS2.sh .
cp JARVIS2-bin-64-Linux/JARVIS2 .
#
# NNCP -------------------------------------------------------------------------
#
rm -fr nncp-2021-06-01.tar.gz nncp-2021-06-01/
wget https://bellard.org/nncp/nncp-2021-06-01.tar.gz
tar -vxzf nncp-2021-06-01.tar.gz
cd nncp-2021-06-01/
make
cp nncp ../
cd ..
#
# PAQ8L ------------------------------------------------------------------------
#
mkdir -p tmp_paq8l
cd tmp_paq8l/
rm -fr paq8l.zip
wget http://mattmahoney.net/dc/paq8l.zip
unzip paq8l.zip
g++ paq8l.cpp -O2 -DUNIX -DNOASM -s -o paq8l
cp paq8l ../
cd ../
rm -fr tmp_paq8l/
#
# CMIX ------------------------------------------------------------------------
#
git clone https://github.com/byronknoll/cmix.git
cd cmix
sudo apt update
sudo apt install clang
make 
cd ..
mv cmix cmix_dir
mv cmix_dir/cmix .
mv cmix_dir/enwik9-preproc .
#
# MEMRGC ------------------------------------------------------------------------
#
git clone https://github.com/yuansliu/memrgc.git
mv memrgc memrgc_dir
cd memrgc_dir
make
cd ..
mv memrgc_dir/memrgc .
