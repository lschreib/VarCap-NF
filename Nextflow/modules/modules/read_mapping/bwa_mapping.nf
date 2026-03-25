process BWA_MAPPING {
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.bwa_mapping.cluster_cpus
    memory params.bwa_mapping.cluster_memory
    time params.bwa_mapping.cluster_time

    input:
        path(reference_index)
        tuple val(sample_id), path(reads)

    output:
        path("${sample_id}.sam"), emit: sam_output

    script:
        """
        bwa-mem2 mem -p \
            -t ${params.bwa_mapping.cluster_cpus} \
            ${reference_index} \
            ${reads} > ${sample_id}.sam
        """
}