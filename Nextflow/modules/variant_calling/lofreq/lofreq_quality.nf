process LOFREQ_QUALITY {
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.lofreq_quality.cluster_cpus
    memory params.lofreq_quality.cluster_memory
    time params.lofreq_quality.cluster_time

    input:
        path(reference_fna)
        tuple val(sample_id), path(bam)

    output:
        tuple val(sample_id), path("${sample_id}_lofreq.bam"), emit: lofreq_bam

    script:
        """
        lofreq indelqual \\
            --dindel \\
            -f ${reference_fna} \\
            -o ${sample_id}_lofreq.bam ${bam}
        """
}
