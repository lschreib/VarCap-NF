process BWA_BUILD_INDEX {
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.bwa_index.cluster_cpus
    memory params.bwa_index.cluster_memory
    time params.bwa_index.cluster_time

    input:
        path(reference_fasta)

    output:
        path("${reference_fasta}.*"), emit: reference_index
    script:
        """
        bwa-mem2 index ${reference_fasta}
        """
}