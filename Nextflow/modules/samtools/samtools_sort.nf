process SAMTOOLS_SORT {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_sort.cluster_cpus
    memory params.samtools_sort.cluster_memory
    time params.samtools_sort.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.sorted.bam"), emit: sorted_bam
    script:
        """
        samtools sort ${bam_file} -o ${sample_id}.sorted.bam
        """
}
