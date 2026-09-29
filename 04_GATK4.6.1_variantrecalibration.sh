#where $1 is sampleID
OMNI=resources_broad_hg38_v0_1000G_omni2.5.hg38.vcf
ONE_THOUSAND=resources_broad_hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf
DBSNP=resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
MILLS=resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf
HAPMAP=resources_broad_hg38_v0_hapmap_3.3.hg38.vcf.gz
AXIOM=Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

gatk --java-options "-Xmx64G" MakeSitesOnlyVcf \
     --INPUT ${1}.vcf.gz \
     --OUTPUT ${1}.sitesOnly.sorted.vcf.gz
gatk --java-options "-Xmx64g" \
     VariantRecalibrator \
     -V ${1}.sitesOnly.sorted.vcf.gz \
     -O ${1}.sitesOnly.indel.recal \
     --tranches-file ${1}.sitesOnly.indel.tranches \
     --rscript-file ${1}.sitesOnly.indel.R \
     --dont-run-rscript \
     --trust-all-polymorphic \
     -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
     -tranche 100 -tranche 99.9 -tranche 99.0 -tranche 95.0 \
     -mode INDEL \
     -resource:mills,known=false,training=true,truth=true,prior=12 $48 \
     -resource:axiomPoly,known=false,training=true,truth=false,prior=10 ${AXIOM} \
     -resource:dbsnp,known=true,training=false,truth=false,prior=2 ${DBSNP}
gatk --java-options "-Xmx64g" \
     VariantRecalibrator \
     -V ${1}.sitesOnly.sorted.vcf.gz \
     -O ${1}.sitesOnly.snp.recal \
     --rscript-file ${1}.sitesOnly.snp.R \
     --dont-run-rscript \
     --tranches-file ${1}.sitesOnly.snp.tranches \
     --trust-all-polymorphic \
     -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
     -tranche 100 -tranche 99.9 -tranche 99.0 -tranche 95.0 \
     -mode SNP \
     -resource:hapmap,known=false,training=true,truth=true,prior=15 $19 \
     -resource:omni,known=false,training=true,truth=true,prior=12 ${OMNI} \
     -resource:1000G,known=false,training=true,truth=false,prior=10 ${ONE_THOUSAND} \
     -resource:dbsnp,known=true,training=false,truth=false,prior=7 ${DBSNP}

gatk --java-options "-Xmx64g" \
        ApplyVQSR \
            -O tmp.indel.recalibrated.vcf \
                -V ${1}.vcf.gz \
                    --recal-file ${1}.sitesOnly.indel.recal \
                        --tranches-file ${1}.sitesOnly.indel.tranches \
                            --truth-sensitivity-filter-level 99.0 \
                                --create-output-variant-index true \
                                    -mode INDEL

gatk --java-options "-Xmx64g" \
        ApplyVQSR \
            -V tmp.indel.recalibrated.vcf \
                -O ${1}.recalibrated.vcf.gz \
                    --recal-file ${1}.sitesOnly.snp.recal \
                        --tranches-file ${1}.sitesOnly.snp.tranches \
                            --truth-sensitivity-filter-level 99.0 \
                                --create-output-variant-index true \
                                    -mode SNP

bcftools view -f PASS -e 'GQ<20 | FMT/DP<8 | GT="./."' $1.vcf.gz -Oz -o $1_trimmed.vcf.gz

