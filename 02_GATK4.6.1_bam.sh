#where $1 is sample ID

samtools view -T $REF -bS -o ${1}_bwa07_aligned.bam ${1}_bwa07.aligned.sam
java -Xmx32G -jar gatk-package-4.6.1.0-local.jar SortSam \
        INPUT=${1}_bwa07_aligned.bam \
        OUTPUT=${1}_bwa07_aligned_sorted.bam \
        SORT_ORDER=coordinate \
        TMP_DIR=tmp1 \
        VALIDATION_STRINGENCY=SILENT \
        MAX_RECORDS_IN_RAM=2500000

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar MarkDuplicates \
        INPUT=${1}_bwa07_aligned_sorted.bam \
        METRICS_FILE=${1}_bwa07_dup_metrics \
        OUTPUT=${1}_bwa07_marked_dups_sorted.bam \
        TMP_DIR=tmp1 \
        VALIDATION_STRINGENCY=SILENT \
        MAX_RECORDS_IN_RAM=2500000

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar SortSam \
        INPUT=${1}_bwa07_marked_dups_sorted.bam \
        OUTPUT=${1}_bwa07.DelDup.bam \
        SORT_ORDER=coordinate \
        TMP_DIR=tmp2 \
        VALIDATION_STRINGENCY=SILENT \
        MAX_RECORDS_IN_RAM=2500000

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar BuildBamIndex \
        INPUT=${1}_bwa07.DelDup.bam \
        TMP_DIR=tmp3 \
        VALIDATION_STRINGENCY=SILENT

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar FixMateInformation \
        INPUT=${1}_bwa07.DelDup.bam \
        OUTPUT=${1}_bwa07.GATK.fixedmateinfo.bam \
        SORT_ORDER=coordinate \
        TMP_DIR=tmp3 \
        VALIDATION_STRINGENCY=SILENT \
        MAX_RECORDS_IN_RAM=500000 \
        CREATE_INDEX=true

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar BaseRecalibrator \
        -I ${1}_bwa07.GATK.fixedmateinfo.bam \
        -R $REF \
        --known-sites $DBSITES \
        -O ${1}_bwa07.recal_data.table

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar ApplyBQSR \
        -R $REF \
        -I ${1}_bwa07.GATK.fixedmateinfo.bam \
        --bqsr-recal-file ${1}_bwa07.recal_data.table \
        -O ${1}_bwa07.GATK.recal.bam \

java -Xmx32G -jar gatk-package-4.6.1.0-local.jar AddOrReplaceReadGroups \
    CREATE_INDEX=true \
    I=${1}_bwa07.GATK.recal.bam \
    O=${1}_bwa07.GATK.recal.reh.bam \
    RGID=99 \
    RGLB=wgs \
    RGPL=ILLUMINA \
    RGPU=wgs \
    RGSM=$1\
    RGDS=GIBD
