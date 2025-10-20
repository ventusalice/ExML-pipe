#!/bin/bash

mkdir ./annout

for file in $(ls ./annvar/*.cns); do
  bash ../src/rename_cns.sh $file ../src/substitution_table.tsv ${file%.cns}.chr.cns
  mv $file $file.old
  mv ${file%.cns}.chr.cns $file
  awk 'NR>1 {if ($6 > 2) type="DUP"; else if ($6 < 2) type="DEL"; else next; print $1"\t"$2"\t"$3"\t"type}' \
  $file > ${file%.cns}.bed;
  done

for file in $(ls ./annvar/*bed); do
	python ../bin/ClassifyCNV/ClassifyCNV.py --infile $file --GenomeBuild hg38 --cores 28 --outdir ./annout/$(basename $file .bed)
	python ../src/af_cnv.py -v ../ref/gnomad.v4.1.cnv.all.vcf.gz -i ./annout/$(basename $file .bed)/Scoresheet.txt -o ./annout/$(basename $file .bed)/cnv.txt
done
