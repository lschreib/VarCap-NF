process PINDEL2VCF_ALL {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.pindel2vcf.cluster_cpus
    memory params.pindel2vcf.cluster_memory
    time params.pindel2vcf.cluster_time

    input:
        tuple val(sample_id), path(mpileup_file)

    output:
        tuple val(sample_id), path("${sample_id}.varscan_tmp.snp"), emit: varscan_snp_tmp

    script:
        """
        java \\
            -XX:-UsePerfData \\
            -Xmx${params.varscan_pileup2snp.java_xmx} \\
            -jar /app_home/varscan2/VarScan.jar \\
            pileup2snp ${mpileup_file} \\
            --min-var-freq ${params.varscan_pileup2snp.min_var_freq} \\
            > ${sample_id}.varscan_tmp.snp
        """
}
