process LOFREQ_CALL {
    publishDir "$params.DEFAULT.outdir/variant_calling/lofreq", mode: 'copy'
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.lofreq_call.cluster_cpus
    memory params.lofreq_call.cluster_memory
    time params.lofreq_call.cluster_time

    input:
        path(reference_fna)
        tuple val(sample_id), path(lofreq_bam)

    output:
        tuple val(sample_id), path("${sample_id}_lofreq.vcf"), emit: lofreq_vcf

    script:
        """
        lofreq call \\
            --call-indels \\
            --min-cov ${params.lofreq_call.min_coverage} \\
            -f ${reference_fna} \\
            -o ${sample_id}_lofreq.vcf \\
            ${lofreq_bam}
        """
}
