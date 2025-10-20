for file in ./variant/*.indels.filtered.vcf; do
	bcftools view -v indels $file | \
	bcftools view -i 'abs(strlen(REF) - strlen(ALT)) == 1' -Ov -o ${file%.indels.filtered.vcf}.sids.filtered.vcf
done

for file in ./variant/*.indels.filtered.vcf; do
	bcftools view -v indels $file | \
	bcftools view -i 'abs(strlen(REF) - strlen(ALT)) > 1' -Ov -o ${file%.indels.filtered.vcf}.largeids.filtered.vcf;
done

for file in ./variant/*{snps,sids,largeids}.filtered.vcf; do
	bcftools annotate --rename-chrs ../src/substitution_table.tsv $file -Ov -o ${file%.vcf}.chr.vcf;
done

#for sample_bam in ./aligned/*.bam; do
#	sample=$(basename $sample_bam .bam);
#	for type in snps sids largeids; do
#		for file in ./variant/${sample}*{fb,dv,gatk}.${type}.filtered.chr.vcf ; do 
#			bcftools annotate --rename-chrs ../src/substitution_table.tsv $file -Ov -o ${file%.vcf}.chr.vcf;
#		done;
#	done;
#done

##Compress and index
for sample_bam in ./aligned/*.bam; do sample=$(basename $sample_bam .bam);
	for type in snps sids largeids; do
		bgzip -f ./variant/${sample}.{dv,fb,gatk}.${type}.filtered.chr.vcf;
		bcftools index ./variant/${sample}.fb.${type}.filtered.chr.vcf.gz;
		bcftools index ./variant/${sample}.gatk.${type}.filtered.chr.vcf.gz;
		bcftools index ./variant/${sample}.dv.${type}.filtered.chr.vcf.gz;
		bcftools isec -n+2 -w1 -Ov -p ./variant/${sample}.${type}.vcf ./variant/${sample}.{dv,fb,gatk}.${type}.filtered.chr.vcf.gz;
	done;
done

#compress and index snps ans sids
mkdir ./annvar

for dir in $(ls -d ./variant/*.snps.vcf); do
	bgzip -f $dir/0000.vcf ${dir%.snps.vcf}.sids.vcf/0000.vcf;
	bcftools index $dir/0000.vcf.gz;
	bcftools index ${dir%.snps.vcf}.sids.vcf/0000.vcf.gz;
	bcftools concat -a -Ov -o ./annvar/$(basename $dir) $dir/0000.vcf.gz ${dir%.snps.vcf}.sids.vcf/0000.vcf.gz;
done

for dir in $(ls -d ./variant/*.largeids.vcf); do cp $dir/0000.vcf ./annvar/$(basename $dir .largeids.vcf).indels.vcf; done
