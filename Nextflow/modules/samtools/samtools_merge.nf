process SAMTOOLS_MERGE {
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
        tuple val(sample_id), path(sam_pe), path(sam_se)

    output:
        tuple val(sample_id), path("${sample_id}.merged.bam"), emit: merged_bam
    
    script:
        """
        samtools merge \\
            -f \\
            -o ${sample_id}.merged.bam \\
            ${sam_pe} ${sam_se}
        """
}
