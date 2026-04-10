process VARCAP_CALCULATE_COVERAGE {
    publishDir "$params.DEFAULT.outdir/varcap/coverage", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(vcf_file), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}_cov.vcf"), emit: vcf_with_cov
        tuple val(sample_id), path("${sample_id}_cov_total.txt"), emit: cov_total

    script:
        """
        echo "VARCAP: calculate average coverage per chromosome/contig"
        samtools depth ${bam_file} | awk 'NR%500==0' >${sample_id}_cov_total.txt
        cat ${sample_id}_cov_total.txt | \
            awk '{ a[\$1]+=\$3; b[\$1]=NR; next } END {for(i in a) { av_cov=(a[i]/b[i]); print i"\t"av_cov } }' \
            >${sample_id}_cov_av.txt

        echo "VARCAP: update total coverage for variant positions"
        echo "Get coverages for positions"
        grep -v '#' ${vcf_file} | cut -f 1,2 >pos_${sample_id}.bed
        samtools depth -b pos_${sample_id}.bed ${bam_file} >${sample_id}_cov_pos.txt
        echo "${sample_id}: update file"
        perl -I /app_home/VarCap/scripts/vcffilter \
            /app_home/VarCap/scripts/vcffilter/get_coverage_2vcf2.pl \
            "${vcf_file}" "${sample_id}_cov_pos.txt" "${sample_id}_cov_av.txt" \
            >${sample_id}_cov.vcf
        """
}
