process PICARD_BAM_TO_FASTQ {
    publishDir "$params.DEFAULT.outdir/read_mapping/duplicates", mode: 'copy', pattern: "*.mmm"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.picard_bam_to_fastq.cluster_cpus
    memory params.picard_bam_to_fastq.cluster_memory
    time params.picard_bam_to_fastq.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}_R1.fastq"), path("${sample_id}_R2.fastq"), emit:fastq_output

    script:
        """
        java -Xmx${params.picard_bam_to_fastq.java_xmx} \\
            -XX:-UsePerfData \\
            -jar /usr/picard/picard.jar SamToFastq \\
            INPUT=${bam_file} \\
            FASTQ=${sample_id}_R1.fastq \\
            SECOND_END_FASTQ=${sample_id}_R2.fastq \\
            INCLUDE_NON_PF_READS=true \\
            VALIDATION_STRINGENCY=SILENT
        """
}
