#! /bin/bash
bash ../src/trim_script.sh
fastqc -t 28 ./trimmed/* -o ./fastqc_trimmed ; cd fastqc_trimmed; multiqc .; cd ..
bash ../src/align.sh
bash ../src/sort_dedup.sh
bash ../src/freebayes.sh
bash ../src/gatk.sh
bash ../src/dv.sh
bash ../src/vcf_sorcery.sh
bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate cnvkit && source ../src/cnv_ck.sh && conda deactivate"
bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate pysam && source ../src/classify_cnv.sh && conda deactivate"
bash ../src/annovar.sh
bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate tapes && source ../src/tapes.sh && conda deactivate"
bash ../src/finalize.sh
