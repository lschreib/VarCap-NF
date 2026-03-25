process FASTQC {
    publishDir "$params.DEFAULT.outdir/qced_reads/fastqc/fastqc_${sample}_${prefix}", mode: 'copy'
    maxForks 1
    errorStrategy 'finish'
    scratch false
    cpus params.fastqc.cluster_cpus
    memory params.fastqc.cluster_memory
    time params.fastqc.cluster_time

    input:
        tuple val(sample), path(reads)
        val(prefix)

    output:
        path("*_fastqc.html"), emit: fastqc_out_html
        path("*_fastqc.zip"), emit: fastqc_out_zip

    script:
    """
    fastqc --threads 1 ${reads}
    """
}