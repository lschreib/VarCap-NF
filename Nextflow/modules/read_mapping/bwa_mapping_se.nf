process BWA_MAPPING_SE {
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
        tuple val(sample_id), path("${sample_id}.se.sam"), emit: sam_output_se

    script:
        """
        bwa-mem2 mem \\
            -t ${params.bwa_mapping.cluster_cpus} \\
            -o ${sample_id}.se.sam \\
            reference.fna \\
            ${reads}
        """
}
