process VARCAP_STATS_VARIANT_FREQUENCY {
    publishDir "$params.DEFAULT.outdir/varcap/stats", mode: 'copy'
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(tags_vcf)

    output:
        tuple val(sample_id), path("${sample_id}_frequency.pdf"), emit: frequency_pdf

    script:
        """
        cat ${tags_vcf} | \
            grep -e SNP | grep -Ev '^#|REP|CV1' | grep -Ev 'samtools|gatk|cortex' | \
            awk '{ split(\$10, pct, ":"); print \$1"\\t"\$2"\\t"pct[3]"\\t"pct[4] }' | \
            sort -un -k2,2 >${sample_id}_pct_hist.txt

        sed -i '1ichrom\tpos\tcov\tfreq' ${sample_id}_pct_hist.txt

        Rscript /app_home/custom_R/varcap_stats_hist.R \
            --sample_id ${sample_id} \
            --input_file ${sample_id}_pct_hist.txt
        mv Rplots.pdf ${sample_id}_frequency.pdf
        """
}
