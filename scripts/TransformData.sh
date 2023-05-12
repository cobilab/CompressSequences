#!/bin/bash

input_file="../bench-results.txt"
output_file="../bench-results-transformed.csv"

# Clear the output file if it exists
> "$output_file"

# Read each line of the input file and extract the required columns
while IFS=$'\t' read -r program bytes c_bytes bps c_time _; do
    # Skip the header line
    if [[ "$program" == "PROGRAM" ]]; then
        echo "c_bytes   bps c_time    program" >> "$output_file"
        continue
    fi

    # Write the selected columns and their respective data to the output file	
    # C_Bytes	        Bps	    C_Time (m)    Program	
    echo "$c_bytes  $bps $c_time    $program" >> "$output_file"
done < "$input_file"
