process PREPARE_REFERENCE {
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
        path(reference_genbank)

    output:
        path("reference.fna"), emit: reference_fasta
        path("reference.gff3"), emit: reference_gff3
        path("reference_genbank.log"), emit: conversion_log

    script:
        """
        genbank_to -g ${reference_genbank} -n reference.fna --gff3 reference.gff3 --log reference_genbank.log
        """
}
