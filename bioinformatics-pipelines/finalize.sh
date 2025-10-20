
#! /bin/bash
mkdir ./final
#Rework files to spec
#for file in $(ls -d ./annout/*.{snps,indels}/{snps,indels}/{snps,indels}.txt); do python ../src/rework_txt.py -i ${file} -o ${file%.txt}.reworked.txt; done


for file in $(ls ./aligned/*.bam); do
	sample=$(basename $file .bam);
	cp ./annout/${sample}.snps/snps/snps.reworked.txt ./final/${sample}_snv.tsv;
        cp ./annout/${sample}.indels/indels/indels.reworked.txt ./final/${sample}_lid.tsv;
        cp ./annout/${sample}/cnv.txt ./final/${sample}_cnv.tsv;
done

#for file in ./final/SRR*_{snv,lid}.tsv; do sed -i 's#\./trimmed/\([^/]*\)\.fastq#\1#g' $file; done
bash ../src/subfinal.sh

for file in $(ls ./aligned/*.bam); do
        $(sample=$(basename $file .bam);
 	python ../src/combiner.py \
	-f1 ./final/${sample}_snv.tsv\
	-f2 ./final/${sample}_lid.tsv\
	-f3 ./final/${sample}_cnv.tsv\
	-o ./final/${sample}.xlsx) &
done
wait
#Copy other files
#cp ./aligned/* ./final
echo "Done!"
