process SAMTOOLS_TO_BAM_PE {
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    //publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_bam.cluster_cpus
    memory params.samtools_bam.cluster_memory
    time params.samtools_bam.cluster_time

    input:
        tuple val(sample_id), path(sam_file)

    output:
        tuple val(sample_id), path("${sample_id}.pe.bam"), emit: bam_output
    
    script:
        """
        samtools view -O BAM -o ${sample_id}.pe.bam ${sam_file}
        """
}
