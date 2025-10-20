#!/bin/bash

#BAM="./aligned/100.bam"
TARGET_BED="../src/WES_bed_file/CoreExomePanel.hg38.p12.target.v3_ncbi.bed"
REFERENCE_FASTA="../ref/GCF_000001405.40_GRCh38.p14_genomic.fna"
#OUTPUT_DIR="./cnv/ck"
ACCESS_FILE="../ref/access_nc.bed"
mkdir -p ./cnv/ck
mkdir ./annvar
for file in ./aligned/*.bam; do
$(
BAM=$file
OUTPUT_DIR="./cnv/ck/$(basename $file .bam)"
mkdir $OUTPUT_DIR

# Step 1: Create targets (already done)
cnvkit.py target $TARGET_BED -o $OUTPUT_DIR/targets.bed

# Step 2: Create antitargets (off-target regions, required for normalization)
cnvkit.py antitarget $TARGET_BED -g $ACCESS_FILE -o $OUTPUT_DIR/antitargets.bed

# Step 3: Build reference from normal/control samples (or create flat reference)
cnvkit.py reference -f $REFERENCE_FASTA -t $OUTPUT_DIR/targets.bed -a $OUTPUT_DIR/antitargets.bed -o $OUTPUT_DIR/reference.cnn

# Step 4: Calculate coverage for target and antitarget regions separately
cnvkit.py coverage $BAM $OUTPUT_DIR/targets.bed -o $OUTPUT_DIR/sample.targetcoverage.cnn
cnvkit.py coverage $BAM $OUTPUT_DIR/antitargets.bed -o $OUTPUT_DIR/sample.antitargetcoverage.cnn

# Step 5: Fix coverage by normalizing with reference
cnvkit.py fix $OUTPUT_DIR/sample.targetcoverage.cnn $OUTPUT_DIR/sample.antitargetcoverage.cnn $OUTPUT_DIR/reference.cnn -o $OUTPUT_DIR/sample.cnr


# Step 6: Segment the copy number ratios
cnvkit.py segment $OUTPUT_DIR/sample.cnr -o $OUTPUT_DIR/sample.cns

# Step 7: Call CNVs
cnvkit.py segmetrics $OUTPUT_DIR/sample.cnr -s $OUTPUT_DIR/sample.cns --drop-low-coverage --ci --sem -o $OUTPUT_DIR/sample.segmetrics.cns
cnvkit.py call $OUTPUT_DIR/sample.segmetrics.cns --drop-low-coverage --filter ci -o $OUTPUT_DIR/sample.call.cns.ci
cnvkit.py call $OUTPUT_DIR/sample.segmetrics.cns --drop-low-coverage --filter cn -o $OUTPUT_DIR/sample.call.cns.cn
cnvkit.py call $OUTPUT_DIR/sample.segmetrics.cns --drop-low-coverage --filter sem -o $OUTPUT_DIR/sample.call.cns.sem

#Step 8: Combine CNVs
python ../src/combine_cnvkit_filters.py --input_ci $OUTPUT_DIR/sample.call.cns.ci --input_cn $OUTPUT_DIR/sample.call.cns.cn --input_sem $OUTPUT_DIR/sample.call.cns.sem --output $OUTPUT_DIR/sample.call.cns
cp $OUTPUT_DIR/sample.call.cns ./annvar/$(basename $file .bam).cns
) &
done
wait
echo "CNVkit pipeline complete. Output files in $OUTPUT_DIR"
