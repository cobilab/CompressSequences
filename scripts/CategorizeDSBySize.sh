#!/bin/bash
#
genomesPath=".";
#
output_file="dsToSize.csv";
#
sizes=("xs" "s" "m" "l" "xl");
sizes_bytes=(1048576 104857600 1073741824 10737418240 10737418240);
#
declare -A dsToSize;
#
seqFiles=( $(ls "$genomesPath" | egrep ".seq$") );
#
# ==============================================================================
#
for seqFile in "${seqFiles[@]}"; do
    seq_num_bytes=`ls -la $seqFile | awk '{ print $5 }'`;

    ds="${seqFile%.*}"
    sucess=false;

    first=${sizes_bytes[0]};
    if (( seq_num_bytes < first )); then # lower than 1MB
        dsToSize[$ds]=${sizes[0]};
        success=true;
    fi

    length=$(( ${#sizes_bytes[@]} - 2 ))
    for ((i = 1; i <= length; i++ )); do
        lower_elem=${sizes_bytes[i]};
        higher_elem=${sizes_bytes[i+1]}
        if (( seq_num_bytes >= lower_elem && seq_num_bytes < higher_elem )); then # lower than 100MB
            dsToSize[$ds]=${sizes[$i]};
            success=true;
        fi
    done

    last=${sizes_bytes[-1]}
    if (( seq_num_bytes >= last )); then # higher than or equal to 10GB
        dsToSize[$ds]=${sizes[-1]};
        success=true;
    fi

    if [ ! "$success" ]; then
        echo "error assigning ds$gen_i to a grp"
    fi
done

for i in ${!dsToSize[@]}; do
    echo $i ${dsToSize[$i]};
done

# iterate over the hashmap and write to the CSV file
echo "ds,size" > "$output_file"  # write the header row
for ds in "${!dsToSize[@]}"; do
  size="${dsToSize[$ds]}"
  echo "$ds,$size" >> "$output_file"
done