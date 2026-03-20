process BBDUK_PAIRED {
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
        tuple val(sample_id), path(infile_R1), path(infile_R2)

    output:
        tuple val(sample_id), path("${sample_id}_paired_ncontam_R1.fastq.gz"), path("${sample_id}_paired_ncontam_R2.fastq.gz"), emit: paired_reads
        path("${sample_id}_bbduk_log.txt"), emit: log

    script:
        """
        /bbmap/bbduk.sh \\
            -Xmx1g \\
            in=${infile_R1} \\
            in2=${infile_R2} \\
            out=${sample_id}_paired_ncontam_R1.fastq.gz \\
            out2=${sample_id}_paired_ncontam_R2.fastq.gz \\
            outm=${sample_id}_paired_contam_R1.fastq.gz \\
            outm2=${sample_id}_paired_contam_R2.fastq.gz \\
            stats=${sample_id}_bbduk_log.txt \\
            k=${params.bbduk.k} \\
            minkmerhits=${params.bbduk.c} \\
			minlength=${params.bbduk.min_len} \\
            ref=${params.bbduk.contaminants} \\
            overwrite=true \\
            threads=1
        """
}