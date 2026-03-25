process COMBINE_READS {
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_idP), path(reads_P1), path(reads_P2)
        tuple val(sample_idS), path(reads_S)

    output:
        tuple val(sample_idP), path("${sample_idP}_merged.fastq.gz"), emit: merged_reads

    script:
        """
        # Interleave paired reads
        /app_home/seqtk/seqtk mergepe ${reads_P1} ${reads_P2} > ${sample_idP}_merged.fastq && \\
        # Combine with single reads and compress
        zcat ${reads_S} >> ${sample_idP}_merged.fastq && \\
        pigz ${sample_idP}_merged.fastq
        """
}
