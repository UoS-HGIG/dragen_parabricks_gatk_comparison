#where $1 is sampleID

REF=GRCh38_full_analysis_set_plus_decoy_hla.fa
java -Xmx64G -jar gatk-package-4.6.1.0-local.jar HaplotypeCaller \
        -R $REF \
        -I ${1}_bwa07.GATK.recal.bam \
        -O ${1}_GATK.vcf.gz \
        --native-pair-hmm-threads 8 \
        --dont-use-soft-clipped-bases
