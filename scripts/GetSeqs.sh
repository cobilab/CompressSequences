#!/bin/bash

genomesPath="." # "../genomes"

faFiles=(
    # "Pseudobrama_simoni.genome.fa" # 886.11MB
    # "Rhodeus_ocellatus.genome.fa" # 860.71MB
    # "TME204.HiFi_HiC.haplotig1.fa" # CASSAVA, 727.09MB
    # "TME204.HiFi_HiC.haplotig2.fa" # 673.62MB
    
    # "MFCexample.fa" # 3.5MB
    # "phyml_tree.fa" # 2.36MB	
    
    "RL0048_chloroplast.fa" # 154.2KB
    "RL0057_chloroplast.fa" # 135.7KB
    "EscherichiaPhageLambda.fa" # 49.2KB
    "mt_genome_CM029732.fa" # 15.06KB
    "zika.fa" # 11.0KB
    "herpes.fa" # 2.7KB
)

urls=(
#     "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz" # human reference genome # ~3GB
#     "https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz" # human reference genome # ~3GB

#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102191/Pseudobrama_simoni.genome.fa" # 886.11MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102192/Rhodeus_ocellatus.genome.fa" # 860.71MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102193/00_Assembly_Fasta/haplotigs/TME204.HiFi_HiC.haplotig1.fa" # CASSAVA, 727.09MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102193/00_Assembly_Fasta/haplotigs/TME204.HiFi_HiC.haplotig2.fa" # 673.62MB
    
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102200/phyml_tree.fa" # 2.36MB
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/101001_102000/101111/RL0048_chloroplast.fa" # 154.2KB
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/101001_102000/101120/RL0057_chloroplast.fa" # 135.7KB
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102194/mt_genome_CM029732.fa" # 15.06KB
)

printf "downloading...\n" # downloads fasta files only if they're missing in directory
for url in "${urls[@]}"; do
    faFile=$(echo $url | rev | cut -d'/' -f1 | rev) # gets filename by spliting in "/" and getting the last element

    if [[ ! -f "$genomesPath/$faFile" ]]; then 
        wget -c $url -P "$genomesPath/"

        # se outros ficheiros do mesmo genoma já existirem apesar de .fa ter sido criado depois, remove-los para atualizar .seq
        find "$genomesPath/" -name "$faFile.*" ! -name "*.fa" -type f -delete
    else 
        echo "$faFile has already been downloaded"
    fi
done

faFiles=( $(ls $genomesPath | egrep -v "_clean" | egrep "*.fa$") )

printf "\npreprocessing...\n" # preprocesses each fasta file into its respective seq files
for faFile in "${faFiles[@]}"; do 

    if [[ "$*" == *"--installed-with-conda"* ||  "$*" == *"-iwc"* ]]; then
        # preprocess .fa files, whether they were already preprocessed or not
        gto_fasta_to_seq < $faFile | tr 'agct' 'AGCT' | tr -d -c "AGCT" | gto_fasta_from_seq -n x -l 80 > ${faFile%.*}_clean.fa
    else
        ../bin/gto_fasta_to_seq < $faFile | tr 'agct' 'AGCT' | tr -d -c "AGCT" | ../bin/gto_fasta_from_seq -n x -l 80 > ${faFile%.*}_clean.fa
    fi

    seqFile=$(echo $faFile | sed 's/fa/seq/g'); # replaces .fa with .seq
    if [[ ! -f $genomesPath/$seqFile ]]; then   
        cat "$genomesPath/$faFile" | grep -v ">" | tr -d -c "ACGT" > "$genomesPath/$seqFile" # removes lines with comments and non-nucleotide chars
        echo "$seqFile has been created"
    else
        echo "$seqFile already exists"
    fi
done
