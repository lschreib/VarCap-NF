process VARSCAN_PILEUP2INDEL {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.varscan_pileup2indel.cluster_cpus
    memory params.varscan_pileup2indel.cluster_memory
    time params.varscan_pileup2indel.cluster_time

    input:
        tuple val(sample_id), path(mpileup_file)

    output:
        tuple val(sample_id), path("${sample_id}.varscan_tmp.indel"), emit: varscan_indel_tmp

    script:
        """
        java \\
            -XX:-UsePerfData \\
            -Xmx${params.varscan_pileup2indel.java_xmx} \\
            -jar /app_home/varscan2/VarScan.jar \\
            pileup2indel ${mpileup_file} \\
            --min-var-freq ${params.varscan_pileup2indel.min_var_freq} \\
            > ${sample_id}.varscan_tmp.indel
        """
}
