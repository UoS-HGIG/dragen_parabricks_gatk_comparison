#where $1 is sampleID 
#$2 is GPU card

apptainer exec --fakeroot --nv --bind $(pwd):/workdir,$(pwd):/outputdir clara-parabricks_4.6.0-1.sif \
          pbrun fq2bam \
               --ref /workdir/GRCh38_full_analysis_set_plus_decoy_hla.fa \
               --bwa-options="-M -K 10000000" \
               --in-fq /workdir/${1}_R1.fq.gz /workdir/${1}_R2.fq.gz '@RG\tID:'$1'_lane1\tSM:'$1'\tPL:ILLUMINA\tLB:Library\tPU:${1}' \
               --knownSites /workdir/common_dbsnp_151.hg38.vcf \
               --out-recal-file /workdir/${1}_recal_pb_{$}2 \
               --out-duplicate-metrics /workdir/${1}_dup_pb_{$}2 \
               --fix-mate \
               --logfile /workdir/${1}_slurm_log_{$}2 \
               --out-bam /workdir/${1}_pb_{$}2.bam \
               --verbose
