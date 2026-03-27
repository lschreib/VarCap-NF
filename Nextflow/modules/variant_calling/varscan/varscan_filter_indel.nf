process VARSCAN_FILTER_INDEL {
    publishDir "$params.DEFAULT.outdir/variant_calling/varscan", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.varscan_filter_indel.cluster_cpus
    memory params.varscan_filter_indel.cluster_memory
    time params.varscan_filter_indel.cluster_time

    input:
        tuple val(sample_id), path(varscan_indel_tmp)

    output:
        tuple val(sample_id), path("${sample_id}.varscan_filter.indel"), emit: varscan_indel_filtered

    script:
        """
        java \\
            -XX:-UsePerfData \\
            -Xmx${params.varscan_filter_indel.java_xmx} \\
            -jar /app_home/varscan2/VarScan.jar \\
            filter ${varscan_indel_tmp} \\
            --min-avg-qual ${params.varscan_filter_indel.min_avg_qual} \\
            --min-var-freq ${params.varscan_filter_indel.min_var_freq} \\
            --output-file ${sample_id}.varscan_filter.indel
        """
}
