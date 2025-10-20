#!/bin/bash
threads=28
REFERENCE="../ref/GCF_000001405.40_GRCh38.p14_genomic.fna"
TARGET_BED="../src/WES_bed_file/CoreExomePanel.hg38.p12.target.v3_ncbi.bed"

mkdir -p ./variant

max_jobs=28
pids=()

for name in ./aligned/*.bam; do
    (
    shortname=$(basename "$name")
    ../bin/freebayes -f "$REFERENCE" -t "$TARGET_BED" "$name" > ./variant/${shortname%.bam}.fb.raw.vcf
    bcftools filter --threads $threads -e 'QUAL < 20 || INFO/DP < 10' -O v -o ./variant/${shortname%.bam}.fb.all.filtered.vcf ./variant/${shortname%.bam}.fb.raw.vcf
    bcftools view --threads $threads -v snps -o ./variant/${shortname%.bam}.fb.snps.filtered.vcf ./variant/${shortname%.bam}.fb.all.filtered.vcf
    bcftools view --threads $threads -v indels -o ./variant/${shortname%.bam}.fb.indels.filtered.vcf ./variant/${shortname%.bam}.fb.all.filtered.vcf
    ) &
    pids+=($!)

    if [ ${#pids[@]} -ge $max_jobs ]; then
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
        pids=()
    fi
done

# Wait for remaining jobs
for pid in "${pids[@]}"; do
    wait "$pid"
done
