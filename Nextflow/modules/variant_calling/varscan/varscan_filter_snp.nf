process VARSCAN_FILTER_SNP {
    publishDir "$params.DEFAULT.outdir/variant_calling/varscan", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.varscan_filter_snp.cluster_cpus
    memory params.varscan_filter_snp.cluster_memory
    time params.varscan_filter_snp.cluster_time

    input:
        tuple val(sample_id), path(varscan_snp_tmp), path(varscan_indel_filtered)

    output:
        tuple val(sample_id), path("${sample_id}.varscan_filter.snp"), emit: varscan_snp_filtered

    script:
        """
        java \\
            -XX:-UsePerfData \\
            -Xmx${params.varscan_filter_snp.java_xmx} \\
            -jar /app_home/varscan2/VarScan.jar \\
            filter ${varscan_snp_tmp} \\
            --min-avg-qual ${params.varscan_filter_snp.min_avg_qual} \\
            --min-var-freq ${params.varscan_filter_snp.min_var_freq} \\
            --min-strands2 ${params.varscan_filter_snp.min_strands2} \\
            --indel-file ${varscan_indel_filtered} \\
            --output-file ${sample_id}.varscan_filter.snp
        """
}
