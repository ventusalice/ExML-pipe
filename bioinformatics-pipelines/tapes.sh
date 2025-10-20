for file in $(ls ./annout/*.snps.hg38_multianno.vcf); do
        mkdir ./annout/$(basename $file .hg38_multianno.vcf);
	mkdir ./annout/$(basename $file .hg38_multianno.vcf)/snps;
        python ../bin/tapes/tapes.py sort --ref_anno refGene --by_gene -i ./annout/$(basename $file .hg38_multianno.vcf).hg38_multianno.vcf \
	-o ./annout/$(basename $file .hg38_multianno.vcf)/snps/ --tab -t 28;
done

for file in $(ls ./annout/*.indels.hg38_multianno.vcf); do
	mkdir ./annout/$(basename $file .hg38_multianno.vcf);
	mkdir ./annout/$(basename $file .hg38_multianno.vcf)/indels;
	python ../bin/tapes/tapes.py sort --ref_anno refGene --by_gene -i ./annout/$(basename $file .hg38_multianno.vcf).hg38_multianno.vcf \
	 -o ./annout/$(basename $file .hg38_multianno.vcf)/indels/ --tab -t 28;
done
