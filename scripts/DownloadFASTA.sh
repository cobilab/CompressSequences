#!/bin/bash
#
function SHOW_HELP() {
  echo " -------------------------------------------------------";
  echo "                                                        ";
  echo " CompressSequences - JARIVS3 Optimization Benchmark     ";
  echo " Download FASTA files script                            ";
  echo "                                                        ";
  echo " Program options ---------------------------------------";
  echo "                                                        ";
  echo " --help|-h.....................................Show this";
  echo " -id........................Download sequence by NCBI id"; 
  echo "                                                        ";
  echo " -------------------------------------------------------";
}
#
# ===========================================================================
#
defaultIDs=(

    "NC_058373.1" # Felis catus isolate Fca126 chromosome B3, F.catus_Fca126_mat1.0, whole genome shotgun sequence (144MB)

    "NC_000001.11" # complete chromosome 1 from Homo sapiens
    "NC_000008.11" # complete chromosome 8 from Homo sapiens
    "NC_000021.9" # complete chromosome 21 from Homo sapiens

    "NC_000024.1" # CY

    "NC_000908.2" # Mycoplasmoides genitalium G37, complete sequence

    "BA000046.3" # Pan troglodytes DNA, chromosome 22, complete sequence (32 MB)
    "NC_073246.2" # Gorilla gorilla gorilla isolate KB3781 chromosome 22, NHGRI_mGorGor1-v2.0_pri, whole genome shotgun sequence (40MB)
    "NC_072005.2" # Pongo abelii isolate AG06213 chromosome 20, NHGRI_mPonAbe1-v2.0_pri, whole genome shotgun sequence (63M)

    "NC_004461.1" # Staphylococcus epidermidis ATCC 12228, complete sequence (staphylococcus_epidermidis_raw.fa) (2,4M)
    "CM029732.1" # Pollicipes pollicipes isolate AB1234 mitochondrion, complete sequence, whole genome shotgun sequence (mt_genome_CM029732_raw.fa) (15KB)
    "OM812693.1" # covid (SARS_CoV_Hun_1_raw.fa) (30K)
    "CM047480.1" # Aldabrachelys gigantea (290M)

    "KT868810.1" # Cutavirus strain BR-283 NS1 gene, partial cds; and putative VP1, hypothetical protein, VP2, and hypothetical protein genes, complete cds (4,3K)

    "NC_000898.1" # Human herpesvirus 6B, complete genome (161K)
    "NC_001664.4" # Human betaherpesvirus 6A, variant A DNA, complete virion genome, isolate U1102 (158K)
)
#
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h)
        SHOW_HELP
        shift 2; 
        ;;
    -id)
        ids+=("$2")
        shift 2; 
        ;;
    *) 
        echo "Invalid option: $1"
        exit 1;
        ;;
    esac
done
#
# default ids are only considered if no ncbi id is defined by user
[ "${#ids[@]}" -eq 0 ] && ids=( "${defaultIDs[@]}" )
#
configJson="../config.json"
rawSequencesPath="$(grep 'rawSequencesPath' $configJson | awk -F':' '{print $2}' | tr -d '[:space:],"' )";
mkdir -p $rawSequencesPath;
#
# === Download rawFiles ===========================================================================
#
printf "downloading ${#ids[@]} sequence files...\n"
for id in "${ids[@]}"; do
    #
    url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$id&rettype=fasta&retmode=text"
    rawFile="$(echo "${id}_raw" | tr '.' '_').fa"
    #
    if [[ ! -f "$rawSequencesPath/$rawFile" ]]; then 
        echo -e "\033[32mdownloading $origFile file... \033[0m"
        curl $url -o "$rawSequencesPath/$rawFile"
    else
        # no need to download a file that already exists
        echo "$rawFile has been previously downloaded"
    fi
    #
    # unzip file if it ends with .gz
    if [[ "$rawSequencesPath/$rawFile" == *.gz ]]; then
        echo -e "$\033[32mrawFile is being gunzipped... \033[0m"
        gunzip "$rawSequencesPath/$rawFile"
    fi
done