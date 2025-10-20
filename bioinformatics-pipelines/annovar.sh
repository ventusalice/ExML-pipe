mkdir ./annout
for file in $(ls ./annvar/*.vcf); do perl ../bin/annovar/table_annovar.pl $file ../bin/annovar/humandb/ -buildver hg38 -out ./annout/$(basename $file .vcf) -remove -protocol refGene,clinvar_20250721,intervar_20250721,gnomad41_exome,dbnsfp47a,avsnp151 -operation g,f,f,f,f,f -nastring . -vcfinput -thread 28 -polish; done
