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
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${bam_file.baseName}.bai"), emit: index_output
    script:
        """
        samtools index ${bam_file} ${bam_file.baseName}.bai
        """
}
