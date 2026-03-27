process BBDUK_COMBINED {
    //publishDir "$params.DEFAULT.outdir/qced_reads/", mode: 'copy'
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
        tuple val(sample_idP), path(infile_Paired1), path(infile_Paired2)
        tuple val(sample_idS), path(infile_Singles1), path(infile_Singles2)


    output:
        tuple val(sample_idP), path("${sample_idP}_paired_ncontam_R1.fastq.gz"), path("${sample_idP}_paired_ncontam_R2.fastq.gz"), emit: paired_reads
        tuple val(sample_idS), path("${sample_idS}_singles_ncontam.fastq.gz"), emit: single_reads
        path("${sample_idP}_paired_bbduk_log.txt"), emit: paired_log
        path("${sample_idS}_singles_bbduk_log.txt"), emit: singles_log

    script:
        """
        /bbmap/bbduk.sh \\
            -Xmx1g \\
            in=${infile_Paired1} \\
            in2=${infile_Paired2} \\
            out=${sample_idP}_paired_ncontam_R1.fastq.gz \\
            out2=${sample_idP}_paired_ncontam_R2.fastq.gz \\
            stats=${sample_idP}_paired_bbduk_log.txt \\
            k=${params.bbduk.k} \\
            minkmerhits=${params.bbduk.c} \\
            minlength=${params.bbduk.min_len} \\
            ref=${params.bbduk.contaminants} \\
            overwrite=true \\
            threads=1 && \\

        {
            gzip -cd ${infile_Singles1} | awk '1' ; \\
            gzip -cd ${infile_Singles2} | awk '1' ; \\
        } | gzip -c > ${sample_idS}_singles.fastq.gz && \\

        /bbmap/bbduk.sh \\
            -Xmx1g \\
            in=${sample_idS}_singles.fastq.gz \\
            out=${sample_idS}_singles_ncontam.fastq.gz \\
            stats=${sample_idS}_singles_bbduk_log.txt \\
            k=${params.bbduk.k} \\
            minkmerhits=${params.bbduk.c} \\
            minlength=${params.bbduk.min_len} \\
            ref=${params.bbduk.contaminants} \\
            overwrite=true \\
            threads=${params.bbduk.cluster_cpus}
        """
}
