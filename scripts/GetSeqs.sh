#!/bin/bash

genomesPath="../genomes"

# alternativa manual
faFiles=(
    # "Pseudobrama_simoni.genome.fa" # 886.11MB
    # "Rhodeus_ocellatus.genome.fa" # 860.71MB
    # "TME204.HiFi_HiC.haplotig1.fa" # CASSAVA, 727.09MB
    # "TME204.HiFi_HiC.haplotig2.fa" # 673.62MB
    
    # "MFCexample.fa" # 3.5MB
    # "phyml_tree.fa" # 2.36MB	
    
    "EscherichiaPhageLambda.fa" # 49.2KB
    "mt_genome_CM029732.fa" # 15.06KB
    "zika.fa" # 11.0KB
    "herpes.fa" # 2.7KB
)

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
    if [[ ! -f "$genomesPath/$faFile" ]]; then 
        wget -c $url -P "$genomesPath/"

        faFiles+=($faFile) # alternativa manual

        # se outros ficheiros do mesmo genoma já existirem apesar de .fa ter sido criado depois, remove-los para atualizar .seq
        find "$genomesPath/" -name "$faFile.*" ! -name "*.fa" -type f -delete
    else 
        echo "$faFile has already been downloaded"
    fi
done

# alternativa automatica
# faFiles=( $(ls $genomesPath | egrep "*.fa$") )

printf "\npreprocessing...\n" # preprocesses each fasta file into its respective seq files
for faFile in "${faFiles[@]}"; do 
    seqFile=$(echo $faFile | sed 's/fa/seq/g'); # replaces .fa with .seq
    if [[ -f $genomesPath/$seqFile ]]; then   
        cat "$genomesPath/$faFile" | grep -v ">" | tr -d -c "ACGT" > "$genomesPath/$seqFile" # removes lines with comments and non-nucleotide chars
        echo "$seqFile has been created"
    else
        echo "$seqFile already exists"
    fi
done
