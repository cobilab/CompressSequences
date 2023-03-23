#!/bin/bash

genomesPath="../genomes"

# alternativa manual
FaFiles=(
    # "$genomesPath//Pseudobrama_simoni.genome.fa" # 886.11MB
    # "$genomesPath/Rhodeus_ocellatus.genome.fa" # 860.71MB
    # "$genomesPath/TME204.HiFi_HiC.haplotig1.fa" # CASSAVA, 727.09MB
    # "$genomesPath/TME204.HiFi_HiC.haplotig2.fa" # 673.62MB
    
    # "$genomesPath/MFCexample.fa" # 3.5MB
    # "$genomesPath/phyml_tree.fa" # 2.36MB	
    
    "$genomesPath/EscherichiaPhageLambda.fa" # 49.2KB
    "$genomesPath/mt_genome_CM029732.fa" # 15.06KB
    "$genomesPath/zika.fa" # 11.0KB
    "$genomesPath/herpes.fa" # 2.7KB
)

# alternativa automatica
# faFiles=( $(ls $genomesPath | egrep "*.fa$") )

urls=(
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102191/Pseudobrama_simoni.genome.fa" # 886.11MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102192/Rhodeus_ocellatus.genome.fa" # 860.71MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102193/00_Assembly_Fasta/haplotigs/TME204.HiFi_HiC.haplotig1.fa" # CASSAVA, 727.09MB
#     "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102193/00_Assembly_Fasta/haplotigs/TME204.HiFi_HiC.haplotig2.fa" # 673.62MB
    
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102200/phyml_tree.fa" # 2.36MB	
      "https://ftp.cngb.org/pub/gigadb/pub/10.5524/102001_103000/102194/mt_genome_CM029732.fa" # 15.06KB
)

printf "downloading...\n" # downloads fasta files only if they're missing in directory
for url in "${urls[@]}"; do
    faFile=$(echo $url | rev | cut -d'/' -f1 | rev) # gets filename by spliting in "/" and getting the last element
    if [ ! -f "$genomesPath/$faFile" ]; then 
        wget -c $url -P "$genomesPath/"

        faFiles+=($faFile) # alternativa manual

        # se outros ficheiros do mesmo genoma já existirem apesar de .fa ter sido criado depois, remove-los para atualizar .seq
        find "$genomesPath/" -name "$faFile.*" ! -name "*.fa" -type f -delete
    else 
        echo "$faFile has already been downloaded"
    fi
done

# atualizar lista de ficheiros fasta, na alternativa automatica
# faFiles=( $(ls $genomesPath | egrep "*.fa$") )

printf "\npreprocessing...\n" # preprocesses each fasta file into its respective seq files
for faFile in "${faFiles[@]}"; do
    seqFile=$(echo $faFile | sed 's/fa/seq/g') # replaces "fa" with "seq" in the string

    if [ ! -f "$genomesPath/$seqFile" ]; then 
        echo "$seqFile has been created"
        cat "$genomesPath/$faFile" | grep -v ">" | tr -d -c "ACGT" > "$genomesPath/$seqFile" # removes lines with comments and non-nucleotide chars
    else
        echo "$seqFile already exists"
    fi
done
