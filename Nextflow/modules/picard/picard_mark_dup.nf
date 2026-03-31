process PICARD_MARK_DUP {
    publishDir "$params.DEFAULT.outdir/read_mapping/duplicates", mode: 'copy', pattern: "*.mmm"
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.picard_dup.cluster_cpus
    memory params.picard_dup.cluster_memory
    time params.picard_dup.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}_dupmarked.bam"), path("${sample_id}_dupmarked.bai"), emit:dupmarked_bam
        //path("${sample_id}.mmm"), emit:metrics_file

    script:
        """
        java -Xmx${params.picard_dup.java_xmx} \\
            -XX:-UsePerfData \\
            -jar /usr/picard/picard.jar MarkDuplicates \\
            ASSUME_SORTED=true \\
            VALIDATION_STRINGENCY=LENIENT \\
            OUTPUT=${sample_id}_dupmarked.bam \\
            INPUT=${bam_file} \\
            CREATE_INDEX=true \\
            METRICS_FILE=${sample_id}.mmm
        """
}
