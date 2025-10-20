job_limit=4
for name in $(ls ./aligned/*.bam | while read bam; do bai="${bam%.bam}.bai"; [ ! -f "$bai" ] && echo "$bam"; done); do #$(ls ./aligned/*.bam); do
	while [ "$(jobs -rp | wc -l)" -ge "$job_limit" ]; do
        	sleep 1
    	done
	$(java -jar ../bin/picard.jar SortSam \
  		INPUT=$name \
  		OUTPUT=${name%.bam}.sorted.bam \
  		SORT_ORDER=coordinate \
  		CREATE_INDEX=true &&
	java -jar ../bin/picard.jar MarkDuplicates \
  		INPUT=${name%.bam}.sorted.bam \
  		OUTPUT=${name%.bam}.dedup.bam \
  		METRICS_FILE=dup_metrics.txt \
  		CREATE_INDEX=true
		OPTICAL_DUPLICATE_PIXEL_DISTANCE=0 &&
	mv ${name%.bam}.dedup.bam $name; rm ${name%.bam}.sorted.bam;
	mv ${name%.bam}.dedup.bai ${name%.bam}.bai; rm ${name%.bam}.sorted.bai
	) &
done
wait
