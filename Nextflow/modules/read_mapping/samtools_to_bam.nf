process SAMTOOLS_TO_BAM {
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
        tuple val(sample_id), path("${sample_id}.bam"), emit: bam_output
    
    script:
        """
        samtools view -bS ${sam_file} | samtools sort -O bam -o ${sample_id}.bam
        """
}
