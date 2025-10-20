#!/bin/bash
mkdir ./aligned
samples=$(ls ./trimmed/*R1.fq.gz | grep -oP '(?<=_)[^_]+(?=_L00)' | grep -v -e 'NA' -e 'PHIX')
ext_samples=$(ls ./trimmed/*R1.fq.gz | grep -oP '.*_(?<capture>[^_]+)(?=_L00)' | grep -v -e 'NA' -e 'PHIX')
echo $samples
for name in $ext_samples; do
	echo "Aligning $name"
	../bin/bwa-mem2 mem -t 28 -R "@RG\tID:readgroupID\tSM:${name##*_}\tPL:ILLUMINA\tLB:libraryName\tPU:platformUnit" \
	../ref/GCF_000001405.40_GRCh38.p14_genomic.fna.gz \
	$name"_L00_R1.fq.gz" $name"_L00_R2.fq.gz" |mbuffer -m 20G |samtools view -bS -o ./aligned/${name##*_}.bam
done
