#!/bin/bash
threads=28
REFERENCE="GCF_000001405.40_GRCh38.p14_genomic.fna"
TARGET_BED="CoreExomePanel.hg38.p12.target.v3_ncbi.bed"

mkdir ./variant

for name in $(ls ./aligned/*.bam); do
	
	shortname=$(basename $name)

	docker run --rm \
		-v "./aligned":/input \
  		-v "./variant":/output \
		-v "../src/WES_bed_file":/bed \
		-v "../ref":/ref \
  		google/deepvariant:latest \
  		/opt/deepvariant/bin/run_deepvariant \
  		--model_type=WES \
  		--ref=/ref/${REFERENCE} \
  		--reads=/input/$shortname \
  		--output_vcf=/output/${shortname%.bam}.dv.raw.vcf \
  		--regions=/bed/${TARGET_BED} \
  		--num_shards=$threads

	bcftools filter --threads $threads -e 'QUAL < 20 || FORMAT/DP < 10' -O v -o ./variant/${shortname%.bam}.dv.all.filtered.vcf ./variant/${shortname%.bam}.dv.raw.vcf
	bcftools view --threads $threads -v snps -o ./variant/${shortname%.bam}.dv.snps.filtered.vcf ./variant/${shortname%.bam}.dv.all.filtered.vcf
	bcftools view --threads $threads -v indels -o ./variant/${shortname%.bam}.dv.indels.filtered.vcf ./variant/${shortname%.bam}.dv.all.filtered.vcf
	
done
wait
