process INDEX_REFERENCE {
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
        path(reference_fasta)

    output:
        path("reference.fna.fai"), emit: reference_index

    script:
        """
        samtools faidx -o reference.fna.fai ${reference_fasta}
        """
}
