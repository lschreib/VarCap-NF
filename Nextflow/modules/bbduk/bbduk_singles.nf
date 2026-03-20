process BBDUK_SINGLES {
    publishDir "$params.DEFAULT.outdir/qced_reads/", mode: 'copy'
    debug true
    //All Java-based steps have problems with parallelization because they will all use the same temporary directory
    //which fills up quickly when many processes are run at the same time, we therefore set these steps to "sequential"
    //mode by using the maxForks command
    maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.bbduk.cluster_cpus
    memory params.bbduk.cluster_memory
    time params.bbduk.cluster_time

    input:
        tuple val(sample_id), path(infile_SE1), path(infile_SE2)

    output:
        tuple val(sample_id), path("${sample_id}_singles_ncontam.fastq.gz"), emit: single_reads
        path("${sample_id}_bbduk_log.txt"), emit: log

    script:
        """
        {
            gzip -cd ${infile_SE1} | awk '1' ; \\
            gzip -cd ${infile_SE2} | awk '1' ; \\
        } | gzip -c > ${sample_id}_singles.fastq.gz && \\
        /bbmap/bbduk.sh \\
            -Xmx1g \\
            in=${sample_id}_singles.fastq.gz \\
            out=${sample_id}_singles_ncontam.fastq.gz \\
            outm=${sample_id}_singles_contam.fastq.gz \\
            stats=${sample_id}_bbduk_log.txt \\
            k=${params.bbduk.k} \\
            minkmerhits=${params.bbduk.c} \\
			minlength=${params.bbduk.min_len} \\
            ref=${params.bbduk.contaminants} \\
            overwrite=true \\
            threads=${params.bbduk.cluster_cpus}
        """
}