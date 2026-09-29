# $1 is sampleID
# $2 is GPU
apptainer exec --fakeroot --nv --bind $(pwd):/workdir --bind $(pwd):/outputdir clara-parabricks_4.6.0-1.sif \
        pbrun haplotypecaller \
                --ref /workdir/GRCh38_full_analysis_set_plus_decoy_hla.fa \
                --in-recal-file /workdir/${1}_recal_pb_{$}2 \
                --in-bam /workdir/${1}_pb__{$}2.bam \
                --dont-use-soft-clipped-bases \
                --out-variants /outputdir/${1}_${2}_pb.vcf.gz
