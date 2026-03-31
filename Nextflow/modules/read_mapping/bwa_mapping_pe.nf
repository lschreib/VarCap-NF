process BWA_MAPPING_PE {
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
        tuple val(sample_id), path(reads_P1), path(reads_P2)

    output:
        tuple val(sample_id), path("${sample_id}.pe.sam"), emit: sam_output_pe

    script:
        """
        bwa-mem2 mem \\
            -t ${params.bwa_mapping.cluster_cpus} \\
            -o ${sample_id}.pe.sam \\
            reference.fna \\
            ${reads_P1} ${reads_P2}
        """
}
