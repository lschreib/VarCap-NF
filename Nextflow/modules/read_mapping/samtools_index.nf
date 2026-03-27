process SAMTOOLS_INDEX {
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_index.cluster_cpus
    memory params.samtools_index.cluster_memory
    time params.samtools_index.cluster_time

    input:
        tuple val(sample_id), path(sam_file)

    output:
        tuple val(sample_id), path("${sample_id}.bai"), emit: index_output
    script:
        """
        samtools index ${sample_id}.bam ${sample_id}.bai
        """
}
