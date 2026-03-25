process MULTIQC {
    publishDir "$params.DEFAULT.outdir/qced_reads/", mode: 'copy'
    //debug true
    maxForks 1
    errorStrategy 'finish'
    scratch false
	cleanup true
    cpus params.multiqc.cluster_cpus
    memory params.multiqc.cluster_memory
    time params.multiqc.cluster_time

    input:
        path(zip_files)
        val(prefix)

    output:
        path("*_multiqc_report.html"), emit: multiqc_out

    script:
    """
    multiqc *_fastqc.zip -n ${prefix}_multiqc_report.html
    """
}