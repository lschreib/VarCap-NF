process VARCAP_STATS_COVERAGE {
    publishDir "$params.DEFAULT.outdir/varcap/stats", mode: 'copy'
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(tags_vcf), path(cov_total_txt)

    output:
        tuple val(sample_id), path("${sample_id}_coverages.pdf"), emit: coverage_pdf

    script:
        """
        # get SNP coverage
        cat ${tags_vcf} | \
            grep -e 'SNP' | grep -Ev 'REP|CV1' | grep -Ev '^#|samtools|gatk|cortex' | \
            awk '{ split(\$10, pct, ":"); print \$1"\\t"\$2"\\t"pct[1]"\\t"pct[3]"\\t"pct[4] }' \
            >cov_snp_2.txt

        # get InDel/SV-small coverage
        cat ${tags_vcf} | \
            grep -E 'DEL|INS|IND' | grep -E 'SVLEN=[-]{0,1}[0-9]{1}\\W' | \
            grep -Ev 'REP|CV1' | grep -Ev '^#|samtools|gatk|cortex' | \
            awk '{ split(\$10, pct, ":"); print \$1"\\t"\$2"\\t"pct[1]"\\t"pct[3]"\\t"pct[4] }' \
            >cov_indelsmall_2.txt

        # get SV coverage
        cat ${tags_vcf} | \
            grep -E 'DEL|INS|INV|DUP|ITX|CTX|LI|COMPLEX' | \
            grep -Ev 'SVLEN=[-]{0,1}[0-9]{1}\\W' | grep -Ev 'REP|CV1' | \
            awk '{ split(\$10, pct, ":"); print \$1"\\t"\$2"\\t"pct[1]"\\t"pct[3]"\\t"pct[4] }' \
            >cov_sv_2.txt

        # get BP coverage
        cat ${tags_vcf} | \
            grep -E 'SVTYPE=BP' | \
            awk '{ split(\$10, pct, ":"); print \$1"\\t"\$2"\\t"pct[1]"\\t"pct[3]"\\t"pct[4] }' \
            >cov_bp_2.txt

        Rscript /app_home/custom_R/varcap_stats_cov.R \
            --sample_id ${sample_id} \
            --cov_total ${cov_total_txt} \
            --cov_snp cov_snp_2.txt \
            --cov_indel cov_indelsmall_2.txt \
            --cov_sv cov_sv_2.txt \
            --cov_bp cov_bp_2.txt
        mv Rplots.pdf ${sample_id}_coverages.pdf
        """
}
