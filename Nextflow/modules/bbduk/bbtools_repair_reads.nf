process BBTOOLS_REPAIR_READS {
    //publishDir "$params.DEFAULT.outdir/qced_reads/", mode: 'copy'
    debug true
    //All Java-based steps have problems with parallelization because they will all use the same temporary directory
    //which fills up quickly when many processes are run at the same time, we therefore set these steps to "sequential"
    //mode by using the maxForks command
    maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.bbtools_repair.cluster_cpus
    memory params.bbtools_repair.cluster_memory
    time params.bbtools_repair.cluster_time

    input:
        tuple val(sample_id), path(reads1), path(reads2)

    output:
        tuple val(sample_id), path("${sample_id}_fixed_R1.fastq.gz"), path("${sample_id}_fixed_R2.fastq.gz"), emit: repaired_reads

    script:
        """
        /bbmap/repair.sh \\
            -Xmx${params.bbtools_repair.java_xmx} \\
            in=${reads1} \\
            in2=${reads2} \\
            out=${sample_id}_fixed_R1.fastq.gz \\
            out2=${sample_id}_fixed_R2.fastq.gz \\
            repair=t \\
            overwrite=true
        """
}
