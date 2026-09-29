REF=GRCh38_full_analysis_set_plus_decoy_hla.fa
DBSITES=common_dbsnp_151.hg38.vcf
bwa mem \
        -K 10000000 \
        -M \
        -R '@RG\tID:'${1}'_lane1\tSM:'${1}'\tPL:ILLUMINA\tLB:Library' \
        $REF \
        ${1}_R1.fq.gz ${1}_R2.fq.gz \
        -t 8 \
        >${1}_bwa07.aligned.sam
