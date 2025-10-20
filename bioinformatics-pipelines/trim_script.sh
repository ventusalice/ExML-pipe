#!/bin/bash
mkdir ./trimmed
samples=$(ls ./Results/Lane00/*R1.fq.gz | grep -oP '(?<=_)[^_]+(?=_L00)' | grep -v -e 'NA' -e 'PHIX')
ext_samples=$(ls ./Results/Lane00/*R1.fq.gz | grep -oP '.*_(?<capture>[^_]+)(?=_L00)' | grep -v -e 'NA' -e 'PHIX')
echo $samples
for name in $ext_samples; do
	echo "Trimming $name"
	fastp -i $name"_L00_R1.fq.gz" -I $name"_L00_R2.fq.gz"\
	-o ./trimmed/$(basename $name)"_L00_R1.fq.gz" -O ./trimmed/$(basename $name)"_L00_R2.fq.gz"\
	--adapter_fasta ../src/truseq_polya.fa -D -q 25 -w 16 -f 10 -F 10 -l 50
done
