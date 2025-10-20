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
    gatk -Xmx8g HaplotypeCaller \
        -R "$REFERENCE" \
        -I "$name" \
        -O "./variant/${shortname%.bam}.gatk.raw.vcf" \
        -L "$TARGET_BED" \
        --native-pair-hmm-threads $threads \
        --standard-min-confidence-threshold-for-calling 10

    bcftools filter --threads $threads -e 'QUAL < 20 || INFO/DP < 10' -O v -o "./variant/${shortname%.bam}.gatk.all.filtered.vcf" "./variant/${shortname%.bam}.gatk.raw.vcf"
    bcftools view --threads $threads -v snps -o "./variant/${shortname%.bam}.gatk.snps.filtered.vcf" "./variant/${shortname%.bam}.gatk.all.filtered.vcf"
    bcftools view --threads $threads -v indels -o "./variant/${shortname%.bam}.gatk.indels.filtered.vcf" "./variant/${shortname%.bam}.gatk.all.filtered.vcf"
    ) &
    pids+=($!)

    # If max jobs reached, wait for all to finish and reset
    if [ ${#pids[@]} -ge $max_jobs ]; then
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
        pids=()
    fi
done

# Wait for any remaining jobs
for pid in "${pids[@]}"; do
    wait "$pid"
done
