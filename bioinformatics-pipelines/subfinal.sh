#!/bin/bash

# Process all *_snv.tsv files in current directory
for file in ./final/*_{snv,lid}.tsv; do
  # Get the prefix for the last column name from filename (filename without _snv.tsv)
  filename=$(basename "$file")
  prefix="${filename%%_*}"

  # Get the number of columns from the header by counting tabs + 1
  num_cols=$(head -n 1 "$file" | awk -F"\t" '{print NF}')

  # Get the column number of Zygosity (assuming header has it)
  zyg_col=$(head -n 1 "$file" | tr '\t' '\n' | nl -v 1 | grep -w "Zygosity" | awk '{print $1}')

  # If Zygosity column not found, skip
  if [[ -z $zyg_col ]]; then
    echo "Zygosity column not found in $file, skipping"
    continue
  fi

  # Also get column number of prefix column (like the filename without _snv)
  prefix_col=$(head -n 1 "$file" | tr '\t' '\n' | nl -v 1 | awk -v colname="$prefix" '$2 == colname {print $1}')

  # If prefix column not found, skip
  if [[ -z $prefix_col ]]; then
    echo "Column named $prefix not found in $file, skipping"
    continue
  fi

  # Create output temporary file
  tmpfile="${file}.tmp"

  # Process the file line by line
  awk -v zyg=$zyg_col -v pref=$prefix_col -F"\t" -v OFS="\t" '
    NR==1 {print; next}
    {
      split($pref, arr, ":")
      $zyg = arr[1]
      print
    }
  ' "$file" > "$tmpfile" && mv "$tmpfile" "$file"

done
