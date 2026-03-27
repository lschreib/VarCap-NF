process SAMTOOLS_MPILEUP {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_mpileup.cluster_cpus
    memory params.samtools_mpileup.cluster_memory
    time params.samtools_mpileup.cluster_time

    input:
        path(reference_fasta)
        tuple val(sample_id), path(sorted_bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.mpileup"), emit: mpileup_output
    script:
        """
        samtools mpileup \\
            -C ${params.samtools_mpileup.adjust_mq} \\
            -d ${params.samtools_mpileup.max_depth} \\
            -E \\
            -f ${reference_fasta} \\
            -o ${sample_id}.mpileup \\
            ${sorted_bam_file}
        """
}
